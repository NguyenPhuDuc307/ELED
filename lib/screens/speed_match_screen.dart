import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/vocabulary.dart';
import '../models/word_state.dart';
import '../services/srs_service.dart';
import '../services/streak_service.dart';
import '../services/user_data_service.dart';
import '../theme/brutalist_theme.dart';

/// Arcade-style cousin of [MatchGameScreen]: a 30-second countdown, 4 active
/// pairs at a time. Every correctly matched pair is replaced from the pool
/// so the user keeps tapping. When the timer hits zero the session ends and
/// each matched word is auto-rated Good in the SRS schedule.
class SpeedMatchScreen extends StatefulWidget {
  /// Vocabulary pool to draw rounds from. Caller is expected to pass at
  /// least 6 entries (the screen still works with fewer, but the experience
  /// is thin).
  final List<Vocabulary> pool;

  /// Game length in seconds.
  static const gameSeconds = 30;

  /// Number of pairs displayed simultaneously.
  static const slots = 4;

  const SpeedMatchScreen({super.key, required this.pool});

  @override
  State<SpeedMatchScreen> createState() => _SpeedMatchScreenState();
}

class _SpeedMatchScreenState extends State<SpeedMatchScreen> {
  // Source pool, shuffled once.
  late final List<Vocabulary> _source;
  int _sourceCursor = 0;

  // Current 4 pairs on screen.
  final List<Vocabulary?> _slots = List<Vocabulary?>.filled(SpeedMatchScreen.slots, null);
  final List<Vocabulary?> _shuffledTranslations =
      List<Vocabulary?>.filled(SpeedMatchScreen.slots, null);

  // The word indices the user has successfully matched (across all rounds).
  final List<Vocabulary> _matchedWords = [];

  int? _selectedWordIdx;
  int? _selectedTransIdx;
  int? _wrongWordIdx;
  int? _wrongTransIdx;

