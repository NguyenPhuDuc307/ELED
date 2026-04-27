package com.nguyenphuduc.eled

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Widget alarm scheduling (existing)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.nguyenphuduc.eled/widget_alarm")
            .setMethodCallHandler { call, result ->
                if (call.method == "scheduleFirst") {
                    val atMs = call.argument<Long>("atMs")
                    if (atMs != null) {
                        WidgetUpdateReceiver.scheduleAlarm(applicationContext, atMs)
                        result.success(null)
                    } else {
                        result.error("INVALID", "atMs required", null)
                    }
                } else {
                    result.notImplemented()
                }
            }

        // Native notification scheduling (replaces flutter_local_notifications on Android)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.nguyenphuduc.eled/notifications")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleAll" -> {
                        @Suppress("UNCHECKED_CAST")
                        val items = call.argument<List<Map<String, Any>>>("items") ?: emptyList()
                        VocabNotificationReceiver.cancelAll(applicationContext)
                        for (item in items) {
                            val id = (item["id"] as? Int) ?: continue
                            val word = (item["word"] as? String) ?: continue
                            val translation = (item["translation"] as? String) ?: ""
                            val pos = (item["pos"] as? String) ?: ""
                            val topic = (item["topic"] as? String) ?: ""
                            val atMs = when (val v = item["atMs"]) {
                                is Long -> v
                                is Int -> v.toLong()
                                else -> continue
                            }
                            val audioUrl = (item["audioUrl"] as? String) ?: ""
                            VocabNotificationReceiver.schedule(
                                applicationContext, id, word, translation, pos, topic, atMs, audioUrl
                            )
                        }
                        result.success(null)
                    }
                    "cancelAll" -> {
                        VocabNotificationReceiver.cancelAll(applicationContext)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        saveNativePayload(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val payload = intent.getStringExtra("native_notification_payload") ?: return
        intent.removeExtra("native_notification_payload")

        // Engine is already running — deliver directly to Flutter via MethodChannel.
        // This works whether the app is in the foreground or just resuming from background.
        try {
            flutterEngine?.let { engine ->
                MethodChannel(engine.dartExecutor.binaryMessenger, "com.nguyenphuduc.eled/nav")
                    .invokeMethod("openPayload", payload)
                return
            }
        } catch (_: Exception) {}

        // Fallback: engine not ready yet (shouldn't happen in onNewIntent, but just in case)
        savePayloadToPrefs(payload)
    }

    // Used only from onCreate (app was killed — engine not ready yet)
    private fun saveNativePayload(intent: Intent?) {
        val payload = intent?.getStringExtra("native_notification_payload") ?: return
        intent.removeExtra("native_notification_payload")
        savePayloadToPrefs(payload)
    }

    private fun savePayloadToPrefs(payload: String) {
        getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
            .edit()
            .putString("flutter.nativeNotificationPayload", payload)
            .apply()
    }
}
