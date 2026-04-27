import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class OxfordSense {
  final int number;
  final String definition;
  final String example;

  const OxfordSense({
    required this.number,
    required this.definition,
    required this.example,
  });

  Map<String, dynamic> toJson() => {
        'n': number,
        'd': definition,
        'e': example,
      };

  factory OxfordSense.fromJson(Map<String, dynamic> j) => OxfordSense(
        number: j['n'] as int,
        definition: j['d'] as String,
        example: j['e'] as String,
      );
}

class OxfordService {
  static const _cachePrefix = 'oxford_def_';
  static const _maxSenses = 4;

  /// Returns up to [_maxSenses] definitions for [word] fetched from [url].
  /// Results are cached in SharedPreferences forever (definitions don't change).
  static Future<List<OxfordSense>> fetchDefinitions(String word, String url) async {
    if (url.isEmpty) return [];

    final cacheKey = '$_cachePrefix${word.toLowerCase()}';
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        final list = jsonDecode(cached) as List;
        // Only use cache if it has results; empty cache means a previous parse failed
        if (list.isNotEmpty) {
          return list.map((e) => OxfordSense.fromJson(e as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
    }

    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse(url));
      request.headers
        ..set('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36')
        ..set('Accept', 'text/html');
      final response = await request.close();
      if (response.statusCode != 200) return [];

      final html = await response.transform(utf8.decoder).join();
      client.close();

      final senses = _parse(html);
      if (senses.isNotEmpty) {
        await prefs.setString(cacheKey, jsonEncode(senses.map((s) => s.toJson()).toList()));
      }
      return senses;
    } catch (_) {
      return [];
    }
  }

  static List<OxfordSense> _parse(String html) {
    final senses = <OxfordSense>[];

    // Words with multiple senses have sensenum="N" attribute
    final multiSenseBlocks = RegExp(
      r'<li class="sense"[^>]*sensenum="(\d+)"[^>]*>(.*?)(?=<li class="sense"|</ol>)',
      dotAll: true,
    ).allMatches(html);

    for (final m in multiSenseBlocks) {
      if (senses.length >= _maxSenses) break;
      final num = int.tryParse(m.group(1) ?? '') ?? (senses.length + 1);
      final body = m.group(2) ?? '';
      final sense = _extractSense(body, num);
      if (sense != null) senses.add(sense);
    }

    // Words with a single sense use sense_single and have no sensenum attribute
    if (senses.isEmpty) {
      final singleBlocks = RegExp(
        r'<li class="sense"[^>]*>(.*?)(?=<li class="sense"|</ol>)',
        dotAll: true,
      ).allMatches(html);
      for (final m in singleBlocks) {
        if (senses.length >= _maxSenses) break;
        final body = m.group(1) ?? '';
        final sense = _extractSense(body, senses.length + 1);
        if (sense != null) senses.add(sense);
      }
    }

    return senses;
  }

  static OxfordSense? _extractSense(String body, int num) {
    final defMatch = RegExp(r'<span class="def"[^>]*>(.*?)</span>').firstMatch(body);
    if (defMatch == null) return null;
    final definition = _stripTags(defMatch.group(1) ?? '').trim();
    if (definition.isEmpty) return null;
    final exMatch = RegExp(r'<span class="x">(.*?)</span>').firstMatch(body);
    final example = _stripTags(exMatch?.group(1) ?? '').trim();
    return OxfordSense(number: num, definition: definition, example: example);
  }

  static String _stripTags(String html) =>
      html.replaceAll(RegExp(r'<[^>]+>'), '');
}
