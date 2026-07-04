import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../launcher/launcher_service.dart';
import '../launcher/launcher_provider.dart';

class PermissionStates {
  final bool defaultLauncher;
  final bool systemAlertWindow;
  final bool accessibilityService;
  final bool usageStats;
  final bool batteryOptimization;

  PermissionStates({
    required this.defaultLauncher,
    required this.systemAlertWindow,
    required this.accessibilityService,
    required this.usageStats,
    required this.batteryOptimization,
  });

  bool get allCriticalGranted =>
      systemAlertWindow &&
      accessibilityService &&
      usageStats;
}

class PermissionNotifier extends StateNotifier<PermissionStates> {
  final LauncherService launcherService;

  PermissionNotifier(this.launcherService)
      : super(PermissionStates(
          defaultLauncher: false,
          systemAlertWindow: false,
          accessibilityService: false,
          usageStats: false,
          batteryOptimization: false,
        )) {
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    final defaultLauncher = await launcherService.isDefaultLauncher();
    final systemAlert = await launcherService.isSystemAlertWindowGranted();
    final accessibility = await launcherService.isAccessibilityServiceEnabled();
    final usage = await launcherService.isUsageStatsGranted();
    final battery = await launcherService.isBatteryOptimizationIgnored();

    state = PermissionStates(
      defaultLauncher: defaultLauncher,
      systemAlertWindow: systemAlert,
      accessibilityService: accessibility,
      usageStats: usage,
      batteryOptimization: battery,
    );
  }
}

final permissionNotifierProvider = StateNotifierProvider<PermissionNotifier, PermissionStates>((ref) {
  final service = ref.watch(launcherServiceProvider);
  return PermissionNotifier(service);
});
