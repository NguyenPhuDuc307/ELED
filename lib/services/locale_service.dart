import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's preferred app language and exposes it as a
/// [ValueNotifier] so [MaterialApp]'s `locale` can rebuild on change.
///
/// A `null` value means "follow system" — `MaterialApp` then picks the
/// best match from `supportedLocales` for the device locale.
class LocaleService {
  static const _prefsKey = 'appLocale';

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// `null` = follow system locale.
  static final ValueNotifier<Locale?> notifier = ValueNotifier<Locale?>(null);

  /// Read the stored preference into [notifier]. Call once during bootstrap.
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    notifier.value = code == null ? null : Locale(code);
  }

  /// Set the active locale. Pass `null` to revert to system default.
  static Future<void> set(Locale? locale) async {
    notifier.value = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}
