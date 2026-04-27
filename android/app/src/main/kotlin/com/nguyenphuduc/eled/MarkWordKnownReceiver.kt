package com.nguyenphuduc.eled

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast

class MarkWordKnownReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val word = intent.getStringExtra("word") ?: return
        val notifId = intent.getIntExtra("notif_id", -1)

        // Dismiss the original vocabulary notification
        if (notifId >= 0) {
            (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                .cancel(notifId)
        }

        // Append word to pending list for Flutter to process on next open
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val existing = prefs.getString("flutter.nativePendingKnownWords", "") ?: ""
        val words = existing.split("\n").filter { it.isNotEmpty() }.toMutableSet()
        words.add(word.lowercase())
        prefs.edit()
            .putString("flutter.nativePendingKnownWords", words.joinToString("\n"))
            .apply()

        Toast.makeText(context, "Marked as known: ${word.uppercase()}", Toast.LENGTH_SHORT).show()
    }
}
