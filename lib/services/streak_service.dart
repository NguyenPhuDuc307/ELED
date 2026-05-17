import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/log.dart';

/// Tracks the user's daily-activity streak. A "day" is the local calendar
/// date (no UTC drift). The streak survives a single skipped day → user has
/// until tomorrow midnight to keep it alive after their last session.
class StreakService {
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  static const _kStateKey = 'streakState';

  final _changeCtrl = StreamController<void>.broadcast();
  Stream<void> get changes => _changeCtrl.stream;

  int _current = 0;
  int _best = 0;
  // ms timestamp of the last day the user did any rating-producing session.
  int _lastActiveMs = 0;
  // YYYY-MM-DD strings for the last 60 days the user practised. Powers the
  // calendar heatmap on the Today screen.
  final Set<String> _activeDays = {};

  int get current => _current;
  int get best => _best;
  int get lastActiveMs => _lastActiveMs;
  Set<String> get activeDays => Set.unmodifiable(_activeDays);

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStateKey);
      if (raw != null && raw.isNotEmpty) {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        _current = (j['current'] as int?) ?? 0;
        _best = (j['best'] as int?) ?? 0;
        _lastActiveMs = (j['lastActiveMs'] as int?) ?? 0;
        _activeDays
          ..clear()
          ..addAll(((j['activeDays'] as List?) ?? const [])
              .map((e) => e.toString()));
      }
      _decayIfStale();
    } catch (e, st) {
      logCaught(e, st, 'StreakService.init');
    }
  }

  /// Recompute current streak considering "today is X". If the last active
  /// day is older than yesterday we reset to 0.
  void _decayIfStale() {
    if (_lastActiveMs == 0) return;
    final today = _dateKey(DateTime.now());
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    final lastKey = _dateKey(DateTime.fromMillisecondsSinceEpoch(_lastActiveMs));
    if (lastKey != today && lastKey != yesterday) {
      _current = 0;
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep activeDays bounded — only the last 90 entries (sorted desc).
      final sorted = _activeDays.toList()..sort((a, b) => b.compareTo(a));
      final trimmed = sorted.take(90).toSet();
      _activeDays
        ..clear()
        ..addAll(trimmed);
      await prefs.setString(
        _kStateKey,
        jsonEncode({
          'current': _current,
          'best': _best,
          'lastActiveMs': _lastActiveMs,
          'activeDays': _activeDays.toList(),
        }),
      );
      if (!_changeCtrl.isClosed) _changeCtrl.add(null);
    } catch (e, st) {
      logCaught(e, st, 'StreakService._persist');
    }
  }

  /// Call after a session where the user actually rated at least one card.
  /// Idempotent within a single calendar day.
  Future<void> recordActivity() async {
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    if (_activeDays.contains(todayKey)) return;

    final yesterdayKey = _dateKey(now.subtract(const Duration(days: 1)));
    final lastKey = _lastActiveMs == 0
        ? null
        : _dateKey(DateTime.fromMillisecondsSinceEpoch(_lastActiveMs));

    if (lastKey == yesterdayKey) {
      _current += 1;
    } else if (lastKey == todayKey) {
      // shouldn't reach here because of the early return, but cheap to guard
    } else {
      _current = 1;
    }
    if (_current > _best) _best = _current;
    _lastActiveMs = now.millisecondsSinceEpoch;
    _activeDays.add(todayKey);
    await _persist();
  }

  /// "2026-05-18" — stable cross-timezone key for one calendar day.
  static String _dateKey(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$m-$d';
  }

  static String dateKeyFor(DateTime dt) => _dateKey(dt);
}
