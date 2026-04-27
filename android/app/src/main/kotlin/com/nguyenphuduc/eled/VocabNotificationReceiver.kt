package com.nguyenphuduc.eled

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import java.io.File
import java.net.HttpURLConnection
import java.net.URL

class VocabNotificationReceiver : BroadcastReceiver() {

    companion object {
        private const val CHANNEL_ID = "eled_vocab_channel_v2"
        private const val OLD_CHANNEL_ID = "eled_vocab_channel"

        fun schedule(
            context: Context, id: Int, word: String, translation: String,
            pos: String, topic: String, atMs: Long, audioUrl: String = ""
        ) {
            val intent = Intent(context, VocabNotificationReceiver::class.java).apply {
                putExtra("notif_id", id)
                putExtra("word", word)
                putExtra("translation", translation)
                putExtra("pos", pos)
                putExtra("topic", topic)
                putExtra("audio_url", audioUrl)
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
                val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                // Remove old channel with default sound (channels are immutable — must use new ID)
                nm.deleteNotificationChannel(OLD_CHANNEL_ID)
                val channel = NotificationChannel(
                    CHANNEL_ID, "Vocabulary Reminders",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Periodic vocabulary notifications"
                    setSound(null, null)  // No default sound — pronunciation MP3 plays manually
                    enableVibration(true)
                    vibrationPattern = longArrayOf(0, 250, 100, 250)
                }
                nm.createNotificationChannel(channel)
            }
        }

        fun audioCacheFile(context: Context, word: String): File {
            val dir = File(context.filesDir, "audio_cache").also { it.mkdirs() }
            val safe = word.replace(Regex("[^a-zA-Z0-9_-]"), "_")
            return File(dir, "$safe.mp3")
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        ensureChannel(context)

        val id = intent.getIntExtra("notif_id", 0)
        val word = intent.getStringExtra("word") ?: return
        val translation = intent.getStringExtra("translation") ?: ""
        val pos = intent.getStringExtra("pos") ?: ""
        val topic = intent.getStringExtra("topic") ?: ""
        val audioUrl = intent.getStringExtra("audio_url") ?: ""
        val payload = "$word|$topic"

        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("native_notification_payload", payload)
        }
        val openPending = PendingIntent.getActivity(
            context, id + 10000, openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

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

        if (audioUrl.isEmpty()) return

        // Play pronunciation MP3 asynchronously (goAsync extends BroadcastReceiver lifetime)
        val pendingResult = goAsync()
        Thread {
            try {
                val file = audioCacheFile(context, word)
                if (!file.exists() || file.length() == 0L) {
                    val conn = URL(audioUrl).openConnection() as HttpURLConnection
                    conn.connectTimeout = 8_000
                    conn.readTimeout = 8_000
                    try {
                        conn.inputStream.use { it.copyTo(file.outputStream()) }
                    } finally {
                        conn.disconnect()
                    }
                }
                if (!file.exists() || file.length() == 0L) { pendingResult.finish(); return@Thread }

                val player = MediaPlayer()
                player.setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                player.setDataSource(file.absolutePath)
                player.setOnCompletionListener { mp -> mp.release(); pendingResult.finish() }
                player.setOnErrorListener { mp, _, _ -> mp.release(); pendingResult.finish(); true }
                player.prepare()
                player.start()
            } catch (_: Exception) {
                pendingResult.finish()
            }
        }.start()
    }
}
