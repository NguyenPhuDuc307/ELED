import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../models/vocabulary.dart';
import '../../models/word_state.dart';
import '../../services/oxford_service.dart';
import '../../theme/brutalist_theme.dart';

/// Active-recall by context: a real Oxford example sentence with the target
/// word redacted to "______". User types the missing word. Lenient match.
/// Falls back to skipping the card silently if no usable example exists.
class FillInContextExercise extends StatefulWidget {
  final Vocabulary word;
  final Future<void> Function(ReviewRating rating) onAnswered;

  const FillInContextExercise({
    super.key,
    required this.word,
    required this.onAnswered,
  });

  @override
  State<FillInContextExercise> createState() => _FillInContextExerciseState();
}

class _FillInContextExerciseState extends State<FillInContextExercise> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _sentence;        // raw example with target word still present
  String? _redactedDisplay; // user-visible sentence with "______"
  bool _loading = true;
  bool? _correctness;

  @override
  void initState() {
    super.initState();
    _loadExample();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadExample() async {
    final senses = await OxfordService.fetchDefinitions(
        widget.word.word, widget.word.url);
    if (!mounted) return;
    final goodSense = senses.firstWhere(
      (s) => s.example.trim().isNotEmpty &&
          _containsWordIgnoringCase(s.example, widget.word.word),
      orElse: () => senses.firstWhere((s) => s.example.trim().isNotEmpty,
          orElse: () => const OxfordSense(number: 0, definition: '', example: '')),
    );
    if (goodSense.example.isEmpty) {
      // No usable example — skip this card so the session continues.
      await widget.onAnswered(ReviewRating.again);
      return;
    }
    setState(() {
      _sentence = goodSense.example;
      _redactedDisplay = _redact(goodSense.example, widget.word.word);
      _loading = false;
    });
  }

  static bool _containsWordIgnoringCase(String haystack, String needle) {
    final pattern = RegExp('\\b${RegExp.escape(needle)}\\b', caseSensitive: false);
    return pattern.hasMatch(haystack);
  }

  static String _redact(String sentence, String word) {
    // Replace the target word (word-boundary, case-insensitive) with a fixed
    // blank, regardless of capitalisation in the original sentence.
    final pattern = RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false);
    return sentence.replaceAll(pattern, '______');
  }

  String _normalise(String s) => s
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r"['\-‘’]"), '')
      .replaceAll(RegExp(r'\s+'), ' ');

  Future<void> _submit() async {
    if (_correctness != null) return;
    final typed = _controller.text;
    if (typed.trim().isEmpty) return;
    final correct = _normalise(typed) == _normalise(widget.word.word);
    setState(() => _correctness = correct);
    await Future.delayed(const Duration(milliseconds: 1200));
    await widget.onAnswered(correct ? ReviewRating.good : ReviewRating.again);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: context.bBorder, strokeWidth: 4),
      );
    }
    final showAnswer = _correctness != null;
    // Same compaction strategy as ListenAndType: shrink top spacing when the
    // keyboard is up so the action buttons stay reachable on small screens.
    final compact = MediaQuery.of(context).viewInsets.bottom > 0;
    return SingleChildScrollView(
      reverse: true,
      padding: EdgeInsets.fromLTRB(24, compact ? 12 : 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.exerciseFillInBlank,
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
              _redactedDisplay ?? '',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: BrutalistTheme.primary,
                    height: 1.4,
                    fontSize: 20,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          if (widget.word.translation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              widget.word.translation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.bMuted,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
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
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: showAnswer
                      ? (_correctness == true
                          ? BrutalistTheme.primary
                          : const Color(0xFFD9534F))
                      : context.bBorder,
                ),
            decoration: InputDecoration(
              hintText: t.exerciseMissingWord,
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.bMuted,
                    fontSize: 17,
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
                borderSide: const BorderSide(color: BrutalistTheme.primary, width: 2),
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
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          // Use the raw sentence below as a hint after revealing the answer,
          // so the user can re-read it with the word in place.
          if (showAnswer && _sentence != null) ...[
            const SizedBox(height: 16),
            Text(
              _sentence!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.bMuted,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
