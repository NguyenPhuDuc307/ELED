package com.nguyenphuduc.eled

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Rebuilds the alarm queue after device reboot or app update — both events clear
 * all scheduled AlarmManager entries.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON",
            "android.intent.action.LOCKED_BOOT_COMPLETED" -> {
                try {
                    VocabNotificationReceiver.ensureChannel(context)
                    ScheduleEngine.rescheduleAll(context)
                    WatchdogWorker.enqueuePeriodic(context)
                } catch (_: Exception) {}
            }
        }
    }
}
