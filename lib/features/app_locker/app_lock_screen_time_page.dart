import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_lock_provider.dart';
import '../launcher/launcher_provider.dart';
import '../launcher/app_info.dart';
import '../../database/collections/locked_app.dart';

// Standalone diagnostics + configuration panel for App Locker and Screen
// Time, split out of System Settings so these (harder to verify without a
// device) features can be checked and tuned on their own.
class AppLockScreenTimePage extends ConsumerStatefulWidget {
  const AppLockScreenTimePage({super.key});

  @override
  ConsumerState<AppLockScreenTimePage> createState() => _AppLockScreenTimePageState();
}

class _AppLockScreenTimePageState extends ConsumerState<AppLockScreenTimePage> with WidgetsBindingObserver {
  final _appSearchController = TextEditingController();
  String _appSearchQuery = "";

  bool _accessibilityEnabled = false;
  bool _usageStatsGranted = false;
  bool _overlayGranted = false;
  bool _permissionsLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissionStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissionStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appSearchController.dispose();
    super.dispose();
  }

  Future<void> _refreshPermissionStatus() async {
    final service = ref.read(launcherServiceProvider);
    final results = await Future.wait([
      service.isAccessibilityServiceEnabled(),
      service.isUsageStatsGranted(),
      service.isSystemAlertWindowGranted(),
    ]);
    if (!mounted) return;
    setState(() {
      _accessibilityEnabled = results[0];
      _usageStatsGranted = results[1];
      _overlayGranted = results[2];
      _permissionsLoaded = true;
    });
    ref.read(appLockNotifierProvider.notifier).resyncFromNative();
  }

  @override
  Widget build(BuildContext context) {
    final launcherState = ref.watch(launcherNotifierProvider);
    final lockedApps = ref.watch(appLockNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("App Lock & Screen Time", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPermissionStatus,
        color: Colors.white,
        backgroundColor: const Color(0xFF161616),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text(
              "PERMISSIONS & STATUS",
              style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            _buildPermissionsCard(context),
            const SizedBox(height: 24),

            const Text(
              "TODAY'S SCREEN TIME",
              style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            _buildScreenTimeCard(launcherState.apps, lockedApps),
            const SizedBox(height: 24),

            const Text(
              "APP LOCK LIMITS",
              style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            _buildAppLockerList(context, launcherState, lockedApps),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsCard(BuildContext context) {
    final service = ref.read(launcherServiceProvider);

    if (!_permissionsLoaded) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Card(
      color: const Color(0xFF161616),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildPermissionRow(
            title: "Accessibility Service",
            subtitle: "Required to detect when a locked app is opened",
            granted: _accessibilityEnabled,
            onFix: () async {
              await service.openAccessibilitySettings();
              _refreshPermissionStatus();
            },
          ),
          const Divider(color: Colors.white10, height: 1),
          _buildPermissionRow(
            title: "Usage Access",
            subtitle: "Required to track screen time per app",
            granted: _usageStatsGranted,
            onFix: () async {
              await service.openUsageStatsSettings();
              _refreshPermissionStatus();
            },
          ),
          const Divider(color: Colors.white10, height: 1),
          _buildPermissionRow(
            title: "Display Over Other Apps",
            subtitle: "Required to show the lock screen overlay",
            granted: _overlayGranted,
            onFix: () async {
              await service.openSystemAlertWindowSettings();
              _refreshPermissionStatus();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRow({
    required String title,
    required String subtitle,
    required bool granted,
    required VoidCallback onFix,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      leading: Icon(
        granted ? Icons.check_circle : Icons.error_outline,
        color: granted ? Colors.green : Colors.redAccent,
      ),
      trailing: granted
          ? null
          : TextButton(
              onPressed: onFix,
              child: const Text("FIX", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
    );
  }

  Widget _buildScreenTimeCard(List<AppInfo> apps, List<LockedApp> lockedApps) {
    if (!_usageStatsGranted) {
      return Card(
        color: const Color(0xFF161616),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white10),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Grant Usage Access above to see today's per-app screen time here.",
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
      );
    }

    final tracked = lockedApps.where((a) => a.todayUsageMinutes > 0).toList()
      ..sort((a, b) => b.todayUsageMinutes.compareTo(a.todayUsageMinutes));

    if (tracked.isEmpty) {
      return Card(
        color: const Color(0xFF161616),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white10),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "No usage recorded yet today for locked apps. Lock an app below to start tracking its screen time.",
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
      );
    }

    return Card(
      color: const Color(0xFF161616),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white10),
      ),
      child: Column(
        children: [
          for (int i = 0; i < tracked.length; i++) ...[
            if (i > 0) const Divider(color: Colors.white10, height: 1),
            _buildScreenTimeRow(tracked[i], apps),
          ],
        ],
      ),
    );
  }

  Widget _buildScreenTimeRow(LockedApp lockedApp, List<AppInfo> apps) {
    String appName = lockedApp.packageName;
    for (final app in apps) {
      if (app.packageName == lockedApp.packageName) {
        appName = app.name;
        break;
      }
    }
    final overLimit = lockedApp.todayUsageMinutes >= lockedApp.dailyLimitMinutes;

    return ListTile(
      title: Text(appName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(
        "Limit: ${lockedApp.dailyLimitMinutes} mins/day",
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
      trailing: Text(
        "${lockedApp.todayUsageMinutes} min",
        style: TextStyle(
          color: overLimit ? Colors.redAccent : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAppLockerList(BuildContext context, LauncherState launcherState, List<LockedApp> lockedApps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _appSearchController,
          style: const TextStyle(color: Colors.white),
          onChanged: (val) {
            setState(() {
              _appSearchQuery = val.toLowerCase().trim();
            });
          },
          decoration: InputDecoration(
            hintText: "Search apps...",
            hintStyle: const TextStyle(color: Colors.white30),
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF161616),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (launcherState.isLoading)
          const Center(child: CircularProgressIndicator(color: Colors.white))
        else
          _buildAppList(context, launcherState.apps, lockedApps),
      ],
    );
  }

  Widget _buildAppList(BuildContext context, List<AppInfo> apps, List<LockedApp> lockedApps) {
    final filteredApps = apps.where((app) {
      return app.name.toLowerCase().contains(_appSearchQuery) ||
          app.packageName.toLowerCase().contains(_appSearchQuery);
    }).toList();

    if (filteredApps.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text("No apps found", style: TextStyle(color: Colors.white30))),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredApps.length,
      separatorBuilder: (context, index) => const Divider(color: Colors.white10),
      itemBuilder: (context, index) {
        final app = filteredApps[index];
        LockedApp? lockedApp;
        for (var la in lockedApps) {
          if (la.packageName == app.packageName) {
            lockedApp = la;
            break;
          }
        }

        final isLocked = lockedApp != null;
        final limit = isLocked ? lockedApp.dailyLimitMinutes : 0;

        return ListTile(
          key: ValueKey(app.packageName),
          contentPadding: EdgeInsets.zero,
          title: Text(
            app.name,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            isLocked ? "Limit: $limit mins/day" : "Unrestricted",
            style: TextStyle(
              color: isLocked ? Colors.redAccent : Colors.white38,
              fontSize: 12,
            ),
          ),
          trailing: Icon(
            isLocked ? Icons.lock : Icons.lock_open,
            color: isLocked ? Colors.redAccent : Colors.white30,
          ),
          onTap: () => _showAppLimitDialog(context, app.name, app.packageName, limit, isLocked),
        );
      },
    );
  }

  void _showAppLimitDialog(BuildContext context, String appName, String packageName, int currentLimit, bool isLocked) {
    int localLimit = isLocked ? currentLimit : 15;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF161616),
          title: Text("Lock Limit: $appName", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Configure daily usage duration. App locker overlay pops up after this threshold is crossed.",
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                    onPressed: () {
                      if (localLimit > 5) {
                        setDialogState(() => localLimit -= 5);
                      }
                    },
                  ),
                  Text(
                    "$localLimit min",
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    onPressed: () {
                      if (localLimit < 360) {
                        setDialogState(() => localLimit += 5);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            if (isLocked)
              TextButton(
                onPressed: () {
                  ref.read(appLockNotifierProvider.notifier).unlockApp(packageName);
                  Navigator.pop(context);
                },
                child: const Text("REMOVE LIMIT", style: TextStyle(color: Colors.redAccent)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                ref.read(appLockNotifierProvider.notifier).lockApp(packageName, localLimit);
                Navigator.pop(context);
              },
              child: const Text("SET LIMIT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
