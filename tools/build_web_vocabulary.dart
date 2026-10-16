import 'dart:convert';
import 'dart:io';
import 'package:eled/services/vocabulary_parser.dart';

/// Run from the project root before `flutter build web`.
void main() {
  final files =
      Directory('assets/data')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.csv'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final bundle = <String, Object>{};
  var words = 0;
  for (final file in files) {
    final path = file.path;
    final topic = topicForVocabularyPath(path);
    final vocab = parseVocabularyCsv(file.readAsStringSync(), topic);
    bundle[path] = [
      for (final v in vocab)
        [
          v.id,
          v.url,
          v.levels,
          v.word,
          v.translation,
          v.partOfSpeech,
          v.ipa,
          v.audioLink,
          v.topic,
        ],
    ];
    words += vocab.length;
  }
  final output = File('web/vocabulary.json')
    ..writeAsStringSync(jsonEncode(bundle));
  stdout.writeln(
    'Bundled ${files.length} files, $words entries, ${output.lengthSync()} bytes',
  );
}
