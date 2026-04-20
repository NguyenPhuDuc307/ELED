import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vocabulary.dart';

class CsvService {
  // ── In-memory cache ──────────────────────────────────────────────────────
  // Stores raw (unfiltered) merged vocabulary per asset path.
  // excludeKnown is applied after cache lookup, so the cache never goes stale.
  static final Map<String, List<Vocabulary>> _rawCache = {};
  static List<String>? _topicFilesCache;

  /// Call this after the user changes their known-words list so that
  /// excludeKnown=true calls immediately reflect the new state.
  /// Raw data is NOT cleared — only the known-word filter is re-applied on
  /// the next call, which is cheap (in-memory iteration).
  static void invalidateKnownWordsFilter() {
    // No-op: cache stores raw data; filtering is always done live.
    // Kept as a named hook for clarity / future use.
  }

  // ── CSV parser ───────────────────────────────────────────────────────────

  static List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    final current = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ',' && !inQuotes) {
        fields.add(current.toString().trim());
        current.clear();
      } else {
        current.write(ch);
      }
    }
    fields.add(current.toString().trim());
    return fields;
  }

  // ── Raw loader (cached) ──────────────────────────────────────────────────

  static Future<List<Vocabulary>> _loadRaw(String path) async {
    if (_rawCache.containsKey(path)) return _rawCache[path]!;

    try {
      final String csvString = await rootBundle.loadString(path);
      final List<String> lines = csvString.split('\n');
      if (lines.length <= 1) {
        _rawCache[path] = [];
        return [];
      }

      String topic = '';
      final pathParts = path.split('/');
      if (path.contains('/topic/')) {
        topic = pathParts.length >= 5
            ? '${pathParts[3]} - ${pathParts.last.replaceAll('.csv', '')}'
            : pathParts.last.replaceAll('.csv', '');
      }

      final Map<String, Vocabulary> merged = {};
      for (var i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final parts = _parseCsvLine(line);
        if (parts.length < 7) continue;

        final vocab = Vocabulary.fromCsvList(parts, topic: topic);
        final key = vocab.word.toLowerCase();

        if (merged.containsKey(key)) {
          final existing = merged[key]!;

          String newPos = existing.partOfSpeech;
          if (!newPos.toLowerCase().contains(vocab.partOfSpeech.toLowerCase())) {
            newPos = '$newPos, ${vocab.partOfSpeech}';
          }

          String newTrans = existing.translation;
          if (!newTrans.toLowerCase().contains(vocab.translation.toLowerCase())) {
            newTrans = '$newTrans; ${vocab.translation}';
          }

          String newTopic = existing.topic;
          if (newTopic.isEmpty) {
            newTopic = topic;
          } else if (topic.isNotEmpty && !newTopic.toLowerCase().contains(topic.toLowerCase())) {
            newTopic = '$newTopic, $topic';
          }

          merged[key] = Vocabulary(
            id: existing.id,
            url: existing.url,
            levels: existing.levels,
            word: existing.word,
            translation: newTrans,
            partOfSpeech: newPos,
            ipa: existing.ipa,
            audioLink: existing.audioLink,
            topic: newTopic,
          );
        } else {
          merged[key] = vocab;
        }
      }

      final result = merged.values.toList();
      _rawCache[path] = result;
      return result;
    } catch (e) {
      _rawCache[path] = [];
      return [];
    }
  }

  static Future<List<String>> _getTopicFiles() async {
    if (_topicFilesCache != null) return _topicFilesCache!;
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _topicFilesCache = manifest.listAssets()
          .where((k) => k.startsWith('assets/data/topic/') && k.endsWith('.csv'))
          .toList();
    } catch (_) {
      _topicFilesCache = [];
    }
    return _topicFilesCache!;
  }

  // ── Public API ───────────────────────────────────────────────────────────

  static Future<List<Vocabulary>> loadVocabularyFromPath(
    String path, {
    bool excludeKnown = false,
  }) async {
    final raw = await _loadRaw(path);
    if (!excludeKnown) return raw;
    return _applyKnownFilter(raw);
  }

  static Future<List<Vocabulary>> loadVocabulary(
    String level, {
    bool excludeKnown = false,
  }) {
    return loadVocabularyFromPath(
      'assets/data/popularity/Oxford Word $level.csv',
      excludeKnown: excludeKnown,
    );
  }

  static Future<Map<int, List<Vocabulary>>> loadVocabularyByDayFromPath(
    String path, {
    bool excludeKnown = false,
    List<String>? levelFilter,
  }) async {
    var vocabList = await loadVocabularyFromPath(path, excludeKnown: excludeKnown);

    if (levelFilter != null && levelFilter.isNotEmpty) {
      final upper = levelFilter.map((f) => f.toUpperCase()).toList();
      vocabList = vocabList
          .where((v) => upper.any((f) => v.levels.toUpperCase().contains(f)))
          .toList();
    }

    final Map<int, List<Vocabulary>> grouped = {};
    int day = 1;
    for (var i = 0; i < vocabList.length; i++) {
      if (i > 0 && i % 20 == 0) day++;
      grouped.putIfAbsent(day, () => []).add(vocabList[i]);
    }
    grouped.removeWhere((_, v) => v.isEmpty);
    return grouped;
  }

  static Future<Map<int, List<Vocabulary>>> loadVocabularyByDay(
    String level, {
    bool excludeKnown = false,
  }) {
    return loadVocabularyByDayFromPath(
      'assets/data/popularity/Oxford Word $level.csv',
      excludeKnown: excludeKnown,
    );
  }

  static Future<List<Vocabulary>> loadAllVocabulary({bool excludeKnown = false}) async {
    const levels = ['A1', 'A2', 'B1', 'B2', 'C1'];
    final topicFiles = await _getTopicFiles();

    final results = await Future.wait([
      ...levels.map((l) => _loadRaw('assets/data/popularity/Oxford Word $l.csv')),
      ...topicFiles.map(_loadRaw),
    ]);

    final all = results.expand((r) => r).toList();
    if (!excludeKnown) return all;
    return _applyKnownFilter(all);
  }

  static Future<List<Vocabulary>> loadSpecificPopularityVocabulary(
    List<String> selectedLevels, {
    bool excludeKnown = false,
  }) async {
    final results = await Future.wait(
      selectedLevels.map((l) => _loadRaw('assets/data/popularity/Oxford Word $l.csv')),
    );
    final all = results.expand((r) => r).toList();
    if (!excludeKnown) return all;
    return _applyKnownFilter(all);
  }

  static Future<List<String>> getAvailableTopics() async {
    final files = await _getTopicFiles();
    final categories = <String>{};
    for (final f in files) {
      final parts = f.split('/');
      if (parts.length >= 4) categories.add(parts[3]);
    }
    return categories.toList()..sort();
  }

  static Future<List<Vocabulary>> loadSpecificTopicsVocabulary(
    List<String> selectedTopics, {
    List<String>? levelFilter,
    bool excludeKnown = false,
  }) async {
    if (selectedTopics.isEmpty) return [];
    try {
      final topicFiles = await _getTopicFiles();
      final matching = topicFiles.where((f) {
        final parts = f.split('/');
        return parts.length >= 4 && selectedTopics.contains(parts[3]);
      }).toList();

      final results = await Future.wait(matching.map(_loadRaw));
      var vocab = results.expand((r) => r).toList();

      if (levelFilter != null && levelFilter.isNotEmpty) {
        final upper = levelFilter.map((f) => f.toUpperCase()).toList();
        vocab = vocab
            .where((v) => upper.any((f) => v.levels.toUpperCase().contains(f)))
            .toList();
      }

      if (!excludeKnown) return vocab;
      return _applyKnownFilter(vocab);
    } catch (e) {
      return [];
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static Future<List<Vocabulary>> _applyKnownFilter(List<Vocabulary> raw) async {
    final prefs = await SharedPreferences.getInstance();
    final known = (prefs.getStringList('knownWords') ?? [])
        .map((w) => w.toLowerCase())
        .toSet();
    return raw.where((v) => !known.contains(v.word.toLowerCase())).toList();
  }
}
