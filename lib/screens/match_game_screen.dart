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

/// A 4-pair matching game. Words on the left column, shuffled translations
/// on the right. Tap a word, then its translation. Correct pairs fade out
/// in green; wrong picks flash red. When all 4 pairs are matched the user
/// is auto-rated per-word and the standard results screen takes over.
///
/// Auto-rating per word:
/// - Matched on the first attempt → ReviewRating.good
/// - Matched after one wrong pairing → ReviewRating.hard
/// - Matched after two+ wrong pairings → ReviewRating.again
class MatchGameScreen extends StatefulWidget {
  /// Pool of vocab to draw 4 pairs from. The screen will refuse to start with
  /// fewer than 4 entries.
  final List<Vocabulary> pool;

  const MatchGameScreen({super.key, required this.pool});

  @override
  State<MatchGameScreen> createState() => _MatchGameScreenState();
}

class _MatchGameScreenState extends State<MatchGameScreen> {
  static const _pairCount = 4;

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
    _pairs = source.take(_pairCount).toList();
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
    setState(() {
      _selectedWordIdx = _selectedWordIdx == i ? null : i;
      _selectedTransIdx = null;
    });
  }

  Future<void> _pickTranslation(int j) async {
    if (_completed) return;
    final translationWord = _shuffledTranslations[j];
    final alreadyMatched = _matchedWordIdx.any((i) => _pairs[i].word == translationWord.word);
    if (alreadyMatched || _wrongTransIdx != null) return;

    final wordIdx = _selectedWordIdx;
    if (wordIdx == null) {
      // No word selected — flash and prompt.
      setState(() {
        _selectedTransIdx = j;
      });
      return;
    }

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
        _wrongTransIdx = j;
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            children: [
              _progressDots(t),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildColumn(words: true)),
                    const SizedBox(width: 10),
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

  Widget _progressDots(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(_pairs.length, (i) {
              final done = _matchedWordIdx.contains(i);
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: done ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: done
                        ? BrutalistTheme.primary
                        : context.bSubtle,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          Text(
            t.matchGameProgress(_matchedWordIdx.length, _pairs.length),
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

  Widget _buildColumn({required bool words}) {
    return Column(
      children: List.generate(_pairs.length, (i) {
        final isLast = i == _pairs.length - 1;
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
    Color bg = context.bBg;
    Color border = context.bSubtle;
    Color textColor = context.bBorder;
    double opacity = 1.0;
    if (matched) {
      bg = BrutalistTheme.primaryLight;
      border = BrutalistTheme.primary;
      textColor = BrutalistTheme.primary;
      opacity = 0.55;
    } else if (wrong) {
      bg = const Color(0xFFFADBD8);
      border = const Color(0xFFD9534F);
      textColor = const Color(0xFFD9534F);
    } else if (selected) {
      bg = BrutalistTheme.accentLight;
      border = BrutalistTheme.accent;
      textColor = BrutalistTheme.accent;
    }
    return Opacity(
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: matched ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
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
      ),
    );
  }
}
