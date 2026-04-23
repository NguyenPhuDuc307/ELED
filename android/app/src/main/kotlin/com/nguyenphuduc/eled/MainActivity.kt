package com.nguyenphuduc.eled

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
    }
}
