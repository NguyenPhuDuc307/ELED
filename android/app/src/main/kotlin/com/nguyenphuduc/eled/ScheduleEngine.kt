package com.nguyenphuduc.eled

import android.content.Context
import java.net.HttpURLConnection
import java.net.URL
import java.util.Calendar

/**
 * Shared scheduling logic for vocab notifications. Used by:
 * - VocabNotificationReceiver (refill after fire)
 * - BootReceiver (rebuild queue after reboot/app update)
 * - WatchdogWorker (defense-in-depth refill if alarms get killed)
 *
 * Config + pool are persisted to FlutterSharedPreferences so both Dart and
 * Kotlin can read/write without duplicating state.
 */
object ScheduleEngine {
    private const val PREFS = "FlutterSharedPreferences"
    const val KEY_POOL = "flutter.vocabSchedulePool"
    const val KEY_INTERVAL = "flutter.vocabScheduleIntervalMinutes"
    const val KEY_START_MINS = "flutter.vocabScheduleStartMinutes"
    const val KEY_END_MINS = "flutter.vocabScheduleEndMinutes"
    const val KEY_LATEST_SCHEDULED_MS = "flutter.vocabScheduleLatestMs"
    const val KEY_LAST_FIRE_MS = "flutter.vocabScheduleLastFireMs"
    const val KEY_POOL_CURSOR = "flutter.vocabSchedulePoolCursor"
    // Mirrors Dart's `notificationWordsPerBundle` setting. After bundling
    // was removed this is now the number of separate notifications fired
    // per scheduled slot, staggered by [INTRA_SLOT_GAP_MS].
    const val KEY_NOTIFS_PER_SLOT = "flutter.vocabScheduleWordsPerBundle"
    // Position within the current slot's burst. Increments on every fire,
    // wraps at notifsPerSlot. Lets refillAfterFire decide whether to start
    // a new slot or just stagger the next notif into the current burst.
    const val KEY_BURST_POSITION = "flutter.vocabScheduleBurstPosition"

    const val MAX_ALARMS_AHEAD = 100
    const val NOTIF_ID_MAX = 200
    const val INTRA_SLOT_GAP_MS = 3_000L
    private const val FIELD_SEP = ""
    private const val ITEM_SEP = "\n"

    data class Config(
        val intervalMins: Int,
        val startMins: Int,
        val endMins: Int,
        val notifsPerSlot: Int,
    ) {
        fun isValid(): Boolean =
            intervalMins > 0 && startMins in 0..1439 && endMins in 0..1440 && endMins > startMins && notifsPerSlot > 0
    }

    data class PoolItem(
        val word: String,
        val translation: String,
        val pos: String,
        val topic: String,
        val audioUrl: String,
        val ipa: String,
        val levels: String,
    )

    private fun prefs(ctx: Context) =
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun loadConfig(ctx: Context): Config? {
        val p = prefs(ctx)
        if (!p.contains(KEY_INTERVAL)) return null
        val interval = p.getInt(KEY_INTERVAL, 0)
        val startMins = p.getInt(KEY_START_MINS, 0)
        val endMins = p.getInt(KEY_END_MINS, 0)
        // Default to 1 for users upgrading from the bundled-pre-fix era who
        // never re-saved their notification settings.
        val notifsPerSlot = p.getInt(KEY_NOTIFS_PER_SLOT, 1).coerceAtLeast(1)
        val cfg = Config(interval, startMins, endMins, notifsPerSlot)
        return if (cfg.isValid()) cfg else null
    }

    fun loadPool(ctx: Context): List<PoolItem> {
        val raw = prefs(ctx).getString(KEY_POOL, "") ?: ""
        if (raw.isEmpty()) return emptyList()
        return raw.split(ITEM_SEP).mapNotNull { line ->
            if (line.isEmpty()) return@mapNotNull null
            val f = line.split(FIELD_SEP)
            if (f.size < 7) return@mapNotNull null
            PoolItem(f[0], f[1], f[2], f[3], f[4], f[5], f[6])
        }
    }

    fun encodePool(pool: List<PoolItem>): String =
        pool.joinToString(ITEM_SEP) {
            listOf(it.word, it.translation, it.pos, it.topic, it.audioUrl, it.ipa, it.levels).joinToString(FIELD_SEP)
        }

    /**
     * Compute the next alarm time at or after [afterMs], aligned to the interval grid
     * within the daily [startMins, endMins) window. If [afterMs] falls outside the window,
     * roll forward to the next day's first slot.
     */
    fun nextSlot(afterMs: Long, config: Config): Long {
        val cal = Calendar.getInstance().apply { timeInMillis = afterMs }
        var year = cal.get(Calendar.YEAR)
        var month = cal.get(Calendar.MONTH)
        var day = cal.get(Calendar.DAY_OF_MONTH)
        val curMins = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)
        val curSec = cal.get(Calendar.SECOND)
        val curMs = cal.get(Calendar.MILLISECOND)

        // Round up to next aligned slot in minutes
        var slot = if (curSec == 0 && curMs == 0) {
            alignedCeil(curMins, config.intervalMins)
        } else {
            alignedCeil(curMins + 1, config.intervalMins)
        }

        if (slot < config.startMins) {
            slot = alignedCeil(config.startMins, config.intervalMins)
        }
        if (slot >= config.endMins) {
            // Roll to next day's first slot
            val nextDay = Calendar.getInstance().apply {
                set(year, month, day, 0, 0, 0)
                set(Calendar.MILLISECOND, 0)
                add(Calendar.DAY_OF_MONTH, 1)
            }
            year = nextDay.get(Calendar.YEAR)
            month = nextDay.get(Calendar.MONTH)
            day = nextDay.get(Calendar.DAY_OF_MONTH)
            slot = alignedCeil(config.startMins, config.intervalMins)
        }

