package com.example.refine.services

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import com.example.refine.receivers.BirthdayAlarmReceiver
import java.util.Calendar

object NotificationScheduler {
    private const val PREFS_NAME = "birthday_prefs"
    private const val KEY_BIRTHDAYS = "birthdays_json"
    private const val ALARM_REQ_CODE_9AM = 9999
    private const val ALARM_REQ_CODE_12AM = 8888

    fun setBirthdayAlarms(context: Context, birthdaysJson: String) {
        // 1. Save to SharedPreferences
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString(KEY_BIRTHDAYS, birthdaysJson).apply()

        // 2. Schedule Daily Check Alarms
        scheduleAllAlarms(context)
    }

    fun scheduleAllAlarms(context: Context) {
        scheduleDailyAlarm(context, 9, ALARM_REQ_CODE_9AM)
        scheduleDailyAlarm(context, 0, ALARM_REQ_CODE_12AM)
    }

    fun scheduleDailyAlarm(context: Context, hour: Int, reqCode: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, BirthdayAlarmReceiver::class.java).apply {
            putExtra("alarm_hour", hour)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            reqCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Cancel existing daily alarm
        alarmManager.cancel(pendingIntent)

        // Set daily alarm at designated hour
        val calendar = Calendar.getInstance().apply {
            timeInMillis = System.currentTimeMillis()
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            
            // If the time has passed today, schedule for tomorrow
            if (timeInMillis <= System.currentTimeMillis()) {
                add(Calendar.DAY_OF_YEAR, 1)
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                calendar.timeInMillis,
                pendingIntent
            )
        } else {
            alarmManager.setExact(
                AlarmManager.RTC_WAKEUP,
                calendar.timeInMillis,
                pendingIntent
            )
        }
    }
}
