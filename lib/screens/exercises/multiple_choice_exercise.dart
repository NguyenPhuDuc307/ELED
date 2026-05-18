import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../models/vocabulary.dart';
import '../../models/word_state.dart';
import '../../theme/brutalist_theme.dart';
import '../../widgets/brutalist_card.dart';

/// Multiple-choice quiz: shows the target word + 4 translation options.
/// Tapping a wrong option highlights both the wrong choice (red) and the
/// correct one (green) for ~1.2s before bubbling the result up via
/// [onAnswered] so the parent session can rate + advance.
class MultipleChoiceExercise extends StatefulWidget {
  final Vocabulary word;

  /// 3 other words sourced from the same session — their translations are
  /// the distractors. Picked by the parent so distractor quality stays
  /// consistent across the session.
  final List<Vocabulary> distractors;

  final Future<void> Function(ReviewRating rating) onAnswered;

  const MultipleChoiceExercise({
    super.key,
    required this.word,
    required this.distractors,
    required this.onAnswered,
  });

  @override
  State<MultipleChoiceExercise> createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise> {
  late final List<String> _options;
  late final int _correctIndex;
  int? _picked;
  final Set<int> _eliminated = {};

  @override
  void initState() {
    super.initState();
    final correct = widget.word.translation.trim();
    final pool = widget.distractors
        .map((v) => v.translation.trim())
        .where((t) => t.isNotEmpty && t.toLowerCase() != correct.toLowerCase())
        .toSet()
        .toList();
    pool.shuffle();
    final picks = pool.take(3).toList();
    while (picks.length < 3) {
      picks.add('—');
    }
    final all = [...picks, correct]..shuffle();
    _options = all;
    _correctIndex = all.indexOf(correct);
  }

  Future<void> _pick(int index) async {
    if (_picked != null) return;
    if (_eliminated.contains(index)) return;
    setState(() => _picked = index);
    final correct = index == _correctIndex;
    // Brief pause so the user sees the right/wrong highlight before the
    // session yanks the page away.
    await Future.delayed(const Duration(milliseconds: 1100));
    await widget.onAnswered(correct ? ReviewRating.good : ReviewRating.again);
  }

  /// 50/50: eliminate one wrong option. Picks the first non-correct,
  /// non-already-eliminated option so the helper is deterministic per card.
  void _useHint() {
    if (_picked != null) return;
    for (var i = 0; i < _options.length; i++) {
      if (i == _correctIndex) continue;
      if (_eliminated.contains(i)) continue;
      setState(() => _eliminated.add(i));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          BrutalistCard(
            backgroundColor: levelColor(widget.word.levels, fallbackIndex: 0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
              child: Column(
                children: [
                  Text(
                    t.exerciseWhatDoesItMean,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: BrutalistTheme.black.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.word.word,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: BrutalistTheme.black,
                          ),
                    ),
                  ),
                  if (widget.word.ipa.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.word.ipa,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: BrutalistTheme.black.withValues(alpha: 0.55),
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: _options.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _optionTile(i),
            ),
          ),
          if (_picked == null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                // Disabled once all wrong options are eliminated — nothing
                // useful left for the hint to do.
                onPressed: _eliminated.length >= _options.length - 1
                    ? null
                    : _useHint,
                icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
                label: Text(t.exerciseHint),
                style: TextButton.styleFrom(
                  foregroundColor: BrutalistTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _optionTile(int i) {
    final isPickedCorrect = _picked == _correctIndex && _picked == i;
    final isPickedWrong = _picked != null && _picked == i && _picked != _correctIndex;
    final isRevealedCorrect = _picked != null && _picked != _correctIndex && i == _correctIndex;
    final isEliminated = _picked == null && _eliminated.contains(i);

    Color bg = context.bBg;
    Color border = context.bSubtle;
    Color textColor = context.bBorder;

    if (isPickedCorrect || isRevealedCorrect) {
      bg = BrutalistTheme.primaryLight;
      border = BrutalistTheme.primary;
      textColor = BrutalistTheme.primary;
    } else if (isPickedWrong) {
      bg = const Color(0xFFFADBD8);
      border = const Color(0xFFD9534F);
      textColor = const Color(0xFFD9534F);
    }

    return Opacity(
      opacity: isEliminated ? 0.35 : 1.0,
      child: InkWell(
        onTap: (_picked == null && !isEliminated) ? () => _pick(i) : null,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _options[i],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        fontSize: 16,
                        decoration: isEliminated
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                ),
              ),
              if (isPickedCorrect || isRevealedCorrect)
                const Icon(Icons.check_rounded, color: BrutalistTheme.primary, size: 22),
              if (isPickedWrong)
                const Icon(Icons.close_rounded, color: Color(0xFFD9534F), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
