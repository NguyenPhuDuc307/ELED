import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/vocabulary.dart';
import '../models/word_state.dart';
import '../services/srs_service.dart';
import '../services/streak_service.dart';
import '../services/user_data_service.dart';
import '../theme/brutalist_theme.dart';
import 'session_results_screen.dart';

/// A matching mini-game: words on the left column, shuffled translations
/// on the right. Tap a word, then its translation. Correct pairs fade out
/// in green; wrong picks flash red. When every pair is matched the user
/// is auto-rated per-word and the standard results screen takes over.
///
/// Pair count is adaptive: up to 6 from the pool, with a minimum of 4
/// (the caller is expected to enforce that floor).
///
/// Auto-rating per word:
/// - Matched on the first attempt → ReviewRating.good
/// - Matched after one wrong pairing → ReviewRating.hard
/// - Matched after two+ wrong pairings → ReviewRating.again
class MatchGameScreen extends StatefulWidget {
  /// Pool of vocab to draw pairs from. The screen will refuse to start with
  /// fewer than 4 entries.
  final List<Vocabulary> pool;

  const MatchGameScreen({super.key, required this.pool});

  @override
  State<MatchGameScreen> createState() => _MatchGameScreenState();
}

class _MatchGameScreenState extends State<MatchGameScreen> {
  static const _minPairs = 4;
  static const _maxPairs = 6;

