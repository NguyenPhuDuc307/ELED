import 'dart:async';

import 'package:flutter/gestures.dart' show LongPressGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../l10n/gen/app_localizations.dart';
import '../models/speaking_set.dart';
import '../services/speaking_cloze.dart';
import '../services/speaking_score.dart';
import '../services/speaking_service.dart';
import '../services/tts_prefs_service.dart';
import '../theme/brutalist_theme.dart';
import '../utils/log.dart';
import '../widgets/brutalist_card.dart';
import 'word_lookup_sheet.dart';

enum SpeakingMode { shadow, recall, cloze, record }

/// Speaking practice for a single [SpeakingSet]. PageView through items, with
/// a mode selector at the top — each mode swaps the central panel:
///
///   - Shadow: TTS plays each sentence, user repeats.
///   - Recall: question only, tap to reveal answer.
///   - Cloze: answer with key content words blanked out.
///   - Record: mic in, transcript scored against the model answer.
class SpeakingPracticeScreen extends StatefulWidget {
  final String setId;
  const SpeakingPracticeScreen({super.key, required this.setId});

  @override
  State<SpeakingPracticeScreen> createState() => _SpeakingPracticeScreenState();
}

class _SpeakingPracticeScreenState extends State<SpeakingPracticeScreen> {
  SpeakingSet? _set;
  int _index = 0;
  SpeakingMode _mode = SpeakingMode.shadow;
  late final PageController _pageCtrl;

  // TTS
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;
  double _ttsRate = 0.5;
  int? _speakingSentenceIdx;
  // Karaoke-style word highlight. `_activeUtterance` is the full string passed
  // to `_tts.speak`; `_utteranceStart`/`_utteranceEnd` are char offsets within
  // it, populated by `setProgressHandler`. Cleared on completion / stop.
  String? _activeUtterance;
  int _utteranceStart = 0;
  int _utteranceEnd = 0;

  // STT
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _sttAvailable = false;
  bool _sttListening = false;
  String _liveTranscript = '';
  SpeakingScore? _score;

  // Recall reveal state per item
  final Set<int> _revealed = {};
  // Cloze: per-item set of blanks already revealed.
  final Map<int, Set<String>> _clozeRevealed = {};

