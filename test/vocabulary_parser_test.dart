import 'package:flutter_test/flutter_test.dart';
import 'package:eled/services/vocabulary_parser.dart';

void main() {
  test(
    'Web prebuild uses the same duplicate merge and topic labels as mobile',
    () {
      const csv =
          'id,url,level,word,translation,pos,ipa,audio\n'
          '1,https://example.com,A1,work,làm việc,verb,/wɜːk/,\n'
          '2,https://example.com,A1,work,"công việc, việc làm",noun,/wɜːk/,https://example.com/audio.mp3\n';
      final topic = topicForVocabularyPath(
        'assets/data/topic/Work_and_business/Jobs.csv',
      );
      final words = parseVocabularyCsv(csv, topic);
      expect(words, hasLength(1));
      expect(words.single.partOfSpeech, 'verb, noun');
      expect(words.single.translation, 'làm việc; công việc, việc làm');
      expect(words.single.audioLink, 'https://example.com/audio.mp3');
      expect(words.single.topic, 'Work_and_business - Jobs');
    },
  );
}
