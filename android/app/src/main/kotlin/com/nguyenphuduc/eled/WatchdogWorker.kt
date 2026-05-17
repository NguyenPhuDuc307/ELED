package com.nguyenphuduc.eled

import android.content.Context
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import java.util.Calendar
import java.util.concurrent.TimeUnit

/**
 * Defense-in-depth: runs every ~30 min, checks if alarms have stopped firing
 * during the user's active window, and rebuilds the schedule if so. Catches
 * the case where aggressive OEM battery savers (MIUI, ColorOS, etc.) silently
 * kill AlarmManager entries.
 */
class WatchdogWorker(ctx: Context, params: WorkerParameters) : Worker(ctx, params) {

    override fun doWork(): Result {
        try {
            val ctx = applicationContext
            val config = ScheduleEngine.loadConfig(ctx) ?: return Result.success()
            val pool = ScheduleEngine.loadPool(ctx)
            if (pool.isEmpty()) return Result.success()

            val prefs = ctx.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val now = System.currentTimeMillis()
            val lastFire = prefs.getLong(ScheduleEngine.KEY_LAST_FIRE_MS, 0L)
            val latestScheduled = prefs.getLong(ScheduleEngine.KEY_LATEST_SCHEDULED_MS, 0L)

            // Are we currently inside the user's active window?
            val cal = Calendar.getInstance().apply { timeInMillis = now }
            val nowMins = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)
            val inWindow = nowMins in config.startMins until config.endMins

            // Heuristics for "schedule is dead":
            // 1) We're in the active window but no fire happened in 3 intervals
            // 2) The tail of the queue is in the past (everything fired, nothing refilled)
            val intervalMs = config.intervalMins * 60_000L
            val staleByFire = inWindow && lastFire > 0L && (now - lastFire) > intervalMs * 3
            val staleByQueue = latestScheduled in 1..now

            if (staleByFire || staleByQueue) {
                ScheduleEngine.rescheduleAll(ctx)
            }

            // Pre-fetch pronunciation MP3s so audio is ready when alarms fire
            // even if the device is offline at that moment.
            ScheduleEngine.prefetchAudio(ctx, count = 20)

            return Result.success()
        } catch (_: Exception) {
            return Result.retry()
        }
    }

    companion object {
        const val WORK_NAME = "eled_vocab_watchdog"

        fun enqueuePeriodic(ctx: Context) {
            val request = PeriodicWorkRequestBuilder<WatchdogWorker>(30, TimeUnit.MINUTES)
                .setConstraints(Constraints.Builder().build())
                .build()
            WorkManager.getInstance(ctx).enqueueUniquePeriodicWork(
                WORK_NAME,
                ExistingPeriodicWorkPolicy.UPDATE,
                request
            )
        }

        fun cancel(ctx: Context) {
            WorkManager.getInstance(ctx).cancelUniqueWork(WORK_NAME)
        }
    }
}