  late final List<Vocabulary> _pairs;
  late final List<Vocabulary> _shuffledTranslations;
  final Set<int> _matchedWordIdx = {};
  final Map<int, int> _attemptsByWordIdx = {};
  int? _selectedWordIdx;
  int? _selectedTransIdx;
  int? _wrongWordIdx;
  int? _wrongTransIdx;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    final source = [...widget.pool]..shuffle();
    final take = source.length.clamp(_minPairs, _maxPairs);
    _pairs = source.take(take).toList();
    _shuffledTranslations = [..._pairs]..shuffle(Random());
    // Guarantee the shuffled list isn't accidentally identical to source.
    if (_pairs.length > 1 &&
        List.generate(_pairs.length,
            (i) => _shuffledTranslations[i].word == _pairs[i].word).every((b) => b)) {
      _shuffledTranslations.add(_shuffledTranslations.removeAt(0));
    }
  }

  void _pickWord(int i) {
    if (_completed || _matchedWordIdx.contains(i) || _wrongWordIdx != null) return;
    // If a translation is already selected, this tap completes the pair —
    // resolve through the shared evaluator instead of just toggling the
    // word selection.
    if (_selectedTransIdx != null) {
      _evaluatePair(wordIdx: i, transIdx: _selectedTransIdx!);
      return;
    }
    setState(() {
      _selectedWordIdx = _selectedWordIdx == i ? null : i;
    });
  }

  void _pickTranslation(int j) {
    if (_completed) return;
    final translationWord = _shuffledTranslations[j];
    final alreadyMatched =
        _matchedWordIdx.any((i) => _pairs[i].word == translationWord.word);
    if (alreadyMatched || _wrongTransIdx != null) return;

    // Translation first is fine — wait for the word tap.
    if (_selectedWordIdx == null) {
      setState(() {
        _selectedTransIdx = _selectedTransIdx == j ? null : j;
      });
      return;
    }
    _evaluatePair(wordIdx: _selectedWordIdx!, transIdx: j);
  }

  /// Centralised pair-evaluation so word-first and translation-first paths
  /// share the same scoring + flash-error animation.
  Future<void> _evaluatePair({
    required int wordIdx,
    required int transIdx,
  }) async {
    final translationWord = _shuffledTranslations[transIdx];
    final correct = _pairs[wordIdx].word == translationWord.word;
    _attemptsByWordIdx[wordIdx] = (_attemptsByWordIdx[wordIdx] ?? 0) + 1;

    if (correct) {
      setState(() {
        _matchedWordIdx.add(wordIdx);
        _selectedWordIdx = null;
        _selectedTransIdx = null;
      });
      if (_matchedWordIdx.length == _pairs.length) {
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) await _finish();
      }
    } else {
      setState(() {
        _wrongWordIdx = wordIdx;
        _wrongTransIdx = transIdx;
      });
      await Future.delayed(const Duration(milliseconds: 700));
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
    setState(() => _completed = true);
    final ratings = <ReviewRating>[];
    for (int i = 0; i < _pairs.length; i++) {
      final attempts = _attemptsByWordIdx[i] ?? 0;
      final rating = attempts <= 1
          ? ReviewRating.good
          : attempts == 2
              ? ReviewRating.hard
              : ReviewRating.again;
      ratings.add(rating);
      final word = _pairs[i].word;
      await SrsService().submitReview(word, rating);
      if (rating == ReviewRating.good) {
        await UserDataService().addKnownWord(word);
      } else if (rating == ReviewRating.again) {
        await UserDataService().removeKnownWord(word);
      }
    }
    await StreakService().recordActivity();
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(smoothRoute(
      SessionResultsScreen(
        ratings: ratings,
        moreDue: SrsService().dueCount() > 0,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.matchGameTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
          child: Column(
            children: [
              _progressHeader(t),
              const SizedBox(height: 14),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildColumn(words: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildColumn(words: false)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Linear progress bar + count chip — cleaner than the old dot row and
  /// scales gracefully as pair count moves between 4 and 6.
  Widget _progressHeader(AppLocalizations t) {
    final ratio = _pairs.isEmpty ? 0.0 : _matchedWordIdx.length / _pairs.length;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              height: 6,
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: context.bSubtle.withValues(alpha: 0.5),
                valueColor:
                    const AlwaysStoppedAnimation(BrutalistTheme.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: BrutalistTheme.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            t.matchGameProgress(_matchedWordIdx.length, _pairs.length),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BrutalistTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontSize: 12,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildColumn({required bool words}) {
    return Column(
      children: List.generate(_pairs.length, (i) {
        final isLast = i == _pairs.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: words ? _wordTile(i) : _translationTile(i),
          ),
        );
      }),
    );
  }

  Widget _wordTile(int i) {
    final matched = _matchedWordIdx.contains(i);
    final selected = _selectedWordIdx == i;
    final wrong = _wrongWordIdx == i;
    return _tile(
      label: _pairs[i].word,
      matched: matched,
      selected: selected,
      wrong: wrong,
      onTap: () => _pickWord(i),
      emphasised: true,
    );
  }

  Widget _translationTile(int j) {
    final t = _shuffledTranslations[j];
    // A translation is matched once its paired word is matched.
    final matched = _matchedWordIdx.any((i) => _pairs[i].word == t.word);
    final selected = _selectedTransIdx == j;
    final wrong = _wrongTransIdx == j;
    return _tile(
      label: t.translation,
      matched: matched,
      selected: selected,
      wrong: wrong,
      onTap: () => _pickTranslation(j),
      emphasised: false,
    );
  }

  Widget _tile({
    required String label,
    required bool matched,
    required bool selected,
    required bool wrong,
    required VoidCallback onTap,
    required bool emphasised,
  }) {
    // Neutral resting palette so an untouched tile doesn't look pre-selected.
    // The English vs Vietnamese column read as different by font weight +
    // size, not by colour.
    Color bg = context.bBg;
    Color border = context.bSubtle;
    Color textColor = context.bBorder;
    double opacity = 1.0;
    List<BoxShadow> shadows = [
      BoxShadow(
        color: BrutalistTheme.black.withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];

    if (matched) {
      bg = BrutalistTheme.primary;
      border = BrutalistTheme.primary;
      textColor = BrutalistTheme.white;
      opacity = 0.75;
      shadows = const [];
    } else if (wrong) {
      bg = const Color(0xFFFFEBE8);
      border = const Color(0xFFD9534F);
      textColor = const Color(0xFFD9534F);
    } else if (selected) {
      bg = BrutalistTheme.accent;
      border = BrutalistTheme.accent;
      textColor = BrutalistTheme.white;
      shadows = [
        BoxShadow(
          color: BrutalistTheme.accent.withValues(alpha: 0.32),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];
    }
    // Outer Stack so the matched-checkmark badge can sit on the tile's
    // corner — inside the Container it was being clipped + centered, which
    // is why it looked off.
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: opacity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: matched ? null : onTap,
              borderRadius: BorderRadius.circular(16),
              splashColor: BrutalistTheme.accent.withValues(alpha: 0.15),
              highlightColor: BrutalistTheme.accent.withValues(alpha: 0.05),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: border, width: selected ? 2 : 1.5),
                  boxShadow: shadows,
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            emphasised ? FontWeight.w800 : FontWeight.w600,
                        color: textColor,
                        fontSize: emphasised ? 18 : 14,
                        height: 1.2,
                        letterSpacing: emphasised ? 0.2 : 0,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (matched)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                decoration: BoxDecoration(
                  color: BrutalistTheme.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BrutalistTheme.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: BrutalistTheme.primary,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
