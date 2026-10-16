import 'package:flutter_test/flutter_test.dart';
import 'package:eled/services/vocabulary_sync_service_web.dart';

void main() {
  test('Bundled web vocabulary never requires filesystem synchronization', () async {
    expect(await VocabularySyncService.hasLocalData(), isTrue);
    expect(await VocabularySyncService.isOutdated(), isFalse);
    double? progress;
    await VocabularySyncService.syncIfNeeded(onProgress: (value) => progress = value);
    expect(progress, 1);
    expect(await VocabularySyncService.readLocalFile('popularity/Oxford Word A1.csv'), isNull);
    expect(await VocabularySyncService.listLocalTopicFiles(), isEmpty);
    await VocabularySyncService.clearLocalData();
    expect(await VocabularySyncService.hasLocalData(), isTrue);
  });
}
