import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/vocabulary.dart';
import '../models/word_state.dart';
import '../services/learning_state_service.dart';
import '../services/oxford_service.dart';
import '../services/srs_service.dart';
import '../services/user_data_service.dart';
import 'exercises/fill_in_context_exercise.dart';
import 'exercises/listen_and_type_exercise.dart';
import 'exercises/multiple_choice_exercise.dart';
import 'session_results_screen.dart';
import '../theme/brutalist_theme.dart';
import '../utils/log.dart';
import '../widgets/brutalist_card.dart';

class LearningScreen extends StatefulWidget {
  final int day;
  final List<Vocabulary> vocabularies;
  final int initialIndex;
  final VoidCallback? onCompleted;

  const LearningScreen({
    super.key,
    required this.day,
    required this.vocabularies,
    this.initialIndex = 0,
    this.onCompleted,
  });

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  Set<String> _knownWords = {};

  // false = show English definition (default), true = show Vietnamese translation of definition
  bool _translateDefinition = false;

  // Oxford definitions per page index
  final Map<int, List<OxfordSense>> _oxfordCache = {};
  bool _loadingDef = false;

  // Translated VI definitions per page index (list of translated strings, one per sense)
  final Map<int, List<String>> _translatedDefsCache = {};
  bool _translatingDef = false;

  final _audioPlayer = AudioPlayer();
  bool _playingAudio = false;

  // Pinned exercise + distractor pick per card so PageView rebuilds don't
  // swap exercise types mid-card.
  final Map<int, ExerciseType> _exerciseCache = {};
  final Map<int, List<Vocabulary>> _distractorsCache = {};

