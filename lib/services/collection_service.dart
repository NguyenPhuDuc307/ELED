import 'user_data_service.dart';

class CollectionService {
  static Future<Map<String, List<String>>> getCollections() async =>
      UserDataService().collections;

  static Future<void> createCollection(String name) =>
      UserDataService().createCollection(name);

  static Future<void> deleteCollection(String name) =>
      UserDataService().deleteCollection(name);

  static Future<bool> addWord(String collectionName, String word) =>
      UserDataService().addWordToCollection(collectionName, word);

  static Future<void> removeWord(String collectionName, String word) =>
      UserDataService().removeWordFromCollection(collectionName, word);
}
