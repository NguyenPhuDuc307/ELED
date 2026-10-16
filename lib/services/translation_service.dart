import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/log.dart';

/// Thin wrapper around the unauthenticated Google Translate gateway.
/// Same endpoint the Learning screen has been using — promoted here so
/// the bulk-import flow + collection renderer can share it.
class TranslationService {
  static const _endpoint =
      'https://translate.googleapis.com/translate_a/single';

  /// Translates [text] from English to Vietnamese. Returns the original
  /// text on any failure so the caller can fall back gracefully.
  static Future<String> toVi(String text) =>
      translate(text, source: 'en', target: 'vi');

  /// Generic translate. [source] can be `'auto'` to let Google detect it.
  /// Returns the original text unchanged on any failure or empty input.
  static Future<String> translate(
    String text, {
    String source = 'auto',
    required String target,
  }) async {
    if (text.trim().isEmpty) return text;
    try {
      final uri = Uri.parse(
        '$_endpoint?client=gtx&sl=$source&tl=$target&dt=t&q=${Uri.encodeComponent(text)}',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return text;
      final body = utf8.decode(response.bodyBytes);
      final json = jsonDecode(body) as List;
      final segments = json[0] as List;
      return segments
          .where((s) => s is List && s.isNotEmpty && s[0] is String)
          .map((s) => s[0] as String)
          .join();
    } catch (e, st) {
      logCaught(e, st, 'TranslationService.translate');
      return text;
    }
  }

  /// Heuristic: returns true if [text] contains characters that are
  /// distinctly Vietnamese (đ or any diacritic in the standard Vietnamese
  /// alphabet). Used by the search-translate flow to pick a target
  /// language without an extra network round-trip.
  static bool looksVietnamese(String text) {
    return RegExp(
      r'[đĐăâêôơưĂÂÊÔƠƯáàảãạắằẳẵặấầẩẫậéèẻẽẹếềểễệíìỉĩịóòỏõọốồổỗộớờởỡợúùủũụứừửữựýỳỷỹỵÁÀẢÃẠẮẰẲẴẶẤẦẨẪẬÉÈẺẼẸẾỀỂỄỆÍÌỈĨỊÓÒỎÕỌỐỒỔỖỘỚỜỞỠỢÚÙỦŨỤỨỪỬỮỰÝỲỶỸỴ]',
    ).hasMatch(text);
  }
}
