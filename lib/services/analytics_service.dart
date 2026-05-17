import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../utils/log.dart';

/// Thin wrapper around FirebaseAnalytics. Methods never throw — analytics
/// failures must not affect the user-facing flow. Collection is auto-disabled
/// in debug builds so dev events don't pollute production reports.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics get _fa => FirebaseAnalytics.instance;

  /// Returns an observer that auto-logs `screen_view` events when the
  /// navigator pushes/pops MaterialPageRoutes. Attach to `MaterialApp.navigatorObservers`.
  FirebaseAnalyticsObserver observer() => FirebaseAnalyticsObserver(analytics: _fa);

  Future<void> init() async {
    try {
      await _fa.setAnalyticsCollectionEnabled(!kDebugMode);
    } catch (e, st) {
      logCaught(e, st, 'AnalyticsService.init');
    }
  }

  /// Logs a user-defined event. Parameter values get truncated by the SDK if
  /// too long; we silently drop any non-int/double/String values.
  Future<void> logEvent(String name, [Map<String, Object?>? parameters]) async {
    try {
      final clean = <String, Object>{};
      parameters?.forEach((k, v) {
        if (v is num || v is String) {
          clean[k] = v as Object;
        }
      });
      await _fa.logEvent(name: name, parameters: clean.isEmpty ? null : clean);
    } catch (e, st) {
      logCaught(e, st, 'AnalyticsService.logEvent($name)');
    }
  }

  Future<void> setUserId(String? id) async {
    try {
      await _fa.setUserId(id: id);
    } catch (e, st) {
      logCaught(e, st, 'AnalyticsService.setUserId');
    }
  }

  Future<void> setUserProperty(String name, String? value) async {
    try {
      await _fa.setUserProperty(name: name, value: value);
    } catch (e, st) {
      logCaught(e, st, 'AnalyticsService.setUserProperty($name)');
    }
  }
}
