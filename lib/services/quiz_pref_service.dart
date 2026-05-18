import 'package:shared_preferences/shared_preferences.dart';

import '../models/word_state.dart';

/// Persists which quiz exercise types the user opted into. Default is the
/// full six-style rotation; the picker sheet writes back whatever the user
/// last confirmed so subsequent Quiz launches start with that as the default.
///
/// Recognize is intentionally excluded — quiz mode never falls back to a
/// flashcard.
class QuizPrefService {
  static const _prefsKey = 'quizSelectedTypes';

  static const allTypes = <ExerciseType>[
    ExerciseType.multipleChoice,
    ExerciseType.listenAndType,
    ExerciseType.fillInContext,
    ExerciseType.anagram,
    ExerciseType.reverseTyping,
  ];

  static Future<Set<ExerciseType>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey);
    if (saved == null || saved.isEmpty) return allTypes.toSet();
    final picked = <ExerciseType>{};
    for (final name in saved) {
      for (final t in allTypes) {
        if (t.name == name) {
          picked.add(t);
          break;
        }
      }
    }
    return picked.isEmpty ? allTypes.toSet() : picked;
  }

  static Future<void> save(Set<ExerciseType> types) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      types.map((t) => t.name).toList(),
    );
  }
}
