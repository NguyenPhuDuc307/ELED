import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/log.dart';

class VocabularySyncService {
  static const _versionKey = 'vocabulary_local_version';
  static const _currentVersion = 'v1.1-vocab';
  static const _downloadUrl =
      'https://github.com/NguyenPhuDuc307/ELED/releases/download/v1.1-vocab/vocabulary_v2.zip';

  static Future<Directory> _localDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/eled_vocab');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<bool> hasLocalData() async {
    final dir = await _localDir();
    return Directory('${dir.path}/popularity').exists();
  }

  static Future<bool> isOutdated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_versionKey) != _currentVersion;
  }

  /// Downloads and extracts vocabulary zip if version changed or missing.
  /// [onProgress] receives 0.0–1.0.
  static Future<void> syncIfNeeded({void Function(double)? onProgress}) async {
    final prefs = await SharedPreferences.getInstance();
    final localVersion = prefs.getString(_versionKey) ?? '';

    if (localVersion == _currentVersion && await hasLocalData()) {
      onProgress?.call(1.0);
      return;
    }

    final dir = await _localDir();
    final zipFile = File('${dir.path}/vocabulary.zip');

    // Download zip
    final client = HttpClient();
    try {
      onProgress?.call(0.0);
      final request = await client.getUrl(Uri.parse(_downloadUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Tải thất bại (HTTP ${response.statusCode})');
      }

      final total = response.contentLength;
      int received = 0;
      final sink = zipFile.openWrite();
      await response.listen((chunk) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(0.1 + (received / total) * 0.7);
      }).asFuture<void>();
      await sink.close();
    } finally {
      client.close();
    }

    // Extract zip
    onProgress?.call(0.8);
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      // Strip leading "assets/data/" from zip paths
      String outPath = file.name;
      if (outPath.startsWith('assets/data/')) {
        outPath = outPath.substring('assets/data/'.length);
      }
      final outFile = File('${dir.path}/$outPath');
      if (file.isFile) {
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      }
    }

    await zipFile.delete();
    await prefs.setString(_versionKey, _currentVersion);
    onProgress?.call(1.0);
  }

  /// Returns content of a local CSV file given its relative path,
  /// e.g. "popularity/Oxford Word A1.csv".
  static Future<String?> readLocalFile(String relativePath) async {
    try {
      final dir = await _localDir();
      final file = File('${dir.path}/$relativePath');
      if (await file.exists()) return file.readAsString();
    } catch (e, st) {
      logCaught(e, st, 'VocabularySyncService.readLocalFile($relativePath)');
    }
    return null;
  }

  /// Lists all topic CSVs in the local directory as asset-style paths,
  /// e.g. "assets/data/topic/Animals/Birds.csv".
  static Future<List<String>> listLocalTopicFiles() async {
    try {
      final dir = await _localDir();
      final topicDir = Directory('${dir.path}/topic');
      if (!await topicDir.exists()) return [];

      final files = <String>[];
      await for (final entity in topicDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.csv')) {
          final relative = entity.path.substring(dir.path.length + 1);
          files.add('assets/data/$relative');
        }
      }
      return files;
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearLocalData() async {
    final dir = await _localDir();
    if (await dir.exists()) await dir.delete(recursive: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_versionKey);
  }
}
