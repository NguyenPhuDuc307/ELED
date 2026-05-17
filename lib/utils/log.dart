import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Logs a caught error to debug console + Crashlytics (non-fatal).
/// Use in places where the user-facing flow should continue even if the
/// underlying operation fails — but where silent failure would hide bugs.
void logCaught(Object error, StackTrace stack, String context) {
  debugPrint('[$context] $error');
  try {
    FirebaseCrashlytics.instance.recordError(error, stack, reason: context, fatal: false);
  } catch (_) {
    // Crashlytics itself can fail before Firebase is initialized — never propagate.
  }
}
