import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vocabulary.dart';
import '../utils/log.dart';
import 'translation_service.dart';

/// Stores Vietnamese translations for words the user added that aren't in
/// the bundled vocabulary CSV (e.g. multi-word phrases, slang, brand names).
/// Filled by the bulk-import flow; read by the collection renderer so those
/// words still surface with a meaning instead of being silently dropped.
///
/// Storage shape (SharedPreferences):
///   key:   `customWordTranslations`
///   value: JSON `{ "<lowercase word>": "<vi translation>" }`
class CustomWordService {
  static final CustomWordService _instance = CustomWordService._internal();
  factory CustomWordService() => _instance;
  CustomWordService._internal();

  static const _kPrefsKey = 'customWordTranslations';

  Map<String, String> _cache = {};
  bool _loaded = false;
  final _ready = Completer<void>();

  Future<void> get ready => _ready.future;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPrefsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _cache = decoded.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (e, st) {
      logCaught(e, st, 'CustomWordService.init');
    } finally {
      _loaded = true;
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  /// Whether [word] (case-insensitive) has a stored translation.
  bool has(String word) => _cache.containsKey(word.toLowerCase());

  /// Returns the cached translation, or null if we haven't translated [word] yet.
  String? translationFor(String word) => _cache[word.toLowerCase()];

  /// Builds a synthetic [Vocabulary] for [word] using the cached translation
  /// (or the raw word if nothing is cached yet — caller can still render).
  Vocabulary syntheticVocabulary(String word) {
    final lower = word.toLowerCase();
    return Vocabulary(
      id: 'custom:$lower',
      url: '',
      levels: '',
      word: lower,
      translation: _cache[lower] ?? '',
      partOfSpeech: '',
      ipa: '',
      audioLink: '',
      topic: '',
    );
  }

  /// Translates each [words] entry through [TranslationService] and persists
  /// the results. Skips entries already cached so re-imports are cheap.
  /// Returns the resolved word→translation map for the input set.
  Future<Map<String, String>> translateAndStore(Iterable<String> words) async {
    await ready;
    final lowered = {for (final w in words) w.toLowerCase()};
    final missing = lowered.where((w) => !_cache.containsKey(w)).toList();

    if (missing.isNotEmpty) {
      final translations = await Future.wait(
        missing.map(TranslationService.toVi),
      );
      for (var i = 0; i < missing.length; i++) {
        _cache[missing[i]] = translations[i];
      }
      await _persist();
    }

    return {for (final w in lowered) w: _cache[w] ?? w};
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPrefsKey, jsonEncode(_cache));
    } catch (e, st) {
      logCaught(e, st, 'CustomWordService._persist');
    }
  }
}
