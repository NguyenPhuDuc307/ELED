package com.nguyenphuduc.eled

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build

class WidgetUpdateReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        // home_widget stores data in "HomeWidgetPreferences" with unprefixed keys
        val hwPrefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val scheduleStr = hwPrefs.getString("widgetScheduleEntries", "") ?: ""
        if (scheduleStr.isEmpty()) return

        val entries = scheduleStr.split(",").filter { it.isNotEmpty() }
        val nowMs = System.currentTimeMillis()

        var latestFired: List<String>? = null
        var nextMs: Long? = null

        for (entry in entries) {
            val parts = entry.split("|")
            if (parts.size < 7) continue
            val ms = parts[0].toLongOrNull() ?: continue
            if (ms <= nowMs) {
                latestFired = parts
            } else if (nextMs == null) {
                nextMs = ms
            }
        }

        if (latestFired != null) {
            val word  = latestFired[1]
            val topic = latestFired[6]

            // Update widget data in HomeWidgetPreferences
            hwPrefs.edit().apply {
                putString("word",        word)
                putString("translation", latestFired[2])
                putString("ipa",         latestFired[3])
                putString("pos",         latestFired[4])
                putString("levels",      latestFired[5])
                putString("topic",       topic)
                apply()
            }

            // Trigger widget redraw
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, VocabularyWidgetProvider::class.java))
            val updateIntent = Intent(context, VocabularyWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            }
            context.sendBroadcast(updateIntent)

            // Write pending history to FlutterSharedPreferences for Flutter to merge on next open
            val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val existing = flutterPrefs.getString("flutter.nativeHistoryPending", "") ?: ""
            val lines = existing.split("\n").filter { it.isNotEmpty() }.toMutableList()
            lines.removeAll { it == word || it.startsWith("$word|") }
            lines.add(0, "$word|$topic")
            if (lines.size > 500) lines.subList(500, lines.size).clear()
            flutterPrefs.edit().putString("flutter.nativeHistoryPending", lines.joinToString("\n")).apply()
        }

        if (nextMs != null) {
            scheduleAlarm(context, nextMs)
        }
    }

    companion object {
        private const val REQUEST_CODE = 9876

        fun scheduleAlarm(context: Context, atMs: Long) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, WidgetUpdateReceiver::class.java)
            val pending = PendingIntent.getBroadcast(
                context, REQUEST_CODE, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarmManager.canScheduleExactAlarms()) {
                alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMs, pending)
            } else {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMs, pending)
            }
        }
    }
}
