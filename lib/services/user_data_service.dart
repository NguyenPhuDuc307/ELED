import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class UserDataService {
  static final _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  // In-memory cache — read synchronously by CsvService
  Set<String> _knownWords = {};
  Map<String, List<String>> _collections = {};

  final _knownWordsCtrl = StreamController<Set<String>>.broadcast();
  final _collectionsCtrl = StreamController<Map<String, List<String>>>.broadcast();
  final _settingsCtrl = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Set<String>> get knownWordsStream => _knownWordsCtrl.stream;
  Stream<Map<String, List<String>>> get collectionsStream => _collectionsCtrl.stream;
  Stream<Map<String, dynamic>> get settingsStream => _settingsCtrl.stream;

  Set<String> get knownWords => _knownWords;
  Map<String, List<String>> get collections => Map.unmodifiable(_collections);

  StreamSubscription? _authSub;
  StreamSubscription? _userDocSub;
  StreamSubscription? _collectionsSub;

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  String? get _uid => AuthService().currentUser?.uid;
  DocumentReference? get _userDoc =>
      _uid != null ? _db.collection('users').doc(_uid) : null;

  Future<void> initialize() async {
    await _loadFromPrefs();

    _authSub = AuthService().userStream.listen((user) async {
      if (user != null) {
        await _migrateLocalToFirestore();
        _startFirestoreListeners();
      } else {
        _stopFirestoreListeners();
        await _loadFromPrefs();
      }
    });

    // Don't call _startFirestoreListeners() here — auth stream fires on startup
    // and will call it after migration completes.
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _knownWords = (prefs.getStringList('knownWords') ?? [])
        .map((w) => w.toLowerCase())
        .toSet();
    _collections = await _getLocalCollections();
    _knownWordsCtrl.add(_knownWords);
    _collectionsCtrl.add(Map.from(_collections));
  }

  void _startFirestoreListeners() {
    _stopFirestoreListeners();
    final doc = _userDoc;
    if (doc == null) return;

    Map<String, dynamic>? lastSettings;

    _userDocSub = doc.snapshots().listen((snap) {
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      _knownWords = Set<String>.from(
        (data['knownWords'] as List? ?? []).map((e) => e.toString().toLowerCase()),
      );
      _knownWordsCtrl.add(_knownWords);

      // Only apply settings when they actually changed
      final remoteSettings = data['settings'] as Map<String, dynamic>?;
      if (remoteSettings != null &&
          remoteSettings.toString() != lastSettings?.toString()) {
        lastSettings = remoteSettings;
        _applyRemoteSettings(data);
      }
    }, onError: (e) => debugPrint('Firestore knownWords error: $e'));

    _collectionsSub = doc.collection('collections').snapshots().listen((snap) {
      _collections = {
        for (final d in snap.docs)
          d.id: List<String>.from(d.data()['words'] as List? ?? []),
      };
      _collectionsCtrl.add(Map.from(_collections));
    }, onError: (e) => debugPrint('Firestore collections error: $e'));
  }

  void _stopFirestoreListeners() {
    _userDocSub?.cancel();
    _userDocSub = null;
    _collectionsSub?.cancel();
    _collectionsSub = null;
  }

  void dispose() {
    _authSub?.cancel();
    _stopFirestoreListeners();
    _knownWordsCtrl.close();
    _collectionsCtrl.close();
    _settingsCtrl.close();
  }

  // ── Settings ──────────────────────────────────────────────────────────────────

  static const _settingsFields = [
    'notificationIntervalMinutes',
    'notificationStartHour', 'notificationStartMinute',
    'notificationEndHour', 'notificationEndMinute',
    'selectedPopularity', 'selectedTopics',
    'themeMode',
  ];

  Future<void> uploadSettings() async {
    final doc = _userDoc;
    if (doc == null) return;
    final prefs = await SharedPreferences.getInstance();
    await doc.set({
      'settings': {
        'notificationIntervalMinutes': prefs.getInt('notificationIntervalMinutes') ?? 60,
        'notificationStartHour': prefs.getInt('notificationStartHour') ?? 9,
        'notificationStartMinute': prefs.getInt('notificationStartMinute') ?? 0,
        'notificationEndHour': prefs.getInt('notificationEndHour') ?? 19,
        'notificationEndMinute': prefs.getInt('notificationEndMinute') ?? 0,
        'selectedPopularity': prefs.getStringList('selectedPopularity') ?? ['A1','A2','B1','B2','C1'],
        'selectedTopics': prefs.getStringList('selectedTopics') ?? [],
        'themeMode': prefs.getString('themeMode') ?? 'system',
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _applyRemoteSettings(Map<String, dynamic> data) async {
    final settings = data['settings'] as Map<String, dynamic>?;
    if (settings == null) return;
    final prefs = await SharedPreferences.getInstance();
    for (final key in _settingsFields) {
      final val = settings[key];
      if (val == null) continue;
      if (val is int) await prefs.setInt(key, val);
      if (val is String) await prefs.setString(key, val);
      if (val is List) await prefs.setStringList(key, List<String>.from(val));
    }
    _settingsCtrl.add(Map<String, dynamic>.from(settings));
  }

  Future<void> _migrateLocalToFirestore() async {
    final doc = _userDoc;
    if (doc == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final migrationKey = 'migrated_to_firestore_$_uid';

      final snap = await doc.get();

      if (snap.exists) {
        // Apply remote settings/data to local prefs on every login
        final remoteData = snap.data() as Map<String, dynamic>;
        await _applyRemoteSettings(remoteData);
        // Don't re-merge local data — Firestore is source of truth
      } else if (prefs.getBool(migrationKey) != true) {
        // First time: push local data up once
        final localKnown = (prefs.getStringList('knownWords') ?? []).toSet();
        final localHistory = prefs.getStringList('notificationHistory') ?? [];
        final localCols = await _getLocalCollections();

        final batch = _db.batch();
        batch.set(doc, {
          'knownWords': localKnown.toList(),
          'notificationHistory': localHistory,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        for (final entry in localCols.entries) {
          batch.set(
            doc.collection('collections').doc(entry.key),
            {'words': entry.value},
          );
        }
        await batch.commit();
        await uploadSettings();
        await prefs.setBool(migrationKey, true);
      }
    } catch (e) {
      debugPrint('Migration error: $e');
    }
  }

  // ── Known Words ──────────────────────────────────────────────────────────────

  Future<void> addKnownWord(String word) async {
    final lower = word.toLowerCase();
    if (_uid != null) {
      await _userDoc!.set({
        'knownWords': FieldValue.arrayUnion([lower]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      _knownWords.add(lower);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('knownWords', _knownWords.toList());
      _knownWordsCtrl.add(_knownWords);
    }
  }

  Future<void> removeKnownWord(String word) async {
    final lower = word.toLowerCase();
    if (_uid != null) {
      await _userDoc!.set({
        'knownWords': FieldValue.arrayRemove([lower]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      _knownWords.remove(lower);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('knownWords', _knownWords.toList());
      _knownWordsCtrl.add(_knownWords);
    }
  }

  Future<void> toggleKnownWord(String word) async {
    if (_knownWords.contains(word.toLowerCase())) {
      await removeKnownWord(word);
    } else {
      await addKnownWord(word);
    }
  }

  // ── Collections ──────────────────────────────────────────────────────────────

  Future<void> createCollection(String name) async {
    if (_uid != null) {
      await _userDoc!.collection('collections').doc(name).set({'words': []});
    } else {
      if (_collections.containsKey(name)) return;
      final local = Map<String, List<String>>.from(_collections)..[name] = [];
      await _saveLocalCollections(local);
      _collections = local;
      _collectionsCtrl.add(Map.from(_collections));
    }
  }

  Future<void> deleteCollection(String name) async {
    if (_uid != null) {
      await _userDoc!.collection('collections').doc(name).delete();
    } else {
      final local = Map<String, List<String>>.from(_collections)..remove(name);
      await _saveLocalCollections(local);
      _collections = local;
      _collectionsCtrl.add(Map.from(_collections));
    }
  }

  Future<bool> addWordToCollection(String name, String word) async {
    final lower = word.toLowerCase();
    if (_collections[name]?.contains(lower) == true) return false;
    if (_uid != null) {
      await _userDoc!.collection('collections').doc(name).set(
        {'words': FieldValue.arrayUnion([lower])},
        SetOptions(merge: true),
      );
    } else {
      final local = Map<String, List<String>>.from(_collections);
      local[name] = [...(local[name] ?? []), lower];
      await _saveLocalCollections(local);
      _collections = local;
      _collectionsCtrl.add(Map.from(_collections));
    }
    return true;
  }

  Future<void> removeWordFromCollection(String name, String word) async {
    final lower = word.toLowerCase();
    if (_uid != null) {
      await _userDoc!.collection('collections').doc(name).set(
        {'words': FieldValue.arrayRemove([lower])},
        SetOptions(merge: true),
      );
    } else {
      final local = Map<String, List<String>>.from(_collections);
      local[name]?.remove(lower);
      await _saveLocalCollections(local);
      _collections = local;
      _collectionsCtrl.add(Map.from(_collections));
    }
  }

  // ── Local helpers ─────────────────────────────────────────────────────────────

  static const _collectionsKey = 'user_collections_data';

  static Future<Map<String, List<String>>> _getLocalCollections() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_collectionsKey);
    if (jsonStr == null) return {};
    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, List<String>.from(v as List)));
    } catch (_) {
      return {};
    }
  }

  static Future<void> _saveLocalCollections(Map<String, List<String>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_collectionsKey, jsonEncode(data));
  }
}