  // Cache of long-press recognizers keyed by lowercased word. Re-used across
  // rebuilds so we don't leak gesture recognizers — disposed on screen exit.
  final Map<String, LongPressGestureRecognizer> _wordRecognizers = {};

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _load();
    _initTts();
    _initStt();
  }

  Future<void> _load() async {
    await SpeakingService().ready;
    if (!mounted) return;
    setState(() {
      _set = SpeakingService().byId(widget.setId);
    });
  }

  Future<void> _initTts() async {
    try {
      await _tts.setSpeechRate(_ttsRate);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
      _tts.setCompletionHandler(() {
        if (!mounted) return;
        setState(() {
          _speakingSentenceIdx = null;
          _activeUtterance = null;
          _utteranceStart = 0;
          _utteranceEnd = 0;
        });
      });
      // Karaoke highlight — fires per word range during speech on iOS and on
      // Android API 26+ when the TTS engine implements onRangeStart. Older
      // engines simply never fire and the active sentence stays unmarked.
      _tts.setProgressHandler((text, start, end, word) {
        if (!mounted) return;
        setState(() {
          _activeUtterance = text;
          _utteranceStart = start;
          _utteranceEnd = end;
        });
      });
      await _applyVoicePref();
      _ttsReady = true;
    } catch (e, st) {
      logCaught(e, st, 'SpeakingPractice.initTts');
    }
  }

  /// Applies the saved accent + voice-name preference. If the user has picked
  /// a specific voice for the current accent (and that voice is still installed
  /// on the device), set it directly. Otherwise fall back to language-only.
  Future<void> _applyVoicePref() async {
    final prefs = TtsPrefsService();
    final locale = prefs.accent.locale;
    try {
      await _tts.setLanguage(locale);
    } catch (e, st) {
      logCaught(e, st, 'SpeakingPractice.setLanguage');
    }
    final wantedName = prefs.voiceFor(prefs.accent);
    if (wantedName == null || wantedName.isEmpty) return;
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) return;
      for (final v in voices) {
        if (v is! Map) continue;
        final m = v.map((k, value) => MapEntry(k.toString(), value.toString()));
        if (m['name'] == wantedName) {
          await _tts.setVoice(
              {'name': m['name']!, 'locale': m['locale'] ?? locale});
          return;
        }
      }
    } catch (e, st) {
      logCaught(e, st, 'SpeakingPractice.setVoice');
    }
  }

  Future<void> _initStt() async {
    try {
      _sttAvailable = await _stt.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            setState(() => _sttListening = false);
          }
        },
        onError: (err) {
          debugPrint('SpeakingPractice.stt.error: ${err.errorMsg}');
          if (!mounted) return;
          setState(() => _sttListening = false);
        },
      );
      if (mounted) setState(() {});
    } catch (e, st) {
      logCaught(e, st, 'SpeakingPractice.initStt');
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _stt.stop();
    _pageCtrl.dispose();
    for (final r in _wordRecognizers.values) {
      r.dispose();
    }
    _wordRecognizers.clear();
    super.dispose();
  }

  /// Returns (creating if needed) a long-press recognizer that opens the word
  /// lookup sheet for [word]. Cached per lowercased form so repeated occurrences
  /// of the same word share one recognizer across rebuilds.
  LongPressGestureRecognizer _recognizerFor(String word) {
    return _wordRecognizers.putIfAbsent(
      word,
      () => LongPressGestureRecognizer()
        ..onLongPress = () {
          HapticFeedback.selectionClick();
          _lookupWord(word);
        },
    );
  }

  /// Opens the word lookup bottom sheet for [rawWord] — strips punctuation
  /// first so a token like "concentration." resolves the same as
  /// "concentration". The sheet itself handles CSV lookup, translation and
  /// Oxford fetch.
  void _lookupWord(String rawWord) {
    final cleaned = rawWord.replaceAll(RegExp(r"[^A-Za-z']"), '').toLowerCase();
    if (cleaned.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WordLookupSheet(word: cleaned),
    );
  }

  /// Splits [text] into alternating word / non-word tokens, preserving offsets
  /// so the caller can map them back to the highlight range or attach a
  /// gesture recognizer per word.
  List<_TextToken> _tokenize(String text) {
    final tokens = <_TextToken>[];
    final re = RegExp(r"[A-Za-z]+(?:'[A-Za-z]+)?");
    int lastEnd = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > lastEnd) {
        tokens.add(_TextToken(lastEnd, m.start, false));
      }
      tokens.add(_TextToken(m.start, m.end, true));
      lastEnd = m.end;
    }
    if (lastEnd < text.length) {
      tokens.add(_TextToken(lastEnd, text.length, false));
    }
    return tokens;
  }

  Future<void> _speak(String text, {int? sentenceIdx}) async {
    if (!_ttsReady) return;
    await _tts.stop();
    if (!mounted) return;
    setState(() {
      _speakingSentenceIdx = sentenceIdx;
      // Preset the active utterance so even before the first progress event
      // fires we can show "this is the line being read" — the highlight
      // background just won't appear until the engine reports a word range.
      _activeUtterance = text;
      _utteranceStart = 0;
      _utteranceEnd = 0;
    });
    try {
      await _tts.speak(text);
    } catch (e, st) {
      logCaught(e, st, 'SpeakingPractice.speak');
    }
  }

  Future<void> _speakAll(List<String> sentences) async {
    for (var i = 0; i < sentences.length; i++) {
      if (!mounted) return;
      await _speak(sentences[i], sentenceIdx: i);
    }
  }

  /// Renders [text] as a `RichText` with two enhancements:
  ///   1) Karaoke-style highlight on the word currently being spoken when this
  ///      string matches the active TTS utterance.
  ///   2) Every word token gets a long-press recognizer that opens the word
  ///      lookup sheet, so the user can check meanings without leaving the
  ///      practice screen.
  /// Falls back gracefully on engines that never fire progress callbacks — the
  /// long-press still works, the highlight just stays off.
  Widget _highlightableText(String text, TextStyle? style) {
    final isActive = _activeUtterance == text && _utteranceEnd > _utteranceStart;
    final hStart = isActive ? _utteranceStart.clamp(0, text.length) : 0;
    final hEnd = isActive ? _utteranceEnd.clamp(hStart, text.length) : 0;
    final hasHighlight = isActive && hEnd > hStart;

    final highlightStyle = TextStyle(
      backgroundColor: BrutalistTheme.primary.withValues(alpha: 0.30),
      color: BrutalistTheme.primary,
      fontWeight: FontWeight.w800,
    );

    final spans = <InlineSpan>[];
    for (final tok in _tokenize(text)) {
      final slice = text.substring(tok.start, tok.end);
      final inHighlight =
          hasHighlight && tok.start < hEnd && tok.end > hStart;
      final tokenStyle = inHighlight ? highlightStyle : null;
      if (tok.isWord) {
        spans.add(TextSpan(
          text: slice,
          style: tokenStyle,
          recognizer: _recognizerFor(slice.toLowerCase()),
        ));
      } else {
        spans.add(TextSpan(text: slice, style: tokenStyle));
      }
    }
    return RichText(text: TextSpan(style: style, children: spans));
  }

  Future<void> _setRate(double rate) async {
    setState(() => _ttsRate = rate);
    try {
      await _tts.setSpeechRate(rate);
    } catch (e, st) {
      logCaught(e, st, 'SpeakingPractice.setRate');
    }
  }

  Future<void> _startListening() async {
    final t = AppLocalizations.of(context);
    if (!_sttAvailable) {
      await _initStt();
      if (!mounted) return;
      if (!_sttAvailable) {
        _showSnack(t.speakingSttUnavailable);
        return;
      }
    }
    final micGranted = await _ensureMic();
    if (!mounted) return;
    if (!micGranted) {
      _showSnack(t.speakingMicDenied);
      return;
    }
    setState(() {
      _sttListening = true;
      _liveTranscript = '';
      _score = null;
    });
    HapticFeedback.lightImpact();
    try {
      await _stt.listen(
        onResult: (r) {
          if (!mounted) return;
          setState(() => _liveTranscript = r.recognizedWords);
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.dictation,
          listenFor: const Duration(seconds: 90),
          pauseFor: const Duration(seconds: 5),
          localeId: 'en_US',
        ),
      );
    } catch (e, st) {
      logCaught(e, st, 'SpeakingPractice.listen');
      if (mounted) setState(() => _sttListening = false);
    }
  }

  Future<void> _stopListening() async {
    try {
      await _stt.stop();
    } catch (e, st) {
      logCaught(e, st, 'SpeakingPractice.stop');
    }
    if (!mounted) return;
    final item = _currentItem();
    if (item != null && _liveTranscript.isNotEmpty) {
      setState(() {
        _score = SpeakingScore.compare(item.answer, _liveTranscript);
        _sttListening = false;
      });
    } else {
      setState(() => _sttListening = false);
    }
  }

  Future<bool> _ensureMic() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  void _showSnack(String msg) {
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ));
  }

  SpeakingItem? _currentItem() {
    final set = _set;
    if (set == null || set.items.isEmpty) return null;
    return set.items[_index];
  }

  void _onPageChanged(int i) {
    setState(() {
      _index = i;
      _liveTranscript = '';
      _score = null;
      _speakingSentenceIdx = null;
      _activeUtterance = null;
      _utteranceStart = 0;
      _utteranceEnd = 0;
    });
    _tts.stop();
    if (_sttListening) _stt.stop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final set = _set;
    if (set == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          set.topic,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          _buildModeSelector(t),
          _buildDots(set.items.length),
          Expanded(
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: set.items.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (_, i) => _buildItemPage(set.items[i], i, t),
            ),
          ),
          if (_mode == SpeakingMode.shadow) _buildRateSlider(t),
          if (_mode == SpeakingMode.record) _buildRecordBar(t),
        ],
      ),
    );
  }

  Widget _buildModeSelector(AppLocalizations t) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // In dark mode the previous pastel sage bg + dark sage text both sat too
    // close to the dark slate background, leaving inactive pills barely legible.
    // Swap to a translucent primary tint with a lighter sage fg so the labels
    // still read at a glance.
    final inactiveBg = isDark
        ? BrutalistTheme.primary.withValues(alpha: 0.22)
        : BrutalistTheme.primaryLight.withValues(alpha: 0.4);
    final inactiveFg =
        isDark ? const Color(0xFFA8D5A4) : BrutalistTheme.primary;

    Widget pill(SpeakingMode mode, IconData icon, String label) {
      final active = _mode == mode;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _mode = mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: active ? BrutalistTheme.primary : inactiveBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 18,
                    color: active ? BrutalistTheme.white : inactiveFg),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: active ? BrutalistTheme.white : inactiveFg,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Row(
        children: [
          pill(SpeakingMode.shadow, Icons.graphic_eq_rounded, t.speakingModeShadow),
          pill(SpeakingMode.recall, Icons.psychology_alt_rounded, t.speakingModeRecall),
          pill(SpeakingMode.cloze, Icons.short_text_rounded, t.speakingModeCloze),
          pill(SpeakingMode.record, Icons.mic_rounded, t.speakingModeRecord),
        ],
      ),
    );
  }

  Widget _buildDots(int total) {
    if (total == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: List.generate(total, (i) {
          final active = i == _index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? BrutalistTheme.primary : context.bSubtle,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildItemPage(SpeakingItem item, int i, AppLocalizations t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: BrutalistCard(
        backgroundColor: BrutalistTheme.primaryLight,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: BrutalistTheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Q${i + 1}',
                      style: const TextStyle(
                        color: BrutalistTheme.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _highlightableText(
                      item.question,
                      Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: BrutalistTheme.black,
                            fontSize: 17,
                            height: 1.3,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: t.speakingPlayQuestion,
                    onPressed: () => _speak(item.question),
                    icon: const Icon(Icons.volume_up_rounded,
                        color: BrutalistTheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _buildModeBody(item, i, t),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeBody(SpeakingItem item, int i, AppLocalizations t) {
    switch (_mode) {
      case SpeakingMode.shadow:
        return _buildShadow(item, t);
      case SpeakingMode.recall:
        return _buildRecall(item, i, t);
      case SpeakingMode.cloze:
        return _buildCloze(item, i, t);
      case SpeakingMode.record:
        return _buildRecord(item, t);
    }
  }

  Widget _buildShadow(SpeakingItem item, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                t.speakingShadowHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BrutalistTheme.black.withValues(alpha: 0.55),
                    ),
              ),
            ),
            FilledButton.icon(
              onPressed: () => _speakAll(item.sentences),
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: Text(t.speakingPlayAll),
              style: FilledButton.styleFrom(
                backgroundColor: BrutalistTheme.primary,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...item.sentences.asMap().entries.map((e) {
          final si = e.key;
          final s = e.value;
          final active = _speakingSentenceIdx == si;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: active
                  ? BrutalistTheme.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _speak(s, sentenceIdx: si),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        active
                            ? Icons.graphic_eq_rounded
                            : Icons.play_circle_outline_rounded,
                        size: 18,
                        color: BrutalistTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _highlightableText(
                          s,
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: BrutalistTheme.black,
                                height: 1.45,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecall(SpeakingItem item, int i, AppLocalizations t) {
    final revealed = _revealed.contains(i);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.speakingRecallHint,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BrutalistTheme.black.withValues(alpha: 0.55),
              ),
        ),
        const SizedBox(height: 14),
        if (!revealed)
          Center(
            child: FilledButton.icon(
              onPressed: () => setState(() => _revealed.add(i)),
              icon: const Icon(Icons.visibility_rounded, size: 18),
              label: Text(t.speakingRecallReveal),
              style: FilledButton.styleFrom(
                backgroundColor: BrutalistTheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
            ),
          )
        else
          _highlightableText(
            item.answer,
            Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: BrutalistTheme.black,
                  height: 1.5,
                ),
          ),
      ],
    );
  }

  Widget _buildCloze(SpeakingItem item, int i, AppLocalizations t) {
    final revealed = _clozeRevealed.putIfAbsent(i, () => <String>{});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                t.speakingClozeHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BrutalistTheme.black.withValues(alpha: 0.55),
                    ),
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() {
                for (final s in item.sentences) {
                  revealed.addAll(SpeakingCloze.picksFor(s));
                }
              }),
              icon: const Icon(Icons.visibility_rounded, size: 16),
              label: Text(t.speakingClozeRevealAll),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...item.sentences.map((s) {
          final picks = SpeakingCloze.picksFor(s);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildClozeSentence(s, picks, revealed),
          );
        }),
      ],
    );
  }

  Widget _buildClozeSentence(
      String sentence, Set<String> picks, Set<String> revealed) {
    // Split sentence on word boundaries while keeping punctuation/whitespace
    // inline. We render either the original token, or a tappable blank with
    // the same visual width as the word.
    final re = RegExp(r"[A-Za-z]+(?:'[A-Za-z]+)?|[^A-Za-z]+");
    final spans = <InlineSpan>[];
    for (final m in re.allMatches(sentence)) {
      final piece = m.group(0)!;
      final norm = piece.toLowerCase();
      final isWord = RegExp(r'^[A-Za-z]').hasMatch(piece);
      if (isWord && picks.contains(norm) && !revealed.contains(norm)) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: () => setState(() => revealed.add(norm)),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: BrutalistTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: BrutalistTheme.primary.withValues(alpha: 0.5),
                    width: 1),
              ),
              child: Text(
                '_' * piece.length,
                style: const TextStyle(
                  color: BrutalistTheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ));
      } else if (isWord) {
        // Non-blank word — long-press opens the lookup sheet so the user can
        // check meanings while filling in the gaps.
        spans.add(TextSpan(
          text: piece,
          recognizer: _recognizerFor(norm),
        ));
      } else {
        spans.add(TextSpan(text: piece));
      }
    }
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: BrutalistTheme.black,
              height: 1.6,
            ),
        children: spans,
      ),
    );
  }

  Widget _buildRecord(SpeakingItem item, AppLocalizations t) {
    final score = _score;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.speakingRecordHint,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BrutalistTheme.black.withValues(alpha: 0.55),
              ),
        ),
        const SizedBox(height: 14),
        if (_sttListening || _liveTranscript.isNotEmpty || score != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BrutalistTheme.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: BrutalistTheme.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _sttListening
                          ? Icons.mic_rounded
                          : Icons.mic_off_rounded,
                      size: 16,
                      color: _sttListening
                          ? const Color(0xFFD9534F)
                          : context.bMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _sttListening
                          ? t.speakingListening
                          : t.speakingYouSaid,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.bMuted,
                            fontSize: 11,
                            letterSpacing: 0.4,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _liveTranscript.isEmpty
                      ? '—'
                      : _liveTranscript,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: BrutalistTheme.black,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        Text(
          t.speakingTargetAnswer,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.bMuted,
                fontSize: 11,
                letterSpacing: 0.4,
              ),
        ),
        const SizedBox(height: 6),
        if (score == null)
          _highlightableText(
            item.answer,
            Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: BrutalistTheme.black,
                  height: 1.5,
                ),
          )
        else
          _buildScoredAnswer(score),
        if (score != null) ...[
          const SizedBox(height: 14),
          _buildScoreBadge(score, t),
        ],
      ],
    );
  }

  Widget _buildScoredAnswer(SpeakingScore score) {
    final spans = <InlineSpan>[];
    for (var i = 0; i < score.tokens.length; i++) {
      final tok = score.tokens[i];
      spans.add(TextSpan(
        text: tok.display,
        style: TextStyle(
          color: tok.matched
              ? BrutalistTheme.primary
              : const Color(0xFFD9534F),
          fontWeight: tok.matched ? FontWeight.w700 : FontWeight.w500,
          decoration: tok.matched ? null : TextDecoration.underline,
        ),
        recognizer: _recognizerFor(tok.display.toLowerCase()),
      ));
      if (i < score.tokens.length - 1) spans.add(const TextSpan(text: ' '));
    }
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: BrutalistTheme.black,
              height: 1.5,
            ),
        children: spans,
      ),
    );
  }

  Widget _buildScoreBadge(SpeakingScore score, AppLocalizations t) {
    final pct = score.percent;
    final (color, label) = pct >= 80
        ? (BrutalistTheme.primary, t.speakingScoreGreat)
        : pct >= 50
            ? (const Color(0xFFE5874E), t.speakingScoreOk)
            : (const Color(0xFFD9534F), t.speakingScoreTryAgain);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.bar_chart_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pct%  ·  $label',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  t.speakingScoreDetail(score.matched, score.total),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateSlider(AppLocalizations t) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.bBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.speed_rounded, size: 18, color: context.bMuted),
          const SizedBox(width: 8),
          Text(
            t.speakingSpeed,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.bMuted,
                  fontSize: 11,
                ),
          ),
          Expanded(
            child: Slider(
              value: _ttsRate,
              min: 0.25,
              max: 0.8,
              divisions: 11,
              activeColor: BrutalistTheme.primary,
              label: '${(_ttsRate * 100).round()}%',
              onChanged: (v) => _setRate(v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordBar(AppLocalizations t) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: context.bBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _sttListening
                  ? t.speakingTapToStop
                  : t.speakingTapToRecord,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.bMuted,
                  ),
            ),
          ),
          GestureDetector(
            onTap: _sttListening ? _stopListening : _startListening,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _sttListening
                    ? const Color(0xFFD9534F)
                    : BrutalistTheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_sttListening
                            ? const Color(0xFFD9534F)
                            : BrutalistTheme.primary)
                        .withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: _sttListening ? 4 : 1,
                  ),
                ],
              ),
              child: Icon(
                _sttListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: BrutalistTheme.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextToken {
  final int start;
  final int end;
  final bool isWord;
  const _TextToken(this.start, this.end, this.isWord);
}
