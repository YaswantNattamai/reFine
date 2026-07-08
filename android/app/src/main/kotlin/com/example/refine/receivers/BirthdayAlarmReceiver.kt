package com.example.refine.receivers

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.example.refine.MainActivity
import com.example.refine.services.NotificationScheduler
import org.json.JSONArray
import java.util.Calendar

class BirthdayAlarmReceiver : BroadcastReceiver() {
    private val CHANNEL_ID = "birthday_alerts"
    private val CHANNEL_NAME = "Birthday Alerts"
    private val PREFS_NAME = "birthday_prefs"
    private val KEY_BIRTHDAYS = "birthdays_json"
    override fun onReceive(context: Context, intent: Intent) {
        // 1. Reschedule for tomorrow
        val hour = intent.getIntExtra("alarm_hour", 9)
        val reqCode = if (hour == 9) 9999 else 8888
        NotificationScheduler.scheduleDailyAlarm(context, hour, reqCode)

        // 2. Check if today is anyone's birthday
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val jsonStr = prefs.getString(KEY_BIRTHDAYS, null) ?: return
        
        try {
            val arr = JSONArray(jsonStr)
            val today = Calendar.getInstance()
            val todayMonth = today.get(Calendar.MONTH) + 1 // 0-indexed month
            val todayDay = today.get(Calendar.DAY_OF_MONTH)

            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                val name = obj.getString("name")
                val month = obj.getInt("month")
                val day = obj.getInt("day")
                val checkedToday = obj.optBoolean("checkedToday", false)

                if (month == todayMonth && day == todayDay && !checkedToday) {
                    showNotification(context, obj.getInt("id"), name)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun showNotification(context: Context, id: Int, name: String) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Create channel for Android O+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Alerts for birthdays today"
            }
            notificationManager.createNotificationChannel(channel)
        }

        val launchIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            id,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("Birthday Alert \uD83C\uDF82")
            .setContentText("Today is $name's birthday! Wish them well!")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)

        notificationManager.notify(id, builder.build())
    }
}
