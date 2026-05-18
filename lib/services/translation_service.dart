import 'dart:convert';
import 'dart:io';

import '../utils/log.dart';

/// Thin wrapper around the unauthenticated Google Translate gateway.
/// Same endpoint the Learning screen has been using — promoted here so
/// the bulk-import flow + collection renderer can share it.
class TranslationService {
  static const _endpoint =
      'https://translate.googleapis.com/translate_a/single';

  /// Translates [text] from English to Vietnamese. Returns the original
  /// text on any failure so the caller can fall back gracefully.
  static Future<String> toVi(String text) async {
    if (text.trim().isEmpty) return text;
    HttpClient? client;
    try {
      final uri = Uri.parse(
        '$_endpoint?client=gtx&sl=en&tl=vi&dt=t&q=${Uri.encodeComponent(text)}',
      );
      client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != 200) return text;
      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as List;
      final segments = json[0] as List;
      return segments
          .where((s) => s is List && s.isNotEmpty && s[0] is String)
          .map((s) => s[0] as String)
          .join();
    } catch (e, st) {
      logCaught(e, st, 'TranslationService.toVi');
      return text;
    } finally {
      client?.close();
    }
  }
}
