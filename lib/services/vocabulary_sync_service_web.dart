/// Browsers load the versioned vocabulary assets bundled with each web release.
class VocabularySyncService {
  static Future<bool> hasLocalData() async => true;
  static Future<bool> isOutdated() async => false;
  static Future<void> syncIfNeeded({void Function(double)? onProgress}) async {
    onProgress?.call(1);
  }

  static Future<String?> readLocalFile(String relativePath) async => null;
  static Future<List<String>> listLocalTopicFiles() async => [];
  static Future<void> clearLocalData() async {}
}