        val result = Calendar.getInstance().apply {
            set(year, month, day, slot / 60, slot % 60, 0)
            set(Calendar.MILLISECOND, 0)
        }
        return result.timeInMillis
    }

    private fun alignedCeil(minutes: Int, interval: Int): Int {
        val aligned = (minutes / interval) * interval
        return if (aligned >= minutes) aligned else aligned + interval
    }

    /**
     * Called from VocabNotificationReceiver after a notification fires.
     * Schedules the next alarm at the tail of the pipeline so we always have
     * ~MAX_ALARMS_AHEAD alarms pending. This fixes the "1-day pool exhaustion" bug.
     */
    fun refillAfterFire(ctx: Context, firedNotifId: Int) {
        val config = loadConfig(ctx) ?: return
        val pool = loadPool(ctx)
        if (pool.isEmpty()) return

        val p = prefs(ctx)
        val now = System.currentTimeMillis()
        val latest = p.getLong(KEY_LATEST_SCHEDULED_MS, 0L).coerceAtLeast(now)
        val burstPos = p.getInt(KEY_BURST_POSITION, 0)

        // Position 0 starts a fresh slot; later positions stack onto the
        // current burst with INTRA_SLOT_GAP_MS spacing.
        val nextMs = if (burstPos == 0) {
            nextSlot(latest, config)
        } else {
            latest + INTRA_SLOT_GAP_MS
        }

        val cursor = p.getInt(KEY_POOL_CURSOR, 0)
        val item = pool[cursor % pool.size]
        // Reuse the fired ID — the slot it just released — so we stay within 0..NOTIF_ID_MAX
        VocabNotificationReceiver.schedule(
            ctx, firedNotifId, item.word, item.translation, item.pos, item.topic, nextMs, item.audioUrl
        )

        p.edit()
            .putLong(KEY_LATEST_SCHEDULED_MS, nextMs)
            .putLong(KEY_LAST_FIRE_MS, now)
            .putInt(KEY_POOL_CURSOR, (cursor + 1) % maxOf(pool.size, 1))
            .putInt(KEY_BURST_POSITION, (burstPos + 1) % config.notifsPerSlot)
            .apply()
    }

    /**
     * Cancel all alarms then schedule MAX_ALARMS_AHEAD starting from now.
     * Used by BootReceiver and WatchdogWorker.
     */
    fun rescheduleAll(ctx: Context) {
        val config = loadConfig(ctx) ?: return
        val pool = loadPool(ctx)
        if (pool.isEmpty()) return

        VocabNotificationReceiver.cancelAll(ctx)

        val p = prefs(ctx)
        val cursorStart = p.getInt(KEY_POOL_CURSOR, 0)
        val count = minOf(MAX_ALARMS_AHEAD, pool.size * 4)  // cap, but allow cycling
        var slotMs = System.currentTimeMillis()
        var lastScheduled = slotMs

        // Burst-aware schedule: for every aligned slot, fan out [notifsPerSlot]
        // notifications separated by INTRA_SLOT_GAP_MS so the user gets a
        // small cluster instead of a single ping.
        for (i in 0 until count) {
            val burstPos = i % config.notifsPerSlot
            val atMs = if (burstPos == 0) {
                slotMs = nextSlot(slotMs, config)
                slotMs
            } else {
                lastScheduled + INTRA_SLOT_GAP_MS
            }
            val item = pool[(cursorStart + i) % pool.size]
            VocabNotificationReceiver.schedule(
                ctx, i % NOTIF_ID_MAX, item.word, item.translation, item.pos, item.topic, atMs, item.audioUrl
            )
            lastScheduled = atMs
        }

        p.edit()
            .putLong(KEY_LATEST_SCHEDULED_MS, lastScheduled)
            .putInt(KEY_POOL_CURSOR, (cursorStart + count) % maxOf(pool.size, 1))
            .putInt(KEY_BURST_POSITION, count % config.notifsPerSlot)
            .apply()
    }

    /**
     * Downloads pronunciation MP3 for the next [count] words in the schedule pool
     * to the local audio cache. Skips items already cached. Best-effort: failures
     * for individual items don't abort the rest. Call this from WatchdogWorker
     * so audio is ready before each alarm fires (no spinning when offline).
     */
    fun prefetchAudio(ctx: Context, count: Int = 20) {
        val pool = loadPool(ctx)
        if (pool.isEmpty()) return
        val p = prefs(ctx)
        val cursor = p.getInt(KEY_POOL_CURSOR, 0)

        for (i in 0 until count) {
            val item = pool[(cursor + i) % pool.size]
            if (item.audioUrl.isEmpty()) continue
            val file = VocabNotificationReceiver.audioCacheFile(ctx, item.word)
            if (file.exists() && file.length() > 0L) continue
            try {
                val conn = URL(item.audioUrl).openConnection() as HttpURLConnection
                conn.connectTimeout = 8_000
                conn.readTimeout = 8_000
                try {
                    conn.inputStream.use { it.copyTo(file.outputStream()) }
                } finally {
                    conn.disconnect()
                }
            } catch (_: Exception) {
                // Individual download failure — keep going. The runtime download
                // path in VocabNotificationReceiver.onReceive will retry at fire time.
            }
        }
    }
}
