package com.example.refine.services

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import com.example.refine.MainActivity
import org.json.JSONArray
import org.json.JSONObject
import java.lang.ref.WeakReference
import java.util.HashMap

class AppLockAccessibilityService : AccessibilityService() {

    data class LockedAppNative(
        val packageName: String,
        val dailyLimitMinutes: Int,
        var todayUsageSeconds: Int,
        var bypassUntil: Long
    )

    companion object {
        private var serviceRef: WeakReference<AppLockAccessibilityService>? = null
        private val lockedAppsMap = HashMap<String, LockedAppNative>()

        private fun saveLockedAppsToPrefs(context: Context, appsJson: String) {
            val prefs = context.getSharedPreferences("refine_locks", Context.MODE_PRIVATE)
            prefs.edit().putString("locked_apps_list", appsJson).apply()
        }

        fun loadLockedAppsFromPrefs(context: Context) {
            val prefs = context.getSharedPreferences("refine_locks", Context.MODE_PRIVATE)
            val appsJson = prefs.getString("locked_apps_list", null) ?: return
            try {
                val jsonArray = JSONArray(appsJson)
                lockedAppsMap.clear()
                for (i in 0 until jsonArray.length()) {
                    val obj = jsonArray.getJSONObject(i)
                    val pkgName = obj.optString("packageName") ?: continue
                    val limit = obj.optInt("dailyLimitMinutes", 0)
                    val usageMinutes = obj.optInt("todayUsageMinutes", 0)
                    val bypass = obj.optLong("bypassUntil", 0L)
                    
                    lockedAppsMap[pkgName] = LockedAppNative(
                        packageName = pkgName,
                        dailyLimitMinutes = limit,
                        todayUsageSeconds = usageMinutes * 60,
                        bypassUntil = bypass
                    )
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        // Update locked app list from Flutter MethodChannel
        fun updateLockedApps(context: Context, apps: List<Map<String, Any>>) {
            // Backup existing in-memory usage seconds to preserve precision
            val oldUsageSeconds = HashMap<String, Int>()
            for (app in lockedAppsMap.values) {
                oldUsageSeconds[app.packageName] = app.todayUsageSeconds
            }

            lockedAppsMap.clear()
            val jsonArray = JSONArray()
            for (app in apps) {
                val pkgName = app["packageName"] as? String ?: continue
                val limit = (app["dailyLimitMinutes"] as? Number)?.toInt() ?: 0
                val usageMinutes = (app["todayUsageMinutes"] as? Number)?.toInt() ?: 0
                val bypass = (app["bypassUntil"] as? Number)?.toLong() ?: 0L
                
                val prevSeconds = oldUsageSeconds[pkgName] ?: 0
                val finalSeconds = if (usageMinutes == 0) 0 else maxOf(prevSeconds, usageMinutes * 60)

                lockedAppsMap[pkgName] = LockedAppNative(
                    packageName = pkgName,
                    dailyLimitMinutes = limit,
                    todayUsageSeconds = finalSeconds,
                    bypassUntil = bypass
                )

                val obj = JSONObject().apply {
                    put("packageName", pkgName)
                    put("dailyLimitMinutes", limit)
                    put("todayUsageMinutes", finalSeconds / 60)
                    put("bypassUntil", bypass)
                }
                jsonArray.put(obj)
            }
            saveLockedAppsToPrefs(context, jsonArray.toString())
            // Trigger check on active package
            serviceRef?.get()?.checkActiveLock()
        }

        // Return usage logs to Flutter
        fun getUpdatedUsage(): List<Map<String, Any>> {
            val list = ArrayList<Map<String, Any>>()
            for (app in lockedAppsMap.values) {
                val map = HashMap<String, Any>()
                map["packageName"] = app.packageName
                map["todayUsageMinutes"] = app.todayUsageSeconds / 60
                list.add(map)
            }
            return list
        }
    }

    private var activePackageName: String? = null
    private var previousPackageName: String? = null
    private var overlayView: View? = null
    private val handler = Handler(Looper.getMainLooper())

    private val excludedPackages = setOf(
        "com.example.refine",
        "com.android.settings",
        "com.android.systemui",
        "com.android.phone",
        "com.android.packageinstaller",
        "com.google.android.packageinstaller",
        "com.google.android.inputmethod.latin",
        "com.sec.android.app.launcher", // Samsung TouchWiz / One UI Home
        "com.miui.home" // Xiaomi System Launcher
    )

    private var lastCheckDay = -1

    private fun checkMidnightReset() {
        val calendar = java.util.Calendar.getInstance()
        val currentDay = calendar.get(java.util.Calendar.DAY_OF_YEAR)
        if (lastCheckDay == -1) {
            val prefs = getSharedPreferences("refine_locks", Context.MODE_PRIVATE)
            lastCheckDay = prefs.getInt("last_reset_day", currentDay)
        }
        if (currentDay != lastCheckDay) {
            for (app in lockedAppsMap.values) {
                app.todayUsageSeconds = 0
                app.bypassUntil = 0L
            }
            lastCheckDay = currentDay
            val prefs = getSharedPreferences("refine_locks", Context.MODE_PRIVATE)
            prefs.edit().putInt("last_reset_day", currentDay).apply()
            
            val jsonArray = JSONArray()
            for (app in lockedAppsMap.values) {
                val obj = JSONObject().apply {
                    put("packageName", app.packageName)
                    put("dailyLimitMinutes", app.dailyLimitMinutes)
                    put("todayUsageMinutes", 0)
                    put("bypassUntil", 0L)
                }
                jsonArray.put(obj)
            }
            prefs.edit().putString("locked_apps_list", jsonArray.toString()).apply()
            
            MainActivity.notifyPackageChange()
        }
    }

    private val timerRunnable = object : Runnable {
        override fun run() {
            // Dynamically recover active package from root window if state was temporarily lost
            val currentPkg = rootInActiveWindow?.packageName?.toString() ?: activePackageName
            if (currentPkg != null && currentPkg != activePackageName) {
                activePackageName = currentPkg
            }

            checkMidnightReset()

            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            val isScreenInteractive = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
                pm.isInteractive
            } else {
                @Suppress("DEPRECATION")
                pm.isScreenOn
            }

            if (isScreenInteractive) {
                activePackageName?.let { pkg ->
                    val app = lockedAppsMap[pkg]
                    if (app != null && !excludedPackages.contains(pkg)) {
                        val now = System.currentTimeMillis()
                        if (now > app.bypassUntil) {
                            app.todayUsageSeconds += 5
                            // Trigger check
                            checkActiveLock()
                        }
                    }
                }
            }
            handler.postDelayed(this, 5000)
        }
    }

    override fun onCreate() {
        super.onCreate()
        serviceRef = WeakReference(this)
        loadLockedAppsFromPrefs(this)
        handler.post(timerRunnable)
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(timerRunnable)
        removeOverlay()
        serviceRef = null
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val pkgName = event.packageName?.toString() ?: return
        
        // Exclude our own package only when overlay is active to prevent layout loop crash,
        // but allow transitions when returning to the launcher Home screen
        if (pkgName == "com.example.refine" && overlayView != null) return
        
        if (pkgName == previousPackageName) return
        previousPackageName = pkgName
        
        activePackageName = pkgName
        checkActiveLock()
    }

    override fun onInterrupt() {}

    private fun checkActiveLock() {
        val pkg = activePackageName ?: return
        if (excludedPackages.contains(pkg)) {
            removeOverlay()
            return
        }

        val app = lockedAppsMap[pkg]
        if (app != null) {
            val now = System.currentTimeMillis()
            val usageMinutes = app.todayUsageSeconds / 60
            
            if (usageMinutes >= app.dailyLimitMinutes && now > app.bypassUntil) {
                // Show blocking overlay if overlay permission is granted
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Settings.canDrawOverlays(this)) {
                    showOverlay(pkg)
                }
            } else {
                removeOverlay()
            }
        } else {
            removeOverlay()
        }
    }

    private fun showOverlay(packageName: String) {
        if (overlayView != null) return // Already showing

        val wm = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        
        val layoutType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            layoutType,
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )

        // Programmatic View Layout
        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#0A0A0A"))
            setPadding(48, 48, 48, 48)
        }

