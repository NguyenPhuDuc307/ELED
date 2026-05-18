import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../models/vocabulary.dart';
import '../../models/word_state.dart';
import '../../theme/brutalist_theme.dart';

/// Tap the scrambled letters in the right order to spell the target word.
/// The user sees the Vietnamese meaning above and a pile of shuffled tiles
/// below. Auto-rates Good when the word is complete + correct, Again on
/// Skip. No backend dependency — works on every word, including custom.
class AnagramExercise extends StatefulWidget {
  final Vocabulary word;
  final Future<void> Function(ReviewRating rating) onAnswered;

  const AnagramExercise({
    super.key,
    required this.word,
    required this.onAnswered,
  });

  @override
  State<AnagramExercise> createState() => _AnagramExerciseState();
}

class _AnagramExerciseState extends State<AnagramExercise> {
  /// Available letters with their original positions. We track index so two
  /// identical letters (e.g. "letter" → two e's) can be told apart.
  late List<_LetterTile> _tiles;

  /// Indexes into [_tiles] in the order the user tapped them.
  final List<int> _picked = [];

  bool? _correctness;

  @override
  void initState() {
    super.initState();
    _seedTiles();
  }

  void _seedTiles() {
    final lower = widget.word.word.toLowerCase();
    final indexed = <_LetterTile>[
      for (var i = 0; i < lower.length; i++)
        _LetterTile(letter: lower[i], originalIndex: i),
    ];
    final rng = Random(widget.word.word.hashCode);
    indexed.shuffle(rng);
    // Guard against the (rare) case where the shuffle returns the original
    // order — would feel like the exercise was already solved.
    if (indexed.length > 1 &&
        List.generate(indexed.length, (i) => indexed[i].originalIndex == i)
            .every((b) => b)) {
      indexed.add(indexed.removeAt(0));
    }
    _tiles = indexed;
  }

  String get _typed => [for (final i in _picked) _tiles[i].letter].join();

  bool get _full => _picked.length == _tiles.length;

  void _pick(int idx) {
    if (_correctness != null) return;
    if (_picked.contains(idx)) return;
    setState(() {
      _picked.add(idx);
    });
    if (_full) _evaluate();
  }

  void _undoLast() {
    if (_correctness != null) return;
    if (_picked.isEmpty) return;
    setState(() => _picked.removeLast());
  }

  Future<void> _evaluate() async {
    final correct = _typed == widget.word.word.toLowerCase();
    setState(() => _correctness = correct);
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    await widget.onAnswered(correct ? ReviewRating.good : ReviewRating.again);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final showAnswer = _correctness != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.exerciseAnagramTitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.bMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: BrutalistTheme.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.word.translation,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: BrutalistTheme.primary,
                    height: 1.4,
                    fontSize: 20,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          _slotsRow(showAnswer),
          const SizedBox(height: 20),
          _tilesGrid(showAnswer),
          const SizedBox(height: 18),
          if (showAnswer && _correctness == false) ...[
            Text(
              widget.word.word,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: BrutalistTheme.primary,
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 12),
          ],
          if (!showAnswer)
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => widget.onAnswered(ReviewRating.again),
                    style: TextButton.styleFrom(
                      foregroundColor: context.bMuted,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(t.exerciseSkip,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton.icon(
                    onPressed: _picked.isEmpty ? null : _undoLast,
                    style: TextButton.styleFrom(
                      foregroundColor: context.bBorder,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.backspace_outlined, size: 18),
                    label: Text(t.exerciseAnagramClear,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// One slot per letter of the answer. Filled in order as the user picks
  /// tiles; empty slots show an underline placeholder.
  Widget _slotsRow(bool showAnswer) {
    final correct = _correctness == true;
    final wrong = _correctness == false;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < _tiles.length; i++)
          _slot(
            letter: i < _picked.length ? _tiles[_picked[i]].letter : null,
            correct: correct,
            wrong: wrong,
          ),
      ],
    );
  }

  Widget _slot({String? letter, required bool correct, required bool wrong}) {
    Color border = context.bSubtle;
    Color fg = context.bBorder;
    if (correct) {
      border = BrutalistTheme.primary;
      fg = BrutalistTheme.primary;
    } else if (wrong) {
      border = const Color(0xFFD9534F);
      fg = const Color(0xFFD9534F);
    } else if (letter != null) {
      border = BrutalistTheme.accent;
      fg = BrutalistTheme.accent;
    }
    return Container(
      width: 32,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 2)),
      ),
      child: Text(
        letter ?? '',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: fg,
              fontSize: 22,
            ),
      ),
    );
  }

  Widget _tilesGrid(bool showAnswer) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < _tiles.length; i++)
          _tileButton(i, showAnswer),
      ],
    );
  }

  Widget _tileButton(int idx, bool showAnswer) {
    final used = _picked.contains(idx);
    return Opacity(
      opacity: used ? 0.25 : 1.0,
      child: Material(
        color: used ? context.bBg : BrutalistTheme.accentLight,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: used || showAnswer ? null : () => _pick(idx),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: used ? context.bSubtle : BrutalistTheme.accent,
                width: 1.5,
              ),
            ),
            child: Text(
              _tiles[idx].letter,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: used ? context.bMuted : BrutalistTheme.accent,
                    fontSize: 22,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LetterTile {
  final String letter;
  final int originalIndex;
  const _LetterTile({required this.letter, required this.originalIndex});
}
