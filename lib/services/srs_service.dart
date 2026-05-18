import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vocabulary.dart';
import '../models/word_state.dart';
import '../utils/log.dart';
import 'csv_service.dart';
import 'user_data_service.dart';

/// Manages each word's spaced-repetition state. Implements an SM-2 variant:
/// each rating updates the interval (days until next review) and an ease
/// factor (multiplier for the next interval). Stored as a single JSON map
/// in SharedPreferences keyed by `srsStates`.
///
/// Sized for ~5000 vocab; only words the user has touched have entries.
class SrsService {
  static final SrsService _instance = SrsService._internal();
  factory SrsService() => _instance;
  SrsService._internal();

  static const _kStatesKey = 'srsStates';
  static const _kMigratedKey = 'srsKnownWordsMigrated';

  static const _minEase = 1.3;
  static const _maxEase = 3.0;
  static const _newCardsPerSession = 10;
  static const _maxSessionSize = 20;

  final _ready = Completer<void>();
  final Map<String, WordState> _states = {};
  final _changeCtrl = StreamController<void>.broadcast();
  Stream<void> get changes => _changeCtrl.stream;

  bool _loaded = false;
  Future<void> get ready => _ready.future;

  // ── Lifecycle ──────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStatesKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          _states[entry.key] = WordState.fromJson(
            (entry.value as Map<String, dynamic>),
          );
        }
      }
      await _migrateKnownWordsIfNeeded(prefs);
    } catch (e, st) {
      logCaught(e, st, 'SrsService.init');
    } finally {
      _loaded = true;
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  /// One-time migration: every word currently in `UserDataService.knownWords`
  /// becomes a `reviewing` card due in 7 days. That way SRS surfaces them
  /// soon enough to verify retention without acting like every "known" word
  /// is brand new.
  Future<void> _migrateKnownWordsIfNeeded(SharedPreferences prefs) async {
    if (prefs.getBool(_kMigratedKey) == true) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final due = now + 7 * 24 * 60 * 60 * 1000;
    for (final w in UserDataService().knownWords) {
      final key = w.toLowerCase();
      if (_states.containsKey(key)) continue;
      _states[key] = WordState(
        word: key,
        stage: SrsStage.reviewing,
        easeFactor: 2.5,
        intervalDays: 7,
        repetitions: 2,
        dueAtMs: due,
        lastReviewedMs: now,
        totalSeen: 1,
        totalLapses: 0,
      );
    }
    await _persist(prefs);
    await prefs.setBool(_kMigratedKey, true);
  }

  Future<void> _persist([SharedPreferences? prefs]) async {
    try {
      prefs ??= await SharedPreferences.getInstance();
      final map = <String, dynamic>{};
      _states.forEach((k, v) => map[k] = v.toJson());
      await prefs.setString(_kStatesKey, jsonEncode(map));
      if (!_changeCtrl.isClosed) _changeCtrl.add(null);
    } catch (e, st) {
      logCaught(e, st, 'SrsService._persist');
    }
  }

  // ── Queries ────────────────────────────────────────────────────────────

  WordState stateFor(String word) =>
      _states[word.toLowerCase()] ?? WordState.fresh(word);

  Iterable<WordState> get all => _states.values;

  /// All currently due word states. Sorted by how overdue they are.
  /// Words the user has explicitly marked as known are filtered out so
  /// the count matches the session that will actually be built.
  List<WordState> dueStates() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final known = UserDataService().knownWords;
    final due = _states.values
        .where((s) => s.dueAtMs > 0 && s.dueAtMs <= now)
        .where((s) => !known.contains(s.word))
        .toList();
    due.sort((a, b) => a.dueAtMs.compareTo(b.dueAtMs));
    return due;
  }

  /// Number of reviews waiting today.
  int dueCount() => dueStates().length;

  /// Words the user has never rated. Pulled from the bundled vocabulary so
  /// the count reflects what's actually available, not whatever was
  /// historically seen.
  Future<List<Vocabulary>> freshPool({
    List<String>? levelFilter,
    int limit = 50,
  }) async {
    final all = await CsvService.loadAllVocabulary(excludeKnown: false);
    final known = UserDataService().knownWords;
    final result = <Vocabulary>[];
    for (final v in all) {
      final key = v.word.toLowerCase();
      if (_states.containsKey(key)) continue;
      if (known.contains(key)) continue;
      if (levelFilter != null && levelFilter.isNotEmpty) {
        final vLevel = v.levels.toUpperCase();
        if (!levelFilter.any((l) => vLevel.contains(l.toUpperCase()))) continue;
      }
      result.add(v);
      if (result.length >= limit) break;
    }
    return result;
  }

  /// Builds today's session: every due card + up to [_newCardsPerSession]
  /// fresh words, capped at [_maxSessionSize] total. Anything the user has
  /// explicitly marked as known via the toolbar ✓ is skipped entirely —
  /// known is treated as a permanent exclusion, not just a "review less
  /// often" hint.
  Future<List<Vocabulary>> buildTodaySession({
    List<String>? levelFilter,
  }) async {
    await ready;
    final all = await CsvService.loadAllVocabulary(excludeKnown: false);
    final byKey = {for (final v in all) v.word.toLowerCase(): v};
    final known = UserDataService().knownWords;

    final dueWords = <Vocabulary>[];
    for (final s in dueStates()) {
      if (known.contains(s.word)) continue;
      final v = byKey[s.word];
      if (v != null) dueWords.add(v);
      if (dueWords.length >= _maxSessionSize) break;
    }

    final remaining = _maxSessionSize - dueWords.length;
    final newWordBudget = min(_newCardsPerSession, remaining);
    final fresh = newWordBudget <= 0
        ? <Vocabulary>[]
        : await freshPool(levelFilter: levelFilter, limit: newWordBudget);

    return [...dueWords, ...fresh];
  }

  // ── Rating ─────────────────────────────────────────────────────────────

  /// Applies a user rating to [word]. Updates ease, interval, due-date, and
  /// stage according to a lightweight SM-2 schedule, then persists.
  Future<void> submitReview(String word, ReviewRating rating) async {
    await ready;
    final key = word.toLowerCase();
    final prev = _states[key] ?? WordState.fresh(word);

    final next = _applyReview(prev, rating);
    _states[key] = next;
    await _persist();
  }

  WordState _applyReview(WordState prev, ReviewRating rating) {
    final now = DateTime.now().millisecondsSinceEpoch;
    double ease = prev.easeFactor;
    int interval = prev.intervalDays;
    int repetitions = prev.repetitions;
    int lapses = prev.totalLapses;
    SrsStage stage = prev.stage;

    switch (rating) {
      case ReviewRating.again:
        ease = (ease - 0.2).clamp(_minEase, _maxEase);
        interval = 1;
        repetitions = 0;
        stage = SrsStage.learning;
        if (prev.stage == SrsStage.reviewing || prev.stage == SrsStage.mastered) {
          lapses += 1;
        }
        break;
      case ReviewRating.hard:
        ease = (ease - 0.15).clamp(_minEase, _maxEase);
        interval = max(1, (interval * 1.2).round());
        repetitions += 1;
        stage = repetitions >= 2 ? SrsStage.reviewing : SrsStage.learning;
        break;
      case ReviewRating.good:
        if (repetitions == 0) {
          interval = 1;
        } else if (repetitions == 1) {
          interval = 4;
        } else {
          interval = max(1, (interval * ease).round());
        }
        repetitions += 1;
        stage = _stageForInterval(interval);
        break;
      case ReviewRating.easy:
        ease = (ease + 0.15).clamp(_minEase, _maxEase);
        if (repetitions == 0) {
          interval = 4;
        } else {
          interval = max(1, (interval * ease * 1.3).round());
        }
        repetitions += 1;
        stage = _stageForInterval(interval);
        break;
    }

    final dueAt = now + interval * 24 * 60 * 60 * 1000;
    return prev.copyWith(
      stage: stage,
      easeFactor: ease,
      intervalDays: interval,
      repetitions: repetitions,
      dueAtMs: dueAt,
      lastReviewedMs: now,
      totalSeen: prev.totalSeen + 1,
      totalLapses: lapses,
    );
  }

  SrsStage _stageForInterval(int interval) {
    if (interval >= 60) return SrsStage.mastered;
    if (interval >= 4) return SrsStage.reviewing;
    return SrsStage.learning;
  }

  // ── Exercise picker ────────────────────────────────────────────────────

  /// Chooses which exercise style to use for [word] in this session.
  ///
  /// Two tiers:
  /// - `fresh` (totalSeen == 0) → [ExerciseType.recognize]. The user sees
  ///   the meaning before they're ever quizzed.
  /// - Anything else → deterministic rotation across the six quiz styles
  ///   so the session stays varied. Even `reviewing` words go through
  ///   rotation now — sticking to Recognize once a word was "stable" made
  ///   long-running users feel they only ever saw flashcards.
  /// - `mastered` is the one exception: those words barely re-surface
  ///   anyway, and when they do a calm Recognize is appropriate.
  ExerciseType pickExerciseType(
    String word, {
    bool hasAudio = true,
    bool hasExample = true,
  }) {
    final state = stateFor(word);
    if (state.totalSeen == 0) return ExerciseType.recognize;
    if (state.stage == SrsStage.mastered) return ExerciseType.recognize;
    // Six-way rotation across all quiz styles. Fill-in stays in even when
    // [hasExample] is false because its widget now degrades to a meaning
    // prompt instead of skipping the card.
    const rotation = [
      ExerciseType.multipleChoice,
      ExerciseType.listenAndType,
      ExerciseType.fillInContext,
      ExerciseType.anagram,
      ExerciseType.firstLetter,
      ExerciseType.reverseTyping,
    ];
    final basis = (state.totalSeen + word.length) % rotation.length;
    var candidate = rotation[basis];
    if (candidate == ExerciseType.listenAndType && !hasAudio) {
      // Single-letter words have no useful anagram, so when we'd swap a
      // missing-audio card into Anagram we'd want to nudge it elsewhere.
      candidate = ExerciseType.firstLetter;
    }
    if (candidate == ExerciseType.anagram && word.length <= 2) {
      candidate = ExerciseType.firstLetter;
    }
    // hasExample is now informational only — fill-in has its own fallback.
    // Leaving the param so existing callers compile without churn.
    return candidate;
  }

  /// Hard-promotes a word to mastered with a year-long interval. Used by the
  /// "I already know this" shortcut so the user can permanently drop trivial
  /// words from the daily queue without having to rate Easy several times.
  Future<void> markMastered(String word) async {
    await ready;
    final key = word.toLowerCase();
    final now = DateTime.now().millisecondsSinceEpoch;
    const oneYear = 365 * 24 * 60 * 60 * 1000;
    _states[key] = stateFor(word).copyWith(
      stage: SrsStage.mastered,
      easeFactor: _maxEase,
      intervalDays: 365,
      repetitions: 5,
      dueAtMs: now + oneYear,
      lastReviewedMs: now,
      totalSeen: stateFor(word).totalSeen + 1,
    );
    await _persist();
  }

  // ── Debug / reset ──────────────────────────────────────────────────────

  Future<void> resetAll() async {
    _states.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kStatesKey);
    await prefs.remove(_kMigratedKey);
    if (!_changeCtrl.isClosed) _changeCtrl.add(null);
  }
}
