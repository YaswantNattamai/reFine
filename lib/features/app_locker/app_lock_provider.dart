import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../database/isar_service.dart';
import '../../database/collections/locked_app.dart';
import '../../database/collections/journal_entry.dart';
import '../launcher/launcher_service.dart';
import '../launcher/launcher_provider.dart';

class AppLockNotifier extends StateNotifier<List<LockedApp>> {
  final IsarService _isarService;
  final LauncherService _launcherService;
  Timer? _syncTimer;

  AppLockNotifier(this._isarService, this._launcherService) : super([]) {
    _init();
  }

  void cancelSyncTimer() {
    _syncTimer?.cancel();
  }

  Future<void> _init() async {
    try {
      final isar = await _isarService.db;
      
      // 1. Fetch native logs before any database sync overwrites them
      List<Map<dynamic, dynamic>> nativeLogs = [];
      try {
        nativeLogs = await _launcherService.getUsageLogs();
      } catch (e) {
        print("DEBUG LOCK INIT: failed to get native logs: $e");
      }
      
      final Map<String, int> nativeUsage = {};
      for (final log in nativeLogs) {
        final pkg = log['packageName'] as String?;
        final mins = log['todayUsageMinutes'] as int?;
        if (pkg != null && mins != null) {
          nativeUsage[pkg] = mins;
        }
      }

      // 2. Fetch initial locked apps
      final rawApps = await isar.lockedApps.where().findAll();
      var apps = List<dynamic>.from(rawApps).whereType<LockedApp>().toList();

      // 3. Process each app for midnight reset and merge usage
      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);
      
      bool dbChanged = false;
      await isar.writeTxn(() async {
        for (var app in apps) {
          if (app.lastResetDate == null || app.lastResetDate!.isBefore(todayMidnight)) {
            app.todayUsageMinutes = 0;
            app.bypassUntil = null;
            app.lastResetDate = todayMidnight;
            await isar.lockedApps.put(app);
            dbChanged = true;
          } else {
            final natMins = nativeUsage[app.packageName] ?? 0;
            if (natMins > app.todayUsageMinutes) {
              app.todayUsageMinutes = natMins;
              await isar.lockedApps.put(app);
              dbChanged = true;
            }
          }
        }
      });

      if (dbChanged) {
        final rawAppsUpdated = await isar.lockedApps.where().findAll();
        apps = List<dynamic>.from(rawAppsUpdated).whereType<LockedApp>().toList();
      }

      print("DEBUG LOCK: apps = $apps");
      state = apps;
      _syncToNative(apps);

      // 4. Start periodic sync timer
      _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _performPeriodicSync();
      });

      // 5. Watch changes in Isar to keep native service updated
      isar.lockedApps.watchLazy().listen((_) async {
        try {
          final rawUpdatedApps = await isar.lockedApps.where().findAll();
          final updatedApps = List<dynamic>.from(rawUpdatedApps).whereType<LockedApp>().toList();
          print("DEBUG LOCK LISTEN: updatedApps = $updatedApps");
          state = updatedApps;
          _syncToNative(updatedApps);
        } catch (e, stack) {
          print("DEBUG LOCK LISTEN ERROR: $e");
          print("DEBUG LOCK LISTEN STACK: $stack");
        }
      });
    } catch (e, stack) {
      print("DEBUG LOCK INIT ERROR: $e");
      print("DEBUG LOCK INIT STACK: $stack");
    }
  }

  Future<void> _performPeriodicSync() async {
    try {
      final isar = await _isarService.db;
      final rawApps = await isar.lockedApps.where().findAll();
      final apps = List<dynamic>.from(rawApps).whereType<LockedApp>().toList();

      List<Map<dynamic, dynamic>> nativeLogs = [];
      try {
        nativeLogs = await _launcherService.getUsageLogs();
      } catch (e) {
        print("DEBUG LOCK SYNC: failed to get native logs: $e");
        return;
      }

      final Map<String, int> nativeUsage = {};
      for (final log in nativeLogs) {
        final pkg = log['packageName'] as String?;
        final mins = log['todayUsageMinutes'] as int?;
        if (pkg != null && mins != null) {
          nativeUsage[pkg] = mins;
        }
      }

      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);
      
      await isar.writeTxn(() async {
        for (var app in apps) {
          if (app.lastResetDate == null || app.lastResetDate!.isBefore(todayMidnight)) {
            app.todayUsageMinutes = 0;
            app.bypassUntil = null;
            app.lastResetDate = todayMidnight;
            await isar.lockedApps.put(app);
          } else {
            final natMins = nativeUsage[app.packageName] ?? 0;
            if (natMins > app.todayUsageMinutes) {
              app.todayUsageMinutes = natMins;
              await isar.lockedApps.put(app);
            }
          }
        }
      });
    } catch (e) {
      print("Error in periodic app lock sync: $e");
    }
  }

  Future<void> _syncToNative(List<LockedApp> apps) async {
    final List<Map<String, dynamic>> nativeList = apps.map((app) => {
      'packageName': app.packageName,
      'dailyLimitMinutes': app.dailyLimitMinutes,
      'todayUsageMinutes': app.todayUsageMinutes,
      'bypassUntil': app.bypassUntil?.millisecondsSinceEpoch ?? 0,
    }).toList();
    await _launcherService.updateLockedApps(nativeList);
  }

  // Add/Update a locked app rule
  Future<void> lockApp(String packageName, int dailyLimitMinutes) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      var app = await isar.lockedApps.filter().packageNameEqualTo(packageName).findFirst();
      if (app == null) {
        app = LockedApp()
          ..packageName = packageName
          ..dailyLimitMinutes = dailyLimitMinutes
          ..todayUsageMinutes = 0
          ..lastResetDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      } else {
        app.dailyLimitMinutes = dailyLimitMinutes;
      }
      await isar.lockedApps.put(app);
    });
  }

  // Remove lock rule
  Future<void> unlockApp(String packageName) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.lockedApps.filter().packageNameEqualTo(packageName).deleteAll();
    });
  }

  // Handle emergency bypass logging from native overlay click
  Future<void> handleEmergencyBypass(String packageName, int minutes) async {
    final isar = await _isarService.db;
    
    // Try to extract a clean app name from package (e.g. com.google.android.youtube -> youtube)
    String cleanName = packageName.split('.').last;
    if (cleanName.length > 1) {
      cleanName = cleanName[0].toUpperCase() + cleanName.substring(1);
    }

    final entry = JournalEntry()
      ..title = "Emergency Bypass: $cleanName"
      ..content = "USED $cleanName FOR EXTRA $minutes minutes."
      ..date = DateTime.now()
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.journalEntrys.put(entry);
      
      // Update bypass timestamp in Isar
      final app = await isar.lockedApps.filter().packageNameEqualTo(packageName).findFirst();
      if (app != null) {
        app.bypassUntil = DateTime.now().add(Duration(minutes: minutes));
        await isar.lockedApps.put(app);
      }
    });
  }
}

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

final appLockNotifierProvider = StateNotifierProvider<AppLockNotifier, List<LockedApp>>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  final launcherService = ref.watch(launcherServiceProvider);
  final notifier = AppLockNotifier(isarService, launcherService);
  ref.onDispose(() {
    notifier.cancelSyncTimer();
  });
  return notifier;
});
