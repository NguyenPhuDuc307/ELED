import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateInfo {
  final String version;   // e.g. "1.0.0-alpha.6"
  final String releaseUrl; // GitHub release page
  final String apkUrl;    // direct APK download URL (empty if none)

  const UpdateInfo({
    required this.version,
    required this.releaseUrl,
    required this.apkUrl,
  });
}

class UpdateService {
  static const _apiUrl =
      'https://api.github.com/repos/NguyenPhuDuc307/ELED/releases?per_page=20';
  static const autoCheckPrefKey = 'autoCheckUpdate';

  static Future<bool> isAutoCheckEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(autoCheckPrefKey) ?? true;
  }

  static Future<void> setAutoCheck(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(autoCheckPrefKey, enabled);
  }

  /// Returns [UpdateInfo] if a newer app release exists, null otherwise.
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(info.buildNumber) ?? 0;

      final client = HttpClient();
      final req = await client.getUrl(Uri.parse(_apiUrl));
      req.headers.set('Accept', 'application/vnd.github.v3+json');
      final res = await req.close();
      client.close();

      if (res.statusCode != 200) return null;
      final body = await res.transform(utf8.decoder).join();
      final releases = jsonDecode(body) as List;

      for (final r in releases) {
        final tag = (r['tag_name'] as String? ?? '');
        // Skip vocabulary data releases (e.g. v1.1-vocab)
        if (tag.contains('vocab')) continue;

        // Parse build number from tag: v1.0.0-alpha.6 → 6
        final match = RegExp(r'alpha\.(\d+)').firstMatch(tag);
        if (match == null) continue;

        final remoteBuild = int.tryParse(match.group(1)!) ?? 0;
        if (remoteBuild <= currentBuild) return null; // up to date

        final assets = r['assets'] as List? ?? [];
        final apkAsset = assets.cast<Map>().where(
          (a) => (a['name'] as String? ?? '').endsWith('.apk'),
        ).firstOrNull;

        return UpdateInfo(
          version: tag.startsWith('v') ? tag.substring(1) : tag,
          releaseUrl: r['html_url'] as String? ?? '',
          apkUrl: apkAsset?['browser_download_url'] as String? ?? '',
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Downloads the APK to cache and triggers the Android package installer.
  /// [onProgress] receives 0.0–1.0; -1.0 means indeterminate (no content-length).
  static Future<void> downloadAndInstall(
    String apkUrl, {
    void Function(double progress)? onProgress,
  }) async {
    final tmpDir = await getTemporaryDirectory();
    final file = File('${tmpDir.path}/eled_update.apk');
    if (file.existsSync()) file.deleteSync();

    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(apkUrl));
      final res = await req.close();
      final total = res.contentLength;
      int received = 0;
      final sink = file.openWrite();
      await for (final chunk in res) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(total > 0 ? received / total : -1.0);
      }
      await sink.close();
    } finally {
      client.close();
    }

    const installChannel = MethodChannel('com.nguyenphuduc.eled/install');
    await installChannel.invokeMethod('installApk', {'path': file.path});
  }

  /// Current installed version string, e.g. "1.0.0-alpha.5"
  static Future<String> currentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }
}
