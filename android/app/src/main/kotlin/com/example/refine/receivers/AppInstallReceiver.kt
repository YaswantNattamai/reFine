package com.example.refine.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.example.refine.MainActivity

class AppInstallReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        if (action == Intent.ACTION_PACKAGE_ADDED || action == Intent.ACTION_PACKAGE_REMOVED) {
            MainActivity.notifyPackageChange()
        }
    }
}
