package com.example.refine

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.app.AppOpsManager
import android.os.Process
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList
import java.util.HashMap
import java.lang.ref.WeakReference
import com.example.refine.services.AppLockAccessibilityService

class MainActivity : FlutterActivity() {
    private val CHANNEL_NAME = "com.example.refine/launcher"
    private var methodChannel: MethodChannel? = null

    companion object {
        private var activityRef: WeakReference<MainActivity>? = null

        fun notifyPackageChange() {
            val activity = activityRef?.get()
            activity?.runOnUiThread {
                activity.methodChannel?.invokeMethod("appsChanged", null)
            }
        }

        fun notifyEmergencyBypass(packageName: String, minutes: Int) {
            val activity = activityRef?.get()
            activity?.runOnUiThread {
                val map = HashMap<String, Any>()
                map["packageName"] = packageName
                map["minutes"] = minutes
                activity.methodChannel?.invokeMethod("emergencyBypassLogged", map)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        activityRef = WeakReference(this)
    }

    override fun onDestroy() {
        super.onDestroy()
        activityRef = null
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        methodChannel = channel
        
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    val apps = getInstalledAppsList()
                    result.success(apps)
                }
                "setBirthdayAlarms" -> {
                    val alarms = call.argument<List<Map<String, Any>>>("birthdays")
                    if (alarms != null) {
                        try {
                            val jsonArray = org.json.JSONArray(alarms)
                            com.example.refine.services.NotificationScheduler.setBirthdayAlarms(this, jsonArray.toString())
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("JSON_ERROR", "Could not serialize birthday alarms", e.message)
                        }
                    } else {
                        result.error("BAD_ARGS", "Missing birthdays list", null)
                    }
                }
                "updateLockedApps" -> {
                    val appsList = call.argument<List<Map<String, Any>>>("apps")
                    if (appsList != null) {
                        AppLockAccessibilityService.updateLockedApps(appsList)
                        result.success(true)
                    } else {
                        result.error("BAD_ARGS", "Missing apps list", null)
                    }
                }
                "getUsageLogs" -> {
                    val usage = AppLockAccessibilityService.getUpdatedUsage()
                    result.success(usage)
                }
                "launchApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
                        if (launchIntent != null) {
                            startActivity(launchIntent)
                            result.success(true)
                        } else {
                            result.error("UNLAUNCHABLE", "App cannot be launched", null)
                        }
                    } else {
                        result.error("BAD_ARGS", "Missing packageName", null)
                    }
                }
                "openDefaultHomeSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_HOME_SETTINGS)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            val intent = Intent(Settings.ACTION_SETTINGS)
                            startActivity(intent)
                            result.success(true)
                        } catch (e2: Exception) {
                            result.error("FAILED", "Could not open settings", e2.message)
                        }
                    }
                }
                "isDefaultLauncher" -> {
                    result.success(isNavbarDefaultLauncher())
                }
                "isAccessibilityServiceEnabled" -> {
                    result.success(isAccessibilityServiceEnabled(this, AppLockAccessibilityService::class.java))
                }
                "openAccessibilitySettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("FAILED", "Could not open Accessibility Settings", e.message)
                    }
                }
                "isSystemAlertWindowGranted" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        result.success(Settings.canDrawOverlays(this))
                    } else {
                        result.success(true)
                    }
                }
                "openSystemAlertWindowSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        try {
                            val intent = Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName")
                            )
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                            startActivity(intent)
                            result.success(true)
                        }
                    } else {
                        result.success(true)
                    }
                }
                "isUsageStatsGranted" -> {
                    result.success(isUsageStatsGranted())
                }
                "openUsageStatsSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("FAILED", "Could not open usage access settings", e.message)
                    }
                }
                "isBatteryOptimizationIgnored" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        result.success(pm.isIgnoringBatteryOptimizations(packageName))
                    } else {
                        result.success(true)
                    }
                }
                "openBatteryOptimizationSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        try {
                            val intent = Intent(
                                Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                                Uri.parse("package:$packageName")
                            )
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                            startActivity(intent)
                            result.success(true)
                        }
                    } else {
                        result.success(true)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getInstalledAppsList(): List<Map<String, String>> {
        val list = ArrayList<Map<String, String>>()
        val intent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val resolveInfoList = packageManager.queryIntentActivities(intent, 0)
        for (resolveInfo in resolveInfoList) {
            val appInfo = HashMap<String, String>()
            val label = resolveInfo.loadLabel(packageManager).toString()
            val packName = resolveInfo.activityInfo.packageName
            appInfo["name"] = label
            appInfo["packageName"] = packName
            list.add(appInfo)
        }
        return list
    }

    private fun isNavbarDefaultLauncher(): Boolean {
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
        }
        val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
        return resolveInfo?.activityInfo?.packageName == packageName
    }

    private fun isAccessibilityServiceEnabled(context: Context, service: Class<*>): Boolean {
        val expectedComponentName = android.content.ComponentName(context, service)
        val enabledServicesSetting = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val colonSplitter = android.text.TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServicesSetting)

        while (colonSplitter.hasNext()) {
            val componentNameString = colonSplitter.next()
            val enabledService = android.content.ComponentName.unflattenFromString(componentNameString)
            if (enabledService != null && enabledService == expectedComponentName) {
                return true
            }
        }
        return false
    }

    private fun isUsageStatsGranted(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        } else {
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }
}
