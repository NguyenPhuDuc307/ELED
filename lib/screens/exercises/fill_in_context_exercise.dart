import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../models/vocabulary.dart';
import '../../models/word_state.dart';
import '../../services/oxford_service.dart';
import '../../theme/brutalist_theme.dart';
import '../../widgets/slot_answer_field.dart';

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
  bool _hintShown = false;

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
    // Custom words have no Oxford URL — go straight to the meaning-prompt
    // fallback so the card doesn't have to round-trip through a network call.
    if (widget.word.url.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    final senses = await OxfordService.fetchDefinitions(
        widget.word.word, widget.word.url);
    if (!mounted) return;
    final goodSense = senses.firstWhere(
      (s) => s.example.trim().isNotEmpty &&
          _containsWordIgnoringCase(s.example, widget.word.word),
      orElse: () => senses.firstWhere((s) => s.example.trim().isNotEmpty,
          orElse: () => const OxfordSense(number: 0, definition: '', example: '')),
    );
    setState(() {
      if (goodSense.example.isNotEmpty) {
        _sentence = goodSense.example;
        _redactedDisplay = _redact(goodSense.example, widget.word.word);
      }
      // No example → leave _sentence null; the build method renders the
      // meaning-prompt fallback instead of silently skipping the card.
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

  /// Drops case, punctuation and whitespace — slot input never contains
  /// spaces so multi-word answers still match.
  String _normalise(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r"['\-‘’]"), '')
      .replaceAll(RegExp(r'\s+'), '');

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
    final hasSentence = _redactedDisplay != null;
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
            hasSentence ? t.exerciseFillInBlank : t.exerciseTypeEnglishFor,
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
              hasSentence
                  ? (_redactedDisplay ?? '')
                  : widget.word.translation,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: BrutalistTheme.primary,
                    height: 1.4,
                    fontSize: 20,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          if (hasSentence && widget.word.translation.isNotEmpty) ...[
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
              widget.word.word,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: BrutalistTheme.primary,
                    fontSize: 20,
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
