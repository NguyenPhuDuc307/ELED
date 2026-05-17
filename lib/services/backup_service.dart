import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/log.dart';
import 'analytics_service.dart';
import 'user_data_service.dart';

class BackupPayload {
  final String version;
  final DateTime exportedAt;
  final List<String> knownWords;
  final Map<String, List<String>> collections;

  BackupPayload({
    required this.version,
    required this.exportedAt,
    required this.knownWords,
    required this.collections,
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'exportedAt': exportedAt.toIso8601String(),
        'knownWords': knownWords,
        'collections': collections,
      };

  factory BackupPayload.fromJson(Map<String, dynamic> j) => BackupPayload(
        version: (j['version'] as String?) ?? '1',
        exportedAt: DateTime.tryParse(j['exportedAt'] as String? ?? '') ?? DateTime.now(),
        knownWords: ((j['knownWords'] as List?) ?? const [])
            .map((e) => e.toString().toLowerCase())
            .toList(),
        collections: ((j['collections'] as Map?) ?? const {}).map(
          (k, v) => MapEntry(
            k.toString(),
            ((v as List?) ?? const []).map((e) => e.toString()).toList(),
          ),
        ),
      );
}

class ImportResult {
  final int knownAdded;
  final int collectionsAdded;
  const ImportResult({required this.knownAdded, required this.collectionsAdded});
}

/// Exports the user's known-words + collections to a JSON file the user can
/// share/save, and imports the same shape back. Pure-local — no Firebase
/// dependency, so it works for logged-out users too.
class BackupService {
  static const _version = '1';

  /// Writes the backup to a temp file and opens the system share sheet.
  /// Returns the temp file path on success.
  Future<String?> exportToShareSheet() async {
    try {
      final data = UserDataService();
      final payload = BackupPayload(
        version: _version,
        exportedAt: DateTime.now(),
        knownWords: data.knownWords.toList()..sort(),
        collections: data.collections,
      );

      final dir = await getTemporaryDirectory();
      final ts = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final file = File('${dir.path}/eled-backup-$ts.json');
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(payload.toJson()),
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'ELED backup ($ts)',
        ),
      );

      AnalyticsService().logEvent('backup_exported', {
        'known_count': payload.knownWords.length,
        'collection_count': payload.collections.length,
      });
      return file.path;
    } catch (e, st) {
      logCaught(e, st, 'BackupService.exportToShareSheet');
      return null;
    }
  }

  /// Lets the user pick a JSON file and merges its contents into the local
  /// known-words set + collections. Existing entries are kept (union, not replace).
  Future<ImportResult?> importFromPicker() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return null;
      final f = result.files.single;
      final bytes = f.bytes ?? (f.path != null ? await File(f.path!).readAsBytes() : null);
      if (bytes == null) return null;

      final raw = utf8.decode(bytes);
      final payload = BackupPayload.fromJson(jsonDecode(raw) as Map<String, dynamic>);

      final data = UserDataService();
      int knownAdded = 0;
      for (final w in payload.knownWords) {
        if (!data.knownWords.contains(w)) {
          await data.addKnownWord(w);
          knownAdded++;
        }
      }
      int collectionsAdded = 0;
      for (final entry in payload.collections.entries) {
        if (!data.collections.containsKey(entry.key)) {
          await data.createCollection(entry.key);
          collectionsAdded++;
        }
        for (final word in entry.value) {
          await data.addWordToCollection(entry.key, word);
        }
      }

      AnalyticsService().logEvent('backup_imported', {
        'known_added': knownAdded,
        'collections_added': collectionsAdded,
      });
      return ImportResult(knownAdded: knownAdded, collectionsAdded: collectionsAdded);
    } catch (e, st) {
      logCaught(e, st, 'BackupService.importFromPicker');
      return null;
    }
  }
}
