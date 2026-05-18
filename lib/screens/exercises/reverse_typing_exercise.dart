import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../models/vocabulary.dart';
import '../../models/word_state.dart';
import '../../theme/brutalist_theme.dart';

/// Reverse direction: show the English word, the user types the Vietnamese
/// meaning. Tests passive → active recall. Match is lenient and accepts any
/// of the synonyms the CSV stores separated by ";" / "," (e.g. "vui; hạnh
/// phúc").
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

  String _normalise(String s) => s
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[̀-ͯ]'), '') // strip diacritics-ish
      .replaceAll(RegExp(r"['\-‘’]"), '')
      .replaceAll(RegExp(r'\s+'), ' ');

  /// True when the typed answer matches any of the comma/semicolon-separated
  /// translation synonyms after light normalisation.
  bool _isCorrect(String typed) {
    final t = _normalise(typed);
    if (t.isEmpty) return false;
    final candidates = widget.word.translation
        .split(RegExp(r'[;,]'))
        .map(_normalise)
        .where((s) => s.isNotEmpty);
    return candidates.contains(t);
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
              widget.word.word,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: BrutalistTheme.primary,
                    height: 1.2,
                    fontSize: 32,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !showAnswer,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.none,
            textAlign: TextAlign.center,
            autofocus: true,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\n')),
            ],
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: showAnswer
                      ? (_correctness == true
                          ? BrutalistTheme.primary
                          : const Color(0xFFD9534F))
                      : context.bBorder,
                ),
            decoration: InputDecoration(
              hintText: t.exerciseReverseTypingHint,
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.bMuted,
                    fontSize: 16,
                  ),
              filled: true,
              fillColor: context.bBg,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: context.bSubtle, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: BrutalistTheme.primary, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: _correctness == true
                      ? BrutalistTheme.primary
                      : const Color(0xFFD9534F),
                  width: 2,
                ),
              ),
            ),
            onSubmitted: (_) => _submit(),
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
