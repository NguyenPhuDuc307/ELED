import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/log.dart';

enum TtsAccent { us, uk }

extension TtsAccentX on TtsAccent {
  String get locale => switch (this) {
        TtsAccent.us => 'en-US',
        TtsAccent.uk => 'en-GB',
      };
  String get label => switch (this) {
        TtsAccent.us => 'US',
        TtsAccent.uk => 'UK',
      };
}

/// Persists TTS voice preferences for the Speaking flow. The user picks an
/// accent (US/UK) and a specific voice name per accent — we store the name
/// directly because gender inference from voice names is unreliable across
/// platforms / TTS engines (Android Google TTS often returns voice names like
/// `en-us-x-iol-local` with no `gender` field and no `male`/`female` token).
class TtsPrefsService {
  static final TtsPrefsService _instance = TtsPrefsService._internal();
  factory TtsPrefsService() => _instance;
  TtsPrefsService._internal();

  static const _kAccentKey = 'ttsAccent';
  static const _kVoiceUsKey = 'ttsVoiceUs';
  static const _kVoiceUkKey = 'ttsVoiceUk';

  TtsAccent _accent = TtsAccent.us;
  String? _voiceUs;
  String? _voiceUk;
  bool _loaded = false;
  final _ready = Completer<void>();

  Future<void> get ready => _ready.future;

  TtsAccent get accent => _accent;

  /// Returns the saved voice name for [a], or null if the user hasn't picked
  /// one yet — caller should then fall back to language-only selection.
  String? voiceFor(TtsAccent a) =>
      a == TtsAccent.us ? _voiceUs : _voiceUk;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final a = prefs.getString(_kAccentKey);
      if (a != null) {
        _accent = TtsAccent.values.firstWhere(
          (e) => e.name == a,
          orElse: () => TtsAccent.us,
        );
      }
      _voiceUs = prefs.getString(_kVoiceUsKey);
      _voiceUk = prefs.getString(_kVoiceUkKey);
    } catch (e, st) {
      logCaught(e, st, 'TtsPrefsService.init');
    } finally {
      _loaded = true;
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  Future<void> setAccent(TtsAccent a) async {
    _accent = a;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccentKey, a.name);
  }

  Future<void> setVoiceFor(TtsAccent a, String? name) async {
    if (a == TtsAccent.us) {
      _voiceUs = name;
    } else {
      _voiceUk = name;
    }
    final prefs = await SharedPreferences.getInstance();
    final key = a == TtsAccent.us ? _kVoiceUsKey : _kVoiceUkKey;
    if (name == null || name.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, name);
    }
  }
}