  // Ratings the user submitted during this session, in card order. Handed
  // off to the results screen on completion.
  final List<ReviewRating> _sessionRatings = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _loadKnownWords();
    _prepareCard(_currentIndex);
    _persistContext();
  }

  /// Persists "where the user left off" so the menu's Continue tile can
  /// jump back into this session. Called on first build + every page change.
  void _persistContext() {
    if (widget.vocabularies.isEmpty) return;
    LearningStateService().saveContext(LearningContext(
      day: widget.day,
      wordKeys: widget.vocabularies.map((v) => v.word.toLowerCase()).toList(),
      currentIndex: _currentIndex,
      totalCount: widget.vocabularies.length,
      lastOpenedMs: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  Future<void> _loadKnownWords() async {
    setState(() {
      _knownWords = UserDataService().knownWords;
    });
  }

  /// Fetches the English definition for the card at [index]; if the user is
  /// currently viewing Vietnamese, chains a translation so the new card
  /// arrives already translated instead of forcing them to toggle EN → VI.
  Future<void> _prepareCard(int index) async {
    await _fetchDefinition(index);
    if (_translateDefinition && mounted) {
      await _translateSenses(index);
    }
  }

  Future<void> _fetchDefinition(int index) async {
    if (_oxfordCache.containsKey(index)) return;
    if (!mounted) return;
    final vocab = widget.vocabularies[index];
    setState(() => _loadingDef = true);
    final senses = await OxfordService.fetchDefinitions(vocab.word, vocab.url);
    if (!mounted) return;
    setState(() {
      _oxfordCache[index] = senses;
      _loadingDef = false;
    });
  }

  Future<void> _toggleKnownWord(String word) async {
    final messenger = ScaffoldMessenger.of(context);
    final t = AppLocalizations.of(context);
    final isAdded = !_knownWords.contains(word.toLowerCase());
    await UserDataService().toggleKnownWord(word);
    if (!mounted) return;
    setState(() {
      _knownWords = UserDataService().knownWords;
    });
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(isAdded ? t.learningMarkedKnown : t.learningRemovedFromKnown),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: t.commonUndo,
          onPressed: () async {
            await UserDataService().toggleKnownWord(word);
            if (!mounted) return;
            setState(() {
              _knownWords = UserDataService().knownWords;
            });
          },
        ),
      ),
    );
  }

  Future<void> _playAudio(String url) async {
    if (url.isEmpty || _playingAudio) return;
    setState(() => _playingAudio = true);
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e, st) {
      logCaught(e, st, 'LearningScreen.playAudio');
    }
    if (mounted) setState(() => _playingAudio = false);
  }

  Future<void> _toggleTranslation(int index) async {
    final newVal = !_translateDefinition;
    setState(() => _translateDefinition = newVal);
    if (newVal) await _translateSenses(index);
  }

  Future<void> _translateSenses(int index) async {
    if (_translatedDefsCache.containsKey(index)) return;
    final senses = _oxfordCache[index];
    if (senses == null || senses.isEmpty) return;
    if (!mounted) return;
    setState(() => _translatingDef = true);
    final results = await Future.wait(senses.map((s) => _translateToVi(s.definition)));
    if (!mounted) return;
    setState(() {
      _translatedDefsCache[index] = results;
      _translatingDef = false;
    });
  }

  static Future<String> _translateToVi(String text) async {
    if (text.isEmpty) return '';
    try {
      final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single'
        '?client=gtx&sl=en&tl=vi&dt=t&q=${Uri.encodeComponent(text)}',
      );
      final client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();
      client.close();
      if (response.statusCode != 200) return text;
      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as List;
      final segments = json[0] as List;
      return segments
          .where((s) => s is List && s.isNotEmpty && s[0] is String)
          .map((s) => s[0] as String)
          .join();
    } catch (_) {
      return text;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.day == 0 ? t.learningSearchTitle : t.learningDayTitle(widget.day)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.vocabularies.isNotEmpty)
            IconButton(
              icon: Icon(
                _knownWords.contains(widget.vocabularies[_currentIndex].word.toLowerCase())
                    ? Icons.check_circle_rounded
                    : Icons.check_circle_outline_rounded,
              ),
              onPressed: () => _toggleKnownWord(widget.vocabularies[_currentIndex].word),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildLocationIndicator(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.vocabularies.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _prepareCard(index);
                _persistContext();
              },
              itemBuilder: (context, index) {
                final vocab = widget.vocabularies[index];
                final exType = _exerciseFor(index);
                if (exType == ExerciseType.multipleChoice) {
                  return MultipleChoiceExercise(
                    word: vocab,
                    distractors: _distractorsFor(index),
                    onAnswered: (rating) => _submitRating(rating),
                  );
                }
                if (exType == ExerciseType.listenAndType) {
                  return ListenAndTypeExercise(
                    word: vocab,
                    onAnswered: (rating) => _submitRating(rating),
                  );
                }
                if (exType == ExerciseType.fillInContext) {
                  return FillInContextExercise(
                    word: vocab,
                    onAnswered: (rating) => _submitRating(rating),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: BrutalistCard(
                    backgroundColor: levelColor(vocab.levels, fallbackIndex: index),
                    child: Stack(
                      children: [
                        // Small affordances: info ⓘ peeks at level/topic; archive
                        // box lets the user permanently drop a trivial word from
                        // the daily queue without rating it Easy multiple times.
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: t.learningTooltipKnown,
                                icon: Icon(
                                  Icons.archive_outlined,
                                  color: BrutalistTheme.black.withValues(alpha: 0.45),
                                  size: 22,
                                ),
                                onPressed: () => _confirmAlreadyKnown(vocab),
                              ),
                              IconButton(
                                tooltip: t.learningTooltipDetails,
                                icon: Icon(
                                  Icons.info_outline_rounded,
                                  color: BrutalistTheme.black.withValues(alpha: 0.45),
                                  size: 22,
                                ),
                                onPressed: () => _showWordDetails(vocab),
                              ),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              vocab.word,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 50,
                                  height: 1.1,
                                  color: BrutalistTheme.black,
                                ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Text(
                                vocab.ipa,
                                style: GoogleFonts.notoSans(
                                  textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: BrutalistTheme.black,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (vocab.audioLink.isNotEmpty)
                                Material(
                                  color: BrutalistTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(24),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () => _playAudio(vocab.audioLink),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: _playingAudio
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: BrutalistTheme.primary,
                                              ),
                                            )
                                          : const Icon(Icons.volume_up_rounded, color: BrutalistTheme.primary, size: 22),
                                    ),
                                  ),
                                ),
                              if (vocab.url.isNotEmpty)
                                Material(
                                  color: BrutalistTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(24),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () async {
                                      final Uri url = Uri.parse(vocab.url);
                                      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.learningCouldntOpenLink)));
                                        }
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(Icons.open_in_new_rounded, color: BrutalistTheme.primary, size: 22),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (vocab.partOfSpeech.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            // Part of speech kept inline as a subtle caption — the
                            // most learning-relevant tag. Level + topic move to the
                            // info sheet so the card isn't a wall of metadata.
                            Text(
                              vocab.partOfSpeech.toLowerCase(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: BrutalistTheme.black.withValues(alpha: 0.55),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 28),
                          // Vietnamese word translation — always visible
                          Text(
                            vocab.translation,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: BrutalistTheme.black,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          // Definitions: English by default, Vietnamese when _translateDefinition=true
                          if (_loadingDef && !_oxfordCache.containsKey(index))
                            const _DefinitionSkeleton()
                          else if ((_oxfordCache[index] ?? []).isNotEmpty)
                            ...List.generate(_oxfordCache[index]!.length, (si) {
                              final s = _oxfordCache[index]![si];
                              final viDefs = _translatedDefsCache[index];
                              final showVI = _translateDefinition && viDefs != null;
                              final defText = showVI && si < viDefs.length
                                  ? viDefs[si]
                                  : s.definition;
                              final isLast = si == _oxfordCache[index]!.length - 1;
                              return Padding(
                                padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _translatingDef && _translateDefinition && viDefs == null
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: BrutalistTheme.primary),
                                          )
                                        : Text(
                                            defText,
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  color: BrutalistTheme.black,
                                                  height: 1.45,
                                                ),
                                          ),
                                    if (s.example.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          '"${s.example}"',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontStyle: FontStyle.italic,
                                                color: BrutalistTheme.textMuted,
                                                height: 1.4,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.vocabularies.isNotEmpty &&
              _exerciseFor(_currentIndex) == ExerciseType.recognize) ...[
            _buildRatingRow(),
          ],
          if (widget.vocabularies.isNotEmpty &&
              _exerciseFor(_currentIndex) == ExerciseType.recognize)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: context.bBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: _currentIndex > 0
                      ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
                ),
                _buildDefinitionLanguageToggle(),
                _buildNavButton(
                  icon: _currentIndex < widget.vocabularies.length - 1
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.skip_next_rounded,
                  onPressed: _currentIndex < widget.vocabularies.length - 1
                      ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : widget.onCompleted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// One-tap exit for trivial words. Confirms, then hard-promotes the word
  /// to "mastered" with a year-long interval — so it stops appearing in
  /// daily sessions without the user having to rate Easy five times.
  Future<void> _confirmAlreadyKnown(Vocabulary vocab) async {
    final t = AppLocalizations.of(context);
    final accept = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.learningSkipTitle),
        content: Text(
          t.learningSkipBody(vocab.word),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.bMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            child: Text(t.commonCancel,
                style: TextStyle(color: context.bMuted, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: BrutalistTheme.primary,
              foregroundColor: BrutalistTheme.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () => Navigator.of(dctx).pop(true),
            child: Text(t.learningSkipAction, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (accept != true || !mounted) return;
    await SrsService().markMastered(vocab.word);
    await UserDataService().addKnownWord(vocab.word);
    _sessionRatings.add(ReviewRating.easy);
    if (!mounted) return;
    if (_currentIndex < widget.vocabularies.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      widget.onCompleted?.call();
      await Navigator.of(context).pushReplacement(smoothRoute(
        SessionResultsScreen(
          ratings: List.of(_sessionRatings),
          moreDue: SrsService().dueCount() > 0,
        ),
      ));
    }
  }

  /// Bottom sheet showing level + topic for the current word. Keeps the
  /// metadata one tap away without cluttering the reading column.
  void _showWordDetails(Vocabulary vocab) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.bBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.bSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              vocab.word,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (vocab.levels.isNotEmpty)
                  _badge(
                    context,
                    vocab.levels.toUpperCase(),
                    BrutalistTheme.black,
                    BrutalistTheme.border.withValues(alpha: 0.4),
                  ),
                if (vocab.topic.isNotEmpty)
                  _badge(
                    context,
                    vocab.topic,
                    BrutalistTheme.accent,
                    BrutalistTheme.accentLight,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(BuildContext context, String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
      ),
    );
  }

  /// Replaces the old "X / Y" + "Z%" + linear progress bar. Up to 30 vocab
  /// items render as dots (current = solid primary, others = muted). Beyond
  /// 30 we fall back to a one-line muted caption so the dot row doesn't
  /// become an unreadable smudge.
  Widget _buildLocationIndicator() {
    final t = AppLocalizations.of(context);
    final total = widget.vocabularies.length;
    if (total == 0) return const SizedBox(height: 16);
    if (total > 30) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            t.learningWordOfTotal(_currentIndex + 1, total),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.bMuted,
                ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: List.generate(total, (i) {
          final isActive = i == _currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive
                  ? BrutalistTheme.primary
                  : context.bSubtle,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  /// Compact segmented control: "English" / "Tiếng Việt" with a one-line label
  /// above so the user can tell what it's switching. Replaces a bare iOS-style
  /// switch with an "EN"/"VI" code that was easy to misread.
  Widget _buildDefinitionLanguageToggle() {
    final t = AppLocalizations.of(context);
    Widget seg(String label, bool active, VoidCallback onTap) {
      return InkWell(
        onTap: active ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? BrutalistTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: active ? BrutalistTheme.white : context.bMuted,
                ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          t.learningDefinition,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.bMuted,
                fontSize: 11,
                letterSpacing: 0.3,
              ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: context.bSubtle.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              seg(t.learningDefinitionEnglish, !_translateDefinition, () {
                if (_translateDefinition) _toggleTranslation(_currentIndex);
              }),
              seg(t.learningDefinitionVietnamese, _translateDefinition, () {
                if (!_translateDefinition) _toggleTranslation(_currentIndex);
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// Decides which exercise widget to render for the card at [index]. Cached
  /// in [_exerciseCache] so the choice is stable across rebuilds — otherwise
  /// the SRS state could mutate mid-card and the page would re-render with a
  /// different exercise type.
  ExerciseType _exerciseFor(int index) {
    final cached = _exerciseCache[index];
    if (cached != null) return cached;
    final vocab = widget.vocabularies[index];
    final type = SrsService().pickExerciseType(
      vocab.word,
      hasAudio: vocab.audioLink.isNotEmpty,
      hasExample: vocab.url.isNotEmpty,
    );
    _exerciseCache[index] = type;
    return type;
  }

  /// Picks 3 distractor words from the rest of the session for the multiple
  /// choice exercise. Stable across rebuilds.
  List<Vocabulary> _distractorsFor(int index) {
    final cached = _distractorsCache[index];
    if (cached != null) return cached;
    final pool = <Vocabulary>[];
    final correct = widget.vocabularies[index].word.toLowerCase();
    for (final v in widget.vocabularies) {
      if (v.word.toLowerCase() != correct &&
          v.translation.trim().isNotEmpty) {
        pool.add(v);
      }
    }
    pool.shuffle();
    final picks = pool.take(3).toList();
    _distractorsCache[index] = picks;
    return picks;
  }

  /// Submits an SRS rating for the current word and advances to the next card.
  /// At the end of the deck we call onCompleted so the caller can chain into
  /// the next session (e.g. next Day).
  Future<void> _submitRating(ReviewRating rating) async {
    if (widget.vocabularies.isEmpty) return;
    final word = widget.vocabularies[_currentIndex].word;
    _sessionRatings.add(rating);
    await SrsService().submitReview(word, rating);
    // Keep the legacy known-words store in sync so notifications + browse
    // modes still exclude what the user has already mastered.
    if (rating == ReviewRating.good || rating == ReviewRating.easy) {
      await UserDataService().addKnownWord(word);
    } else if (rating == ReviewRating.again) {
      await UserDataService().removeKnownWord(word);
    }
    if (!mounted) return;
    if (_currentIndex < widget.vocabularies.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      // Last card — push the results screen on top so the session closes with
      // a clear summary + streak signal instead of just popping silently.
      widget.onCompleted?.call();
      await Navigator.of(context).pushReplacement(smoothRoute(
        SessionResultsScreen(
          ratings: List.of(_sessionRatings),
          moreDue: SrsService().dueCount() > 0,
        ),
      ));
    }
  }

  /// Row of four rating chips above the nav bar. Color encodes severity:
  /// red Again → orange Hard → green Good → blue Easy.
  Widget _buildRatingRow() {
    final t = AppLocalizations.of(context);
    Widget chip(String label, ReviewRating rating, Color color) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Material(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _submitRating(rating),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color,
                          fontSize: 13,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: Row(
        children: [
          chip(t.learningAgain, ReviewRating.again, const Color(0xFFD9534F)),
          chip(t.learningHard, ReviewRating.hard, const Color(0xFFE5874E)),
          chip(t.learningGood, ReviewRating.good, BrutalistTheme.primary),
          chip(t.learningEasy, ReviewRating.easy, const Color(0xFF3E7CB1)),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback? onPressed}) {
    final active = onPressed != null;
    return Material(
      color: active ? BrutalistTheme.primaryLight : BrutalistTheme.border.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(icon, color: active ? BrutalistTheme.primary : BrutalistTheme.textMuted, size: 24),
        ),
      ),
    );
  }
}

/// Subtle pulsing placeholder for the Oxford definition while it's being
/// fetched. Three skeleton lines feel like an actual paragraph is loading,
/// so the user doesn't think the screen is broken.
class _DefinitionSkeleton extends StatefulWidget {
  const _DefinitionSkeleton();

  @override
  State<_DefinitionSkeleton> createState() => _DefinitionSkeletonState();
}

class _DefinitionSkeletonState extends State<_DefinitionSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.35, end: 0.8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _bar(double width) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, _) => Opacity(
        opacity: _opacity.value,
        child: Container(
          height: 14,
          width: width,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: BrutalistTheme.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bar(width * 0.65),
        _bar(width * 0.55),
        _bar(width * 0.4),
      ],
    );
  }
}
