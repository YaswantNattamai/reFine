import 'package:flutter/services.dart';
import 'app_info.dart';

class LauncherService {
  static const MethodChannel _channel = MethodChannel('com.example.refine/launcher');

  void setLauncherCallbacks({
    required void Function() onAppsChanged,
    required void Function(String packageName, int minutes) onEmergencyBypass,
  }) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'appsChanged':
          onAppsChanged();
          break;
        case 'emergencyBypassLogged':
          final args = call.arguments as Map<dynamic, dynamic>;
          final packageName = args['packageName'] as String;
          final minutes = args['minutes'] as int;
          onEmergencyBypass(packageName, minutes);
          break;
      }
    });
  }

  // Query installed apps
  Future<List<AppInfo>> getInstalledApps() async {
    try {
      final List<dynamic>? apps = await _channel.invokeMethod<List<dynamic>>('getInstalledApps');
      if (apps == null) return [];
      return apps.map((item) => AppInfo.fromMap(item as Map<dynamic, dynamic>)).toList();
    } on PlatformException catch (e) {
      print("Error fetching apps: $e");
      return [];
    }
  }

  // Launch a package
  Future<bool> launchApp(String packageName) async {
    try {
      final bool? success = await _channel.invokeMethod<bool>('launchApp', {'packageName': packageName});
      return success ?? false;
    } on PlatformException catch (e) {
      print("Error launching app $packageName: $e");
      return false;
    }
  }

  // Open default home system settings screen
  Future<bool> openDefaultHomeSettings() async {
    try {
      final bool? success = await _channel.invokeMethod<bool>('openDefaultHomeSettings');
      return success ?? false;
    } on PlatformException catch (e) {
      print("Error opening home settings: $e");
      return false;
    }
  }

  // Check if reFine is the default launcher
  Future<bool> isDefaultLauncher() async {
    try {
      final bool? isDefault = await _channel.invokeMethod<bool>('isDefaultLauncher');
      return isDefault ?? false;
    } on PlatformException catch (e) {
      print("Error checking default launcher: $e");
      return false;
    }
  }

  // Accessibility Service states
  Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final bool? enabled = await _channel.invokeMethod<bool>('isAccessibilityServiceEnabled');
      return enabled ?? false;
    } on PlatformException catch (e) {
      print("Error checking accessibility: $e");
      return false;
    }
  }

  Future<bool> openAccessibilitySettings() async {
    try {
      final bool? success = await _channel.invokeMethod<bool>('openAccessibilitySettings');
      return success ?? false;
    } on PlatformException catch (e) {
      print("Error opening accessibility settings: $e");
      return false;
    }
  }

  // Overlay window settings (Draw over other apps)
  Future<bool> isSystemAlertWindowGranted() async {
    try {
      final bool? granted = await _channel.invokeMethod<bool>('isSystemAlertWindowGranted');
      return granted ?? false;
    } on PlatformException catch (e) {
      print("Error checking overlay: $e");
      return false;
    }
  }

  Future<bool> openSystemAlertWindowSettings() async {
    try {
      final bool? success = await _channel.invokeMethod<bool>('openSystemAlertWindowSettings');
      return success ?? false;
    } on PlatformException catch (e) {
      print("Error opening overlay settings: $e");
      return false;
    }
  }

  // Usage access settings (UsageStatsManager)
  Future<bool> isUsageStatsGranted() async {
    try {
      final bool? granted = await _channel.invokeMethod<bool>('isUsageStatsGranted');
      return granted ?? false;
    } on PlatformException catch (e) {
      print("Error checking usage stats: $e");
      return false;
    }
  }

  Future<bool> openUsageStatsSettings() async {
    try {
      final bool? success = await _channel.invokeMethod<bool>('openUsageStatsSettings');
      return success ?? false;
    } on PlatformException catch (e) {
      print("Error opening usage stats settings: $e");
      return false;
    }
  }

  // Battery optimization exemptions
  Future<bool> isBatteryOptimizationIgnored() async {
    try {
      final bool? ignored = await _channel.invokeMethod<bool>('isBatteryOptimizationIgnored');
      return ignored ?? false;
    } on PlatformException catch (e) {
      print("Error checking battery settings: $e");
      return false;
    }
  }

  Future<bool> openBatteryOptimizationSettings() async {
    try {
      final bool? success = await _channel.invokeMethod<bool>('openBatteryOptimizationSettings');
      return success ?? false;
    } on PlatformException catch (e) {
      print("Error opening battery settings: $e");
      return false;
    }
  }

  // Sync locked app rules with native app blocker
  Future<bool> updateLockedApps(List<Map<String, dynamic>> apps) async {
    try {
      final bool? success = await _channel.invokeMethod<bool>('updateLockedApps', {'apps': apps});
      return success ?? false;
    } on PlatformException catch (e) {
      print("Error updating locked apps in native: $e");
      return false;
    }
  }

  // Fetch usage logs updated by accessibility service
  Future<List<Map<dynamic, dynamic>>> getUsageLogs() async {
    try {
      final List<dynamic>? usage = await _channel.invokeMethod<List<dynamic>>('getUsageLogs');
      if (usage == null) return [];
      return usage.map((item) => item as Map<dynamic, dynamic>).toList();
    } on PlatformException catch (e) {
      print("Error fetching usage logs: $e");
      return [];
    }
  }
}
