import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/word_state.dart';
import '../services/quiz_pref_service.dart';
import '../theme/brutalist_theme.dart';

/// Shows the quiz exercise-type picker as a modal bottom sheet. Resolves to
/// the selected set when the user taps Start, or `null` if dismissed.
/// Persists the chosen set via [QuizPrefService] so the next launch starts
/// with it pre-selected.
Future<Set<ExerciseType>?> showQuizPickerSheet(BuildContext context) async {
  final initial = await QuizPrefService.load();
  if (!context.mounted) return null;
  return showModalBottomSheet<Set<ExerciseType>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _QuizPickerSheet(initial: initial),
  );
}

class _QuizPickerSheet extends StatefulWidget {
  final Set<ExerciseType> initial;
  const _QuizPickerSheet({required this.initial});

  @override
  State<_QuizPickerSheet> createState() => _QuizPickerSheetState();
}

class _QuizPickerSheetState extends State<_QuizPickerSheet> {
  late final Set<ExerciseType> _selected = {...widget.initial};

  void _toggle(ExerciseType type) {
    setState(() {
      if (_selected.contains(type)) {
        _selected.remove(type);
      } else {
        _selected.add(type);
      }
    });
  }

  void _toggleAll() {
    setState(() {
      if (_selected.length == QuizPrefService.allTypes.length) {
        _selected
          ..clear()
          ..add(QuizPrefService.allTypes.first);
      } else {
        _selected
          ..clear()
          ..addAll(QuizPrefService.allTypes);
      }
    });
  }

  Future<void> _start() async {
    if (_selected.isEmpty) return;
    await QuizPrefService.save(_selected);
    if (!mounted) return;
    Navigator.of(context).pop(_selected);
  }

  String _labelFor(AppLocalizations t, ExerciseType type) {
    switch (type) {
      case ExerciseType.multipleChoice:
        return t.exerciseLabelMultipleChoice;
      case ExerciseType.listenAndType:
        return t.exerciseLabelListenAndType;
      case ExerciseType.fillInContext:
        return t.exerciseLabelFillInContext;
      case ExerciseType.anagram:
        return t.exerciseLabelAnagram;
      case ExerciseType.reverseTyping:
        return t.exerciseLabelReverseTyping;
      case ExerciseType.recognize:
        return '';
    }
  }

  IconData _iconFor(ExerciseType type) {
    switch (type) {
      case ExerciseType.multipleChoice:
        return Icons.checklist_rounded;
      case ExerciseType.listenAndType:
        return Icons.headphones_rounded;
      case ExerciseType.fillInContext:
        return Icons.short_text_rounded;
      case ExerciseType.anagram:
        return Icons.shuffle_rounded;
      case ExerciseType.reverseTyping:
        return Icons.translate_rounded;
      case ExerciseType.recognize:
        return Icons.style_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final allSelected = _selected.length == QuizPrefService.allTypes.length;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.bSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.quizPickerTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: _toggleAll,
                    style: TextButton.styleFrom(
                      foregroundColor: BrutalistTheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(
                      t.quizPickerSelectAll,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: allSelected ? TextDecoration.underline : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(
                t.quizPickerSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.bMuted,
                    ),
              ),
            ),
            ...QuizPrefService.allTypes.map((type) {
              final isOn = _selected.contains(type);
              return InkWell(
                onTap: () => _toggle(type),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isOn
                              ? BrutalistTheme.primaryLight
                              : context.bSubtle.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _iconFor(type),
                          color: isOn ? BrutalistTheme.primary : context.bMuted,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _labelFor(t, type),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Checkbox(
                        value: isOn,
                        onChanged: (_) => _toggle(type),
                        activeColor: BrutalistTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: FilledButton(
                onPressed: _selected.isEmpty ? null : _start,
                style: FilledButton.styleFrom(
                  backgroundColor: BrutalistTheme.primary,
                  foregroundColor: BrutalistTheme.white,
                  disabledBackgroundColor: context.bSubtle,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  t.quizPickerStart,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
