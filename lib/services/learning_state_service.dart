import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vocabulary.dart';
import '../utils/log.dart';
import 'csv_service.dart';
import 'user_data_service.dart';

/// Last position the user was at inside a Learning session. We store just
/// enough to rebuild the screen — labels and the ordered list of word keys —
/// so the menu's "Continue" tile can warp the user straight back in.
class LearningContext {
  final String label;          // e.g. "Day 3", "Topic: Animals", "Search: happy"
  final int day;               // 0 if not day-grouped
  final List<String> wordKeys; // lowercase word strings, in order
  final int currentIndex;
  final int totalCount;
  final int lastOpenedMs;

  const LearningContext({
    required this.label,
    required this.day,
    required this.wordKeys,
    required this.currentIndex,
    required this.totalCount,
    required this.lastOpenedMs,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'day': day,
        'wordKeys': wordKeys,
        'currentIndex': currentIndex,
        'totalCount': totalCount,
        'lastOpenedMs': lastOpenedMs,
      };

  factory LearningContext.fromJson(Map<String, dynamic> j) => LearningContext(
        label: (j['label'] as String?) ?? '',
        day: (j['day'] as int?) ?? 0,
        wordKeys: ((j['wordKeys'] as List?) ?? const [])
            .map((e) => e.toString().toLowerCase())
            .toList(),
        currentIndex: (j['currentIndex'] as int?) ?? 0,
        totalCount: (j['totalCount'] as int?) ?? 0,
        lastOpenedMs: (j['lastOpenedMs'] as int?) ?? 0,
      );

  /// Whether enough time has passed that "Continue" feels stale and we
  /// shouldn't surface it on the menu. 14 days for now.
  bool get isFresh =>
      DateTime.now().millisecondsSinceEpoch - lastOpenedMs <
      14 * 24 * 60 * 60 * 1000;
}

class LearningStateService {
  static final LearningStateService _instance = LearningStateService._internal();
  factory LearningStateService() => _instance;
  LearningStateService._internal();

  static const _kContextKey = 'lastLearningContext';

  Future<void> saveContext(LearningContext ctx) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kContextKey, jsonEncode(ctx.toJson()));
    } catch (e, st) {
      logCaught(e, st, 'LearningStateService.saveContext');
    }
  }

  Future<LearningContext?> loadContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kContextKey);
      if (raw == null || raw.isEmpty) return null;
      final ctx = LearningContext.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      return ctx.isFresh ? ctx : null;
    } catch (e, st) {
      logCaught(e, st, 'LearningStateService.loadContext');
      return null;
    }
  }

  Future<void> clearContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kContextKey);
    } catch (e, st) {
      logCaught(e, st, 'LearningStateService.clearContext');
    }
  }

  /// Resolve the saved word keys back into full Vocabulary objects so the
  /// Learning screen can pick up where it left off. Returns null if too few
  /// of the saved words still resolve (e.g. user wiped vocabulary data).
  Future<List<Vocabulary>?> hydrateContext(LearningContext ctx) async {
    try {
      final all = await CsvService.loadAllVocabulary(excludeKnown: false);
      final byKey = <String, Vocabulary>{};
      for (final v in all) {
        byKey.putIfAbsent(v.word.toLowerCase(), () => v);
      }
      final hydrated = <Vocabulary>[];
      for (final key in ctx.wordKeys) {
        final v = byKey[key];
        if (v != null) hydrated.add(v);
      }
      if (hydrated.length < ctx.wordKeys.length * 0.5) return null;
      return hydrated;
    } catch (e, st) {
      logCaught(e, st, 'LearningStateService.hydrateContext');
      return null;
    }
  }

  /// Pick up to [count] known words at random for a quick review session.
  /// Returns an empty list if there aren't enough known words.
  Future<List<Vocabulary>> dailyReviewWords({int count = 10}) async {
    try {
      final known = UserDataService().knownWords;
      if (known.length < 3) return [];
      final all = await CsvService.loadAllVocabulary(excludeKnown: false);
      final pool = <Vocabulary>[];
      final seen = <String>{};
      for (final v in all) {
        final k = v.word.toLowerCase();
        if (known.contains(k) && seen.add(k)) {
          pool.add(v);
        }
      }
      pool.shuffle();
      return pool.take(count).toList();
    } catch (e, st) {
      logCaught(e, st, 'LearningStateService.dailyReviewWords');
      return [];
    }
  }
}
