import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import '../models/vocabulary.dart';
import 'user_data_service.dart';
import 'vocabulary_sync_service.dart';

// ── Top-level parser helpers ───────────────────────────────────────────────
// These live outside the class so `compute()` can hand them to a background
// isolate. Parsing ~36K CSV rows on the UI isolate freezes the spinner on
// TodayScreen during cold start; this is the work being moved off-thread.

List<String> _parseCsvLine(String line) {
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

List<Vocabulary> _parseCsvContent(String csvString, String topic) {
  if (csvString.isEmpty) return const [];
  final lines = csvString.split('\n');
  if (lines.length <= 1) return const [];

  final merged = <String, Vocabulary>{};
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
      } else if (topic.isNotEmpty &&
          !newTopic.toLowerCase().contains(topic.toLowerCase())) {
        newTopic = '$newTopic, $topic';
      }

      merged[key] = Vocabulary(
        id: existing.id,
        url: existing.url.isNotEmpty ? existing.url : vocab.url,
        levels: existing.levels,
        word: existing.word,
        translation: newTrans,
        partOfSpeech: newPos,
        ipa: existing.ipa.isNotEmpty ? existing.ipa : vocab.ipa,
        audioLink: existing.audioLink.isNotEmpty ? existing.audioLink : vocab.audioLink,
        topic: newTopic,
      );
    } else {
      merged[key] = vocab;
    }
  }

  return merged.values.toList();
}

/// compute() entrypoint — parses a batch of (csvString, topic) pairs and
/// returns one Vocabulary list per job, in the same order.
List<List<Vocabulary>> _parseCsvBatch(List<List<String>> jobs) {
  return jobs.map((j) => _parseCsvContent(j[0], j[1])).toList(growable: false);
}

String _topicForPath(String path) {
  if (!path.contains('/topic/')) return '';
  final pathParts = path.split('/');
  return pathParts.length >= 5
      ? '${pathParts[3]} - ${pathParts.last.replaceAll('.csv', '')}'
      : pathParts.last.replaceAll('.csv', '');
}

class CsvService {
  // ── In-memory cache ──────────────────────────────────────────────────────
  static final Map<String, List<Vocabulary>> _rawCache = {};
  static List<String>? _topicFilesCache;
  // Memoized merge of all CSVs — hit by every notification tap.
  static List<Vocabulary>? _allCacheUnfiltered;
  static List<Vocabulary>? _allCacheKnownFiltered;

  /// Called by [UserDataService] when the known-words set changes — the
  /// known-filtered cache must be rebuilt next access.
  static void invalidateKnownWordsFilter() {
    _allCacheKnownFiltered = null;
  }

  static void clearCache() {
    _rawCache.clear();
    _topicFilesCache = null;
    _allCacheUnfiltered = null;
    _allCacheKnownFiltered = null;
  }

  // ── Raw loader (cached) ──────────────────────────────────────────────────

  static Future<String> _loadCsvString(String path) async {
    try {
      // "assets/data/popularity/Oxford Word A1.csv" → "popularity/Oxford Word A1.csv"
      final relative = path.startsWith('assets/data/')
          ? path.substring('assets/data/'.length)
          : null;
      if (relative != null) {
        final local = await VocabularySyncService.readLocalFile(relative);
        if (local != null) return local;
      }
      return await rootBundle.loadString(path);
    } catch (_) {
      return '';
    }
  }

  static Future<List<Vocabulary>> _loadRaw(String path) async {
    if (_rawCache.containsKey(path)) return _rawCache[path]!;

    try {
      final csvString = await _loadCsvString(path);
      final result = _parseCsvContent(csvString, _topicForPath(path));
      _rawCache[path] = result;
      return result;
    } catch (e) {
      _rawCache[path] = [];
      return [];
    }
  }

  static Future<List<String>> _getTopicFiles() async {
    if (_topicFilesCache != null) return _topicFilesCache!;

    // Try local downloaded files first
    final localFiles = await VocabularySyncService.listLocalTopicFiles();
    if (localFiles.isNotEmpty) {
      _topicFilesCache = localFiles;
      return _topicFilesCache!;
    }

    // Fallback to bundled assets
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
    if (excludeKnown && _allCacheKnownFiltered != null) return _allCacheKnownFiltered!;
    if (!excludeKnown && _allCacheUnfiltered != null) return _allCacheUnfiltered!;

    const levels = ['A1', 'A2', 'B1', 'B2', 'C1'];
    final topicFiles = await _getTopicFiles();
    final allPaths = <String>[
      for (final l in levels) 'assets/data/popularity/Oxford Word $l.csv',
      ...topicFiles,
    ];

    // Parse the cold paths in a background isolate so the UI thread stays
    // free to animate the spinner during cold start. Anything already cached
    // (e.g. from a prior single-file call) is reused as-is.
    final coldPaths =
        allPaths.where((p) => !_rawCache.containsKey(p)).toList(growable: false);

    if (coldPaths.isNotEmpty) {
      final strings = await Future.wait(coldPaths.map(_loadCsvString));
      final jobs = <List<String>>[
        for (var i = 0; i < coldPaths.length; i++)
          [strings[i], _topicForPath(coldPaths[i])],
      ];
      List<List<Vocabulary>> parsed;
      try {
        parsed = await compute(_parseCsvBatch, jobs);
      } catch (_) {
        // Isolate spawn can fail in constrained environments (e.g. tests).
        // Fall back to parsing on the current isolate.
        parsed = _parseCsvBatch(jobs);
      }
      for (var i = 0; i < coldPaths.length; i++) {
        _rawCache[coldPaths[i]] = parsed[i];
      }
    }

    final all = <Vocabulary>[];
    for (final p in allPaths) {
      final list = _rawCache[p];
      if (list != null) all.addAll(list);
    }
    _allCacheUnfiltered = all;
    if (!excludeKnown) return all;
    final filtered = await _applyKnownFilter(all);
    _allCacheKnownFiltered = filtered;
    return filtered;
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
    final known = UserDataService().knownWords;
    return raw.where((v) => !known.contains(v.word.toLowerCase())).toList();
  }
}
