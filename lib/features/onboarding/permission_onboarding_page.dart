import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'permission_provider.dart';

class PermissionOnboardingPage extends ConsumerStatefulWidget {
  const PermissionOnboardingPage({super.key});

  @override
  ConsumerState<PermissionOnboardingPage> createState() => _PermissionOnboardingPageState();
}

class _PermissionOnboardingPageState extends ConsumerState<PermissionOnboardingPage> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Re-check permissions whenever the user returns to the app from System settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(permissionNotifierProvider.notifier).checkPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionNotifierProvider);
    final notifier = ref.read(permissionNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "reFine Setup",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "reFine requires a few key permissions to work offline as a focused launcher.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // 1. Accessibility Service (Critical)
                    _buildPermissionCard(
                      title: "Accessibility Service",
                      description: "Monitors app changes to run the locker screen instantly. Note: On Android 13+, if settings are disabled, go to App Info -> Three dots (top right) -> click 'Allow restricted settings' first.",
                      isGranted: permissions.accessibilityService,
                      onPressed: () {
                        ref.read(permissionNotifierProvider.notifier).launcherService.openAccessibilitySettings();
                      },
                    ),

                    // 2. Draw Over Apps (Critical)
                    _buildPermissionCard(
                      title: "Display Over Other Apps",
                      description: "Allows reFine to draw the lock overlay screen when time limits are exceeded.",
                      isGranted: permissions.systemAlertWindow,
                      onPressed: () {
                        ref.read(permissionNotifierProvider.notifier).launcherService.openSystemAlertWindowSettings();
                      },
                    ),

                    // 3. Usage Stats Access (Critical)
                    _buildPermissionCard(
                      title: "App Usage Statistics",
                      description: "Allows reFine to track active app times locally to calculate limits.",
                      isGranted: permissions.usageStats,
                      onPressed: () {
                        ref.read(permissionNotifierProvider.notifier).launcherService.openUsageStatsSettings();
                      },
                    ),

                    // 4. Default Home Launcher (Optional but Recommended)
                    _buildPermissionCard(
                      title: "Default Home Screen",
                      description: "Make reFine your default home interface so it opens when pressing the Home button.",
                      isGranted: permissions.defaultLauncher,
                      onPressed: () {
                        ref.read(permissionNotifierProvider.notifier).launcherService.openDefaultHomeSettings();
                      },
                    ),

                    // 5. Battery Optimization Exempt (Optional)
                    _buildPermissionCard(
                      title: "Ignore Battery Optimization",
                      description: "Prevents Android from stopping reFine's background scheduler alarms.",
                      isGranted: permissions.batteryOptimization,
                      onPressed: () {
                        ref.read(permissionNotifierProvider.notifier).launcherService.openBatteryOptimizationSettings();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: Text(
                  permissions.allCriticalGranted
                      ? "All critical permissions enabled."
                      : "Please enable all critical permissions to continue.",
                  style: TextStyle(
                    color: permissions.allCriticalGranted ? Colors.green : Colors.white24,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Enter Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: permissions.allCriticalGranted ? Colors.white : Colors.white12,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: permissions.allCriticalGranted
                      ? () {
                          // Double check state refresh
                          notifier.checkPermissions();
                        }
                      : null,
                  child: Text(
                    "ENTER REFINE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: permissions.allCriticalGranted ? Colors.black : Colors.white24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: isGranted ? const Color(0xFF142416) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isGranted ? Colors.green.withOpacity(0.3) : Colors.white10),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isGranted ? Colors.green.shade300 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isGranted ? Colors.white60 : Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isGranted ? Colors.green : Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onPressed,
                child: Text(
                  isGranted ? "Active" : "Enable",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
