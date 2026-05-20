import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/speaking_set.dart';
import '../utils/log.dart';

/// Persists user-imported speaking sets to SharedPreferences. Single key, JSON
/// list shape — sets are tiny (a few KB at most) so we keep it simple instead
/// of using a per-set key scheme.
class SpeakingService {
  static final SpeakingService _instance = SpeakingService._internal();
  factory SpeakingService() => _instance;
  SpeakingService._internal();

  static const _kPrefsKey = 'speakingSets';

  List<SpeakingSet> _cache = [];
  bool _loaded = false;
  final _ready = Completer<void>();

  Future<void> get ready => _ready.future;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPrefsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List;
        _cache = decoded
            .map((e) => SpeakingSet.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e, st) {
      logCaught(e, st, 'SpeakingService.init');
    } finally {
      _loaded = true;
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  /// Returns all stored sets, newest first.
  List<SpeakingSet> all() {
    final list = List<SpeakingSet>.of(_cache);
    list.sort((a, b) => b.createdMs.compareTo(a.createdMs));
    return list;
  }

  SpeakingSet? byId(String id) {
    for (final s in _cache) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<void> add(SpeakingSet set) async {
    _cache.add(set);
    await _persist();
  }

  Future<void> update(SpeakingSet set) async {
    final idx = _cache.indexWhere((s) => s.id == set.id);
    if (idx < 0) return;
    _cache[idx] = set;
    await _persist();
  }

  Future<void> remove(String id) async {
    _cache.removeWhere((s) => s.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_cache.map((s) => s.toJson()).toList());
      await prefs.setString(_kPrefsKey, encoded);
    } catch (e, st) {
      logCaught(e, st, 'SpeakingService._persist');
    }
  }
}
