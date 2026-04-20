import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionService {
  static const String _key = 'user_collections_data';

  static Future<Map<String, List<String>>> getCollections() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return {};
    
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final Map<String, List<String>> result = {};
      decoded.forEach((key, value) {
        if (value is List) {
          result[key] = value.map((e) => e.toString()).toList();
        }
      });
      return result;
    } catch (e) {
      return {};
    }
  }

  static Future<void> _saveCollections(Map<String, List<String>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }

  static Future<void> createCollection(String name) async {
    final data = await getCollections();
    if (!data.containsKey(name)) {
      data[name] = [];
      await _saveCollections(data);
    }
  }

  static Future<void> deleteCollection(String name) async {
    final data = await getCollections();
    if (data.containsKey(name)) {
      data.remove(name);
      await _saveCollections(data);
    }
  }

  static Future<bool> addWord(String collectionName, String word) async {
    final data = await getCollections();
    if (data.containsKey(collectionName)) {
      final w = word.toLowerCase();
      if (!data[collectionName]!.contains(w)) {
        data[collectionName]!.add(w);
        await _saveCollections(data);
        return true;
      }
    }
    return false;
  }

  static Future<void> removeWord(String collectionName, String word) async {
    final data = await getCollections();
    if (data.containsKey(collectionName)) {
      final w = word.toLowerCase();
      data[collectionName]!.remove(w);
      await _saveCollections(data);
    }
  }
}