  Timer? _ticker;
  int _remainingMs = SpeedMatchScreen.gameSeconds * 1000;
  bool _started = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _source = [...widget.pool]..shuffle(Random());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    _seedSlots();
    setState(() => _started = true);
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() {
        _remainingMs -= 100;
        if (_remainingMs <= 0) {
          _remainingMs = 0;
          _ticker?.cancel();
          _finish();
        }
      });
    });
  }

  void _seedSlots() {
    for (var i = 0; i < SpeedMatchScreen.slots; i++) {
      _slots[i] = _nextWord();
    }
    _reshuffleTranslations();
  }

  /// Pulls the next word out of [_source], wrapping if we run out (so a
  /// fast player doesn't bottom out the deck before 30s).
  Vocabulary? _nextWord() {
    if (_source.isEmpty) return null;
    final v = _source[_sourceCursor % _source.length];
    _sourceCursor++;
    return v;
  }

  void _reshuffleTranslations() {
    final present = <Vocabulary>[for (final v in _slots) ?v];
    present.shuffle(Random());
    var idx = 0;
    for (var i = 0; i < SpeedMatchScreen.slots; i++) {
      _shuffledTranslations[i] = _slots[i] == null
          ? null
          : (idx < present.length ? present[idx++] : null);
    }
  }

  void _pickWord(int i) {
    if (_finished || _slots[i] == null || _wrongWordIdx != null) return;
    if (_selectedTransIdx != null) {
      _evaluate(wordIdx: i, transIdx: _selectedTransIdx!);
      return;
    }
    setState(() {
      _selectedWordIdx = _selectedWordIdx == i ? null : i;
    });
  }

  void _pickTranslation(int j) {
    if (_finished || _shuffledTranslations[j] == null || _wrongTransIdx != null) return;
    if (_selectedWordIdx != null) {
      _evaluate(wordIdx: _selectedWordIdx!, transIdx: j);
      return;
    }
    setState(() {
      _selectedTransIdx = _selectedTransIdx == j ? null : j;
    });
  }

  Future<void> _evaluate({required int wordIdx, required int transIdx}) async {
    final word = _slots[wordIdx];
    final trans = _shuffledTranslations[transIdx];
    if (word == null || trans == null) return;
    final correct = word.word == trans.word;
    if (correct) {
      setState(() {
        _matchedWords.add(word);
        _slots[wordIdx] = _nextWord();
        // If we wrapped to the same word in the source, the screen would
        // still show the matched word — skip that to keep visuals fresh.
        if (_slots[wordIdx]?.word == word.word) {
          _slots[wordIdx] = _nextWord();
        }
        _selectedWordIdx = null;
        _selectedTransIdx = null;
        _reshuffleTranslations();
      });
    } else {
      setState(() {
        _wrongWordIdx = wordIdx;
        _wrongTransIdx = transIdx;
      });
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      setState(() {
        _wrongWordIdx = null;
        _wrongTransIdx = null;
        _selectedWordIdx = null;
        _selectedTransIdx = null;
      });
    }
  }

  Future<void> _finish() async {
    setState(() => _finished = true);
    final srs = SrsService();
    final user = UserDataService();
    final seen = <String>{};
    for (final v in _matchedWords) {
      // Same word can be matched twice in one session if source wraps; only
      // schedule it once for SRS so the ease factor doesn't double-bump.
      if (!seen.add(v.word.toLowerCase())) continue;
      await srs.submitReview(v.word, ReviewRating.good);
      await user.addKnownWord(v.word);
    }
    await StreakService().recordActivity();
  }

  void _restart() {
    _ticker?.cancel();
    setState(() {
      _sourceCursor = 0;
      _matchedWords.clear();
      _remainingMs = SpeedMatchScreen.gameSeconds * 1000;
      _selectedWordIdx = null;
      _selectedTransIdx = null;
      _wrongWordIdx = null;
      _wrongTransIdx = null;
      _finished = false;
      _started = false;
      _source.shuffle(Random());
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.speedMatchTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: !_started
              ? _splash(t)
              : _finished
                  ? _resultsView(t)
                  : _gameView(t),
        ),
      ),
    );
  }

  Widget _splash(AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded, size: 64, color: BrutalistTheme.primary),
          const SizedBox(height: 18),
          Text(
            t.speedMatchTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            t.speedMatchSubtitle(SpeedMatchScreen.gameSeconds),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.bMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          FilledButton.icon(
            onPressed: _start,
            style: FilledButton.styleFrom(
              backgroundColor: BrutalistTheme.primary,
              foregroundColor: BrutalistTheme.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(t.speedMatchStart,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _gameView(AppLocalizations t) {
    return Column(
      children: [
        _hud(t),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _column(words: true)),
              const SizedBox(width: 10),
              Expanded(child: _column(words: false)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hud(AppLocalizations t) {
    final progress = _remainingMs / (SpeedMatchScreen.gameSeconds * 1000);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: context.bSubtle,
                valueColor: AlwaysStoppedAnimation(
                  progress < 0.2 ? const Color(0xFFD9534F) : BrutalistTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: BrutalistTheme.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(_remainingMs / 1000).ceil()}s',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: BrutalistTheme.primary,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            t.speedMatchScore(_matchedWords.length),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.bMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }

  Widget _column({required bool words}) {
    return Column(
      children: List.generate(SpeedMatchScreen.slots, (i) {
        final isLast = i == SpeedMatchScreen.slots - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
            child: words ? _wordTile(i) : _translationTile(i),
          ),
        );
      }),
    );
  }

  Widget _wordTile(int i) {
    final vocab = _slots[i];
    if (vocab == null) return const SizedBox.shrink();
    final selected = _selectedWordIdx == i;
    final wrong = _wrongWordIdx == i;
    return _tile(
      label: vocab.word,
      selected: selected,
      wrong: wrong,
      onTap: () => _pickWord(i),
      emphasised: true,
    );
  }

  Widget _translationTile(int j) {
    final vocab = _shuffledTranslations[j];
    if (vocab == null) return const SizedBox.shrink();
    final selected = _selectedTransIdx == j;
    final wrong = _wrongTransIdx == j;
    return _tile(
      label: vocab.translation,
      selected: selected,
      wrong: wrong,
      onTap: () => _pickTranslation(j),
      emphasised: false,
    );
  }

  Widget _tile({
    required String label,
    required bool selected,
    required bool wrong,
    required VoidCallback onTap,
    required bool emphasised,
  }) {
    Color bg = context.bBg;
    Color border = context.bSubtle;
    Color textColor = context.bBorder;
    if (wrong) {
      bg = const Color(0xFFFADBD8);
      border = const Color(0xFFD9534F);
      textColor = const Color(0xFFD9534F);
    } else if (selected) {
      bg = BrutalistTheme.accentLight;
      border = BrutalistTheme.accent;
      textColor = BrutalistTheme.accent;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: emphasised ? FontWeight.w700 : FontWeight.w600,
                  color: textColor,
                  fontSize: emphasised ? 17 : 14,
                  height: 1.2,
                ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _resultsView(AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_off_rounded, size: 64, color: BrutalistTheme.primary),
          const SizedBox(height: 18),
          Text(
            t.speedMatchTimeUp,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            t.speedMatchScore(_matchedWords.length),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.bMuted,
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: context.bBorder, width: 1.5),
                  foregroundColor: context.bBorder,
                ),
                child: Text(t.resultsFinish,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _restart,
                style: FilledButton.styleFrom(
                  backgroundColor: BrutalistTheme.primary,
                  foregroundColor: BrutalistTheme.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.replay_rounded, size: 20),
                label: Text(t.speedMatchPlayAgain,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
