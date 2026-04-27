package com.nguyenphuduc.eled

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class VocabNotificationReceiver : BroadcastReceiver() {

    companion object {
        private const val CHANNEL_ID = "eled_vocab_channel"

        fun schedule(
            context: Context, id: Int, word: String, translation: String,
            pos: String, topic: String, atMs: Long
        ) {
            val intent = Intent(context, VocabNotificationReceiver::class.java).apply {
                putExtra("notif_id", id)
                putExtra("word", word)
                putExtra("translation", translation)
                putExtra("pos", pos)
                putExtra("topic", topic)
            }
            val pending = PendingIntent.getBroadcast(
                context, id, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !am.canScheduleExactAlarms()) {
                am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMs, pending)
            } else {
                am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMs, pending)
            }
        }

        fun cancelAll(context: Context) {
            val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            for (id in 0..199) {
                val intent = Intent(context, VocabNotificationReceiver::class.java)
                val pending = PendingIntent.getBroadcast(
                    context, id, intent,
                    PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
                )
                if (pending != null) {
                    am.cancel(pending)
                    pending.cancel()
                }
                nm.cancel(id)
            }
        }

        fun ensureChannel(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID, "Vocabulary Reminders",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply { description = "Periodic vocabulary notifications" }
                (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                    .createNotificationChannel(channel)
            }
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        ensureChannel(context)

        val id = intent.getIntExtra("notif_id", 0)
        val word = intent.getStringExtra("word") ?: return
        val translation = intent.getStringExtra("translation") ?: ""
        val pos = intent.getStringExtra("pos") ?: ""
        val topic = intent.getStringExtra("topic") ?: ""
        val payload = "$word|$topic"

        // Tap → open app and navigate to word
        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("native_notification_payload", payload)
        }
        val openPending = PendingIntent.getActivity(
            context, id + 10000, openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // "Đã biết" action → MarkWordKnownReceiver (no app open)
        val markIntent = Intent(context, MarkWordKnownReceiver::class.java).apply {
            putExtra("word", word)
            putExtra("notif_id", id)
        }
        val markPending = PendingIntent.getBroadcast(
            context, id + 20000, markIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notif = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.launcher_icon)
            .setContentTitle(word.uppercase())
            .setContentText("$translation  •  $pos")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(openPending)
            .setAutoCancel(true)
            .addAction(0, "Known", markPending)
            .build()

        NotificationManagerCompat.from(context).notify(id, notif)
    }
}
