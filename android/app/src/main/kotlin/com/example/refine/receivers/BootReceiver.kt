package com.example.refine.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.example.refine.services.NotificationScheduler

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            NotificationScheduler.scheduleAllAlarms(context)
        }
    }
}
