import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../models/vocabulary.dart';
import '../../models/word_state.dart';
import '../../theme/brutalist_theme.dart';

/// Active-recall lite: shows the meaning + first letter of the word, user
/// types the rest. Easier than fill-in (gets a hint) and never needs a
/// network call — works on every word, custom or bundled.
class FirstLetterExercise extends StatefulWidget {
  final Vocabulary word;
  final Future<void> Function(ReviewRating rating) onAnswered;

  const FirstLetterExercise({
    super.key,
    required this.word,
    required this.onAnswered,
  });

  @override
  State<FirstLetterExercise> createState() => _FirstLetterExerciseState();
}

class _FirstLetterExerciseState extends State<FirstLetterExercise> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool? _correctness;

  String get _firstLetter =>
      widget.word.word.isEmpty ? '' : widget.word.word[0].toUpperCase();

  String _normalise(String s) => s
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r"['\-‘’]"), '')
      .replaceAll(RegExp(r'\s+'), ' ');

  /// Accepts either the full word or just the tail. So if the answer is
  /// "abandon", typing "bandon" or "abandon" both work.
  bool _isCorrect(String typed) {
    final tgt = _normalise(widget.word.word);
    final t = _normalise(typed);
    if (t.isEmpty) return false;
    if (t == tgt) return true;
    final tail = tgt.length > 1 ? tgt.substring(1) : '';
    return t == tail;
  }

  Future<void> _submit() async {
    if (_correctness != null) return;
    final typed = _controller.text;
    if (typed.trim().isEmpty) return;
    final correct = _isCorrect(typed);
    setState(() => _correctness = correct);
    await Future.delayed(const Duration(milliseconds: 1100));
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
            t.exerciseFirstLetterTitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.bMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: compact ? 14 : 28),
          Container(
            padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: BrutalistTheme.accentLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _firstLetter,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: BrutalistTheme.accent,
                      ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !showAnswer,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.none,
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
                    hintText: '_____',
                    hintStyle: TextStyle(color: context.bMuted, fontSize: 22),
                    filled: true,
                    fillColor: context.bBg,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.bSubtle, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: BrutalistTheme.primary, width: 2),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
              ),
            ],
          ),
          if (showAnswer && _correctness == false) ...[
            const SizedBox(height: 12),
            Text(
              widget.word.word,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: BrutalistTheme.primary,
                    fontSize: 20,
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
