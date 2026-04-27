class Vocabulary {
  final String id;
  final String url;
  final String levels;
  final String word;
  final String translation;
  final String partOfSpeech;
  final String ipa;
  final String audioLink;
  final String topic;

  Vocabulary({
    required this.id,
    required this.url,
    required this.levels,
    required this.word,
    required this.translation,
    required this.partOfSpeech,
    required this.ipa,
    required this.audioLink,
    this.topic = '',
  });

  factory Vocabulary.fromCsvList(List<String> row, {String topic = ''}) {
    final word = row.length > 3 ? row[3] : '';
    return Vocabulary(
      id: row.isNotEmpty ? row[0] : '',
      url: row.length > 1 ? row[1] : '',
      levels: row.length > 2 ? row[2] : '',
      word: word,
      translation: row.length > 4 ? row[4] : '',
      partOfSpeech: row.length > 5 ? row[5] : '',
      ipa: row.length > 6 ? row[6] : '',
      audioLink: row.length > 7 ? row[7].trim() : '',
      topic: topic,
    );
  }
}
