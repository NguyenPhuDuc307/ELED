import '../models/vocabulary.dart';

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

List<Vocabulary> parseVocabularyCsv(String csvString, String topic) {
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
        audioLink: existing.audioLink.isNotEmpty
            ? existing.audioLink
            : vocab.audioLink,
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
List<List<Vocabulary>> parseVocabularyCsvBatch(List<List<String>> jobs) {
  return jobs
      .map((j) => parseVocabularyCsv(j[0], j[1]))
      .toList(growable: false);
}

String topicForVocabularyPath(String path) {
  if (!path.contains('/topic/')) return '';
  final pathParts = path.split('/');
  return pathParts.length >= 5
      ? '${pathParts[3]} - ${pathParts.last.replaceAll('.csv', '')}'
      : pathParts.last.replaceAll('.csv', '');
}
