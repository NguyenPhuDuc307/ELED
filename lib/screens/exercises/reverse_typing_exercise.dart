import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../models/vocabulary.dart';
import '../../models/word_state.dart';
import '../../theme/brutalist_theme.dart';
import '../../widgets/slot_answer_field.dart';

/// Reverse direction: show the Vietnamese meaning, the user types the English
/// word. Tests passive → active recall. Match is lenient on case + stray
/// punctuation, mirroring the listen-and-type rules.
class ReverseTypingExercise extends StatefulWidget {
  final Vocabulary word;
  final Future<void> Function(ReviewRating rating) onAnswered;

  const ReverseTypingExercise({
    super.key,
    required this.word,
    required this.onAnswered,
  });

  @override
  State<ReverseTypingExercise> createState() => _ReverseTypingExerciseState();
}

class _ReverseTypingExerciseState extends State<ReverseTypingExercise> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool? _correctness;
  bool _hintShown = false;

  /// Drops case, punctuation and whitespace so the slot input ("givebirth")
  /// matches a multi-word answer ("give birth").
  String _normalise(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r"['\-‘’]"), '')
      .replaceAll(RegExp(r'\s+'), '');

  /// User sees the Vietnamese meaning, types the English word. Match is
  /// lenient on case + stray punctuation, mirroring the listen-and-type
  /// rules so a missing apostrophe doesn't count as wrong.
  bool _isCorrect(String typed) {
    final t = _normalise(typed);
    if (t.isEmpty) return false;
    return t == _normalise(widget.word.word);
  }

  Widget _hintRow(AppLocalizations t) {
    final firstLetter = widget.word.word.isEmpty ? '' : widget.word.word[0];
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: _hintShown
            ? Text(
                t.exerciseHintStartsWith(firstLetter),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BrutalistTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              )
            : TextButton.icon(
                onPressed: () => setState(() => _hintShown = true),
                icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
                label: Text(t.exerciseHint),
                style: TextButton.styleFrom(
                  foregroundColor: BrutalistTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_correctness != null) return;
    final typed = _controller.text;
    if (typed.trim().isEmpty) return;
    final correct = _isCorrect(typed);
    setState(() => _correctness = correct);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    await widget.onAnswered(correct ? ReviewRating.good : ReviewRating.again);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final showAnswer = _correctness != null;
    final compact = MediaQuery.of(context).viewInsets.bottom > 0;
    return SingleChildScrollView(
      reverse: true,
      padding: EdgeInsets.fromLTRB(24, compact ? 12 : 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.exerciseReverseTypingTitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.bMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: compact ? 14 : 28),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: BrutalistTheme.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.word.translation,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: BrutalistTheme.primary,
                    height: 1.3,
                    fontSize: 22,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 22),
          SlotAnswerField(
            template: widget.word.word,
            controller: _controller,
            focusNode: _focusNode,
            enabled: !showAnswer,
            correctness: _correctness,
            onSubmit: _submit,
          ),
          if (showAnswer && _correctness == false) ...[
            const SizedBox(height: 12),
            Text(
              widget.word.translation,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: BrutalistTheme.primary,
                    fontSize: 18,
                  ),
            ),
          ],
          if (!showAnswer) _hintRow(t),
          const SizedBox(height: 18),
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
                  flex: 2,
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: BrutalistTheme.primary,
                      foregroundColor: BrutalistTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(t.exerciseCheck,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
