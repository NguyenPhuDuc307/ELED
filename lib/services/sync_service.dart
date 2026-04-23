import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'collection_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  String? get _uid => AuthService().currentUser?.uid;
  DocumentReference? get _userDoc =>
      _uid != null ? _db.collection('users').doc(_uid) : null;

  // ── Upload ─────────────────────────────────────────────────────────────

  Future<void> uploadAll() async {
    final doc = _userDoc;
    if (doc == null) return;

    final prefs       = await SharedPreferences.getInstance();
    final collections = await CollectionService.getCollections();

    final batch = _db.batch();
    batch.set(doc, {
      'knownWords':          prefs.getStringList('knownWords') ?? [],
      'notificationHistory': prefs.getStringList('notificationHistory') ?? [],
      'updatedAt':           FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    for (final entry in collections.entries) {
      batch.set(
        doc.collection('collections').doc(entry.key),
        {'words': entry.value},
      );
    }

    await batch.commit();
  }

  Future<void> uploadKnownWords() async {
    final doc = _userDoc;
    if (doc == null) return;
    final prefs = await SharedPreferences.getInstance();
    await doc.set({
      'knownWords': prefs.getStringList('knownWords') ?? [],
      'updatedAt':  FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> uploadHistory() async {
    final doc = _userDoc;
    if (doc == null) return;
    final prefs = await SharedPreferences.getInstance();
    await doc.set({
      'notificationHistory': prefs.getStringList('notificationHistory') ?? [],
      'updatedAt':           FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> uploadCollection(String name, List<String> words) async {
    await _userDoc?.collection('collections').doc(name).set({'words': words});
  }

  Future<void> deleteCloudCollection(String name) async {
    await _userDoc?.collection('collections').doc(name).delete();
  }

  // ── Download & merge ───────────────────────────────────────────────────

  Future<void> downloadAndMerge() async {
    final doc = _userDoc;
    if (doc == null) return;

    final prefs = await SharedPreferences.getInstance();
    final snap  = await doc.get();

    if (snap.exists) {
      final data = snap.data() as Map<String, dynamic>;

      // Merge knownWords
      final cloudKnown = List<String>.from(data['knownWords'] ?? []);
      final localKnown = prefs.getStringList('knownWords') ?? [];
      await prefs.setStringList('knownWords', {...localKnown, ...cloudKnown}.toList());

      // Merge history (cloud first, deduped)
      final cloudHistory = List<String>.from(data['notificationHistory'] ?? []);
      final localHistory = prefs.getStringList('notificationHistory') ?? [];
      final merged = <String>[];
      final seen   = <String>{};
      for (final e in [...cloudHistory, ...localHistory]) {
        if (seen.add(e.split('|')[0])) merged.add(e);
      }
      if (merged.length > 500) merged.length = 500;
      await prefs.setStringList('notificationHistory', merged);
    }

    // Merge collections
    final colSnaps   = await doc.collection('collections').get();
    final localCols  = await CollectionService.getCollections();

    for (final colDoc in colSnaps.docs) {
      final name        = colDoc.id;
      final cloudWords  = List<String>.from(colDoc.data()['words'] ?? []);
      final localWords  = localCols[name] ?? [];
      final mergedWords = {...localWords, ...cloudWords}.toList();

      if (!localCols.containsKey(name)) {
        await CollectionService.createCollection(name);
      }
      for (final w in mergedWords) {
        await CollectionService.addWord(name, w);
      }
    }

    // Push merged data back to cloud
    await uploadAll();
  }
}