        val titleView = TextView(this).apply {
            text = "reFine Lock"
            textSize = 28f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 16)
        }

        val descView = TextView(this).apply {
            text = "You have exceeded your daily limit for this application."
            textSize = 14f
            setTextColor(Color.parseColor("#808080"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 48)
        }

        container.addView(titleView)
        container.addView(descView)

        // Add Bypass buttons
        val minutesOptions = listOf(15, 30, 60)
        for (mins in minutesOptions) {
            val button = Button(this).apply {
                text = "Emergency Bypass ($mins min)"
                setTextColor(Color.BLACK)
                setBackgroundColor(Color.WHITE)
                setPadding(0, 12, 0, 12)
                
                val layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    setMargins(0, 0, 0, 16)
                }
                this.layoutParams = layoutParams

                setOnClickListener {
                    applyBypass(packageName, mins)
                }
            }
            container.addView(button)
        }

        // Add Close/Go Home button
        val closeButton = Button(this).apply {
            text = "Go Home Screen"
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor("#222222"))
            setPadding(0, 12, 0, 12)
            
            val layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            this.layoutParams = layoutParams

            setOnClickListener {
                goHome()
            }
        }
        container.addView(closeButton)

        overlayView = container
        wm.addView(overlayView, params)
    }

    private fun applyBypass(packageName: String, minutes: Int) {
        val app = lockedAppsMap[packageName]
        if (app != null) {
            val bypassMillis = minutes * 60000L
            app.bypassUntil = System.currentTimeMillis() + bypassMillis
            
            // Notify MainActivity to write journal log in Flutter
            MainActivity.notifyPackageChange() // Trigger general sync
            // Trigger specific bypass log channel event
            MainActivity.notifyEmergencyBypass(packageName, minutes)
        }
        removeOverlay()
    }

    private fun goHome() {
        removeOverlay()
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(intent)
    }

    private fun removeOverlay() {
        overlayView?.let {
            val wm = getSystemService(Context.WINDOW_SERVICE) as WindowManager
            try {
                wm.removeView(it)
            } catch (e: Exception) {}
            overlayView = null
        }
    }
}
