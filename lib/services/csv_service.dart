import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vocabulary.dart';

class CsvService {
  static Future<List<Vocabulary>> loadVocabularyFromPath(String path, {bool excludeKnown = false}) async {
    try {
      final String csvString = await rootBundle.loadString(path);
      final List<String> lines = csvString.split('\n');
      if (lines.length <= 1) return [];

      Map<String, Vocabulary> mergedVocab = {};
      
      Set<String> knownWords = {};
      if (excludeKnown) {
        final prefs = await SharedPreferences.getInstance();
        knownWords = (prefs.getStringList('knownWords') ?? []).map((w) => w.toLowerCase()).toSet();
      }

      String topic = '';
      final pathParts = path.split('/');
      if (path.contains('/topic/')) {
        if (pathParts.length >= 5) {
          topic = '${pathParts[3]} - ${pathParts.last.replaceAll('.csv', '')}';
        } else {
          topic = pathParts.last.replaceAll('.csv', '');
        }
      } else if (path.contains('/popularity/')) {
        topic = '';
      }

      for (var i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        final parts = line.split(',');
        if (parts.length >= 7) {
          final vocab = Vocabulary.fromCsvList(parts, topic: topic);
          final key = vocab.word.toLowerCase();
          
          if (excludeKnown && knownWords.contains(key)) continue;

          if (mergedVocab.containsKey(key)) {
            final existing = mergedVocab[key]!;
            
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
            
            mergedVocab[key] = Vocabulary(
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
            mergedVocab[key] = vocab;
          }
        }
      }
      return mergedVocab.values.toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Vocabulary>> loadVocabulary(String level, {bool excludeKnown = false}) async {
    final String assetPath = 'assets/data/popularity/Oxford Word $level.csv';
    return loadVocabularyFromPath(assetPath, excludeKnown: excludeKnown);
  }

  static Future<Map<int, List<Vocabulary>>> loadVocabularyByDayFromPath(String path, {bool excludeKnown = false, List<String>? levelFilter}) async {
    var vocabList = await loadVocabularyFromPath(path, excludeKnown: excludeKnown);
    
    if (levelFilter != null && levelFilter.isNotEmpty) {
      vocabList = vocabList.where((v) {
        final vLevel = v.levels.toUpperCase();
        return levelFilter.any((filter) => vLevel.contains(filter.toUpperCase()));
      }).toList();
    }

    final Map<int, List<Vocabulary>> grouped = {};

    int day = 1;
    for (var i = 0; i < vocabList.length; i++) {
      if (i > 0 && i % 20 == 0) {
        day++;
      }
      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(vocabList[i]);
    }

    // Clean up empty days if any
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }

  static Future<Map<int, List<Vocabulary>>> loadVocabularyByDay(String level, {bool excludeKnown = false}) async {
    final String assetPath = 'assets/data/popularity/Oxford Word $level.csv';
    return loadVocabularyByDayFromPath(assetPath, excludeKnown: excludeKnown);
  }

  static Future<List<Vocabulary>> loadAllVocabulary({bool excludeKnown = false}) async {
    final levels = ['A1', 'A2', 'B1', 'B2', 'C1'];
    List<Vocabulary> allVocab = [];
    
    // Load Popularity
    for (var level in levels) {
      allVocab.addAll(await loadVocabulary(level, excludeKnown: excludeKnown));
    }
    
    // Load Topics
    try {
      final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final topicFiles = assetManifest.listAssets()
          .where((String key) => key.startsWith('assets/data/topic/') && key.endsWith('.csv'))
          .toList();
      for (var file in topicFiles) {
        allVocab.addAll(await loadVocabularyFromPath(file, excludeKnown: excludeKnown));
      }
    } catch (e) {
      // Fail silently if topic loading throws
    }
    
    return allVocab;
  }

  static Future<List<Vocabulary>> loadSpecificPopularityVocabulary(List<String> selectedLevels, {bool excludeKnown = false}) async {
    List<Vocabulary> vocab = [];
    for (var level in selectedLevels) {
      vocab.addAll(await loadVocabulary(level, excludeKnown: excludeKnown));
    }
    return vocab;
  }

  static Future<List<String>> getAvailableTopics() async {
    try {
      final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final topicFiles = assetManifest.listAssets()
          .where((String key) => key.startsWith('assets/data/topic/') && key.endsWith('.csv'))
          .toList();

      Set<String> categories = {};
      for (var file in topicFiles) {
        final pathParts = file.split('/');
        if (pathParts.length >= 4) {
          categories.add(pathParts[3]); // Category folder name
        }
      }
      return categories.toList()..sort();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Vocabulary>> loadSpecificTopicsVocabulary(
      List<String> selectedTopics, {
      List<String>? levelFilter,
      bool excludeKnown = false,
  }) async {
    if (selectedTopics.isEmpty) return [];
    try {
      final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final topicFiles = assetManifest.listAssets()
          .where((String key) => key.startsWith('assets/data/topic/') && key.endsWith('.csv'))
          .toList();

      List<Vocabulary> vocab = [];
      for (var file in topicFiles) {
        final pathParts = file.split('/');
        if (pathParts.length >= 4) {
          final category = pathParts[3];
          if (selectedTopics.contains(category)) {
            vocab.addAll(await loadVocabularyFromPath(file, excludeKnown: excludeKnown));
          }
        }
      }
      
      // INTERSECTION LOGIC: Only keep terms that map to the user's chosen Oxford levels
      if (levelFilter != null && levelFilter.isNotEmpty) {
        vocab = vocab.where((v) {
          final vLevel = v.levels.toUpperCase();
          return levelFilter.any((filter) => vLevel.contains(filter.toUpperCase()));
        }).toList();
      }
      
      return vocab;
    } catch (e) {
      return [];
    }
  }
}
