import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'system_settings_provider.dart';
import 'backup_provider.dart';
import 'wallpaper_crop_page.dart';
import '../launcher/launcher_provider.dart';
import '../launcher/app_info.dart';
import '../app_locker/app_lock_provider.dart';
import '../../database/collections/locked_app.dart';

class SystemSettingsPage extends ConsumerStatefulWidget {
  const SystemSettingsPage({super.key});

  @override
  ConsumerState<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends ConsumerState<SystemSettingsPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final _appSearchController = TextEditingController();
  String _appSearchQuery = "";
  // Cached rather than called inline in FutureBuilder - this page's build()
  // reruns on every setting change (typing in the app search box, toggling
  // switches, etc.), and creating a fresh Future each time made the "Default
  // Launcher Status" indicator flash back to "Not Set" on nearly every tap.
  late Future<bool> _isDefaultLauncherFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _isDefaultLauncherFuture = ref.read(launcherServiceProvider).isDefaultLauncher();
    WidgetsBinding.instance.addObserver(this);
  }

  void _refreshDefaultLauncherStatus() {
    setState(() {
      _isDefaultLauncherFuture = ref.read(launcherServiceProvider).isDefaultLauncher();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // openDefaultHomeSettings() just fires the system intent and returns
    // immediately - the actual choice only lands once the user comes back.
    if (state == AppLifecycleState.resumed) {
      _refreshDefaultLauncherStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _appSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("System Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: "App Locker Limits"),
            Tab(text: "Launcher Config"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppLockerTab(context),
          _buildLauncherConfigTab(context),
        ],
      ),
    );
  }

  Widget _buildAppLockerTab(BuildContext context) {
    final launcherState = ref.watch(launcherNotifierProvider);
    final lockedApps = ref.watch(appLockNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          // App list search bar
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

          // Apps List
          Expanded(
            child: launcherState.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : () {
                    final filteredApps = launcherState.apps.where((app) {
                      return app.name.toLowerCase().contains(_appSearchQuery) ||
                          app.packageName.toLowerCase().contains(_appSearchQuery);
                    }).toList();

                    if (filteredApps.isEmpty) {
                      return const Center(
                        child: Text("No apps found", style: TextStyle(color: Colors.white30)),
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
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
                  }(),
          ),
        ],
      ),
    );
  }

  Widget _buildLauncherConfigTab(BuildContext context) {
    final settingsState = ref.watch(systemSettingsProvider);
    final launcherService = ref.watch(launcherServiceProvider);
    final launcherState = ref.watch(launcherNotifierProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: settingsState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
        data: (settings) {
          final thresholdPercent = (settings.wallpaperUnlockedThreshold * 100).round();

          return ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. Wallpaper unlock threshold
              const Text(
                "WALLPAPER LOCK THRESHOLD",
                style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Threshold: $thresholdPercent% task completion",
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Choose what percentage of daily tasks must be completed to unlock the custom wallpaper.",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: settings.wallpaperUnlockedThreshold,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white24,
                      onChanged: (val) {
                        ref.read(systemSettingsProvider.notifier).updateThreshold(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Wallpaper Image Picker
              const Text(
                "WALLPAPER IMAGE",
                style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preview
                    if (settings.selectedWallpaperPath != null &&
                        settings.selectedWallpaperPath!.isNotEmpty &&
                        File(settings.selectedWallpaperPath!).existsSync())
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(settings.selectedWallpaperPath!),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "No wallpaper set",
                            style: TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    const Text(
                      "This image is shown as your home screen background once you hit the task completion threshold above.",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.image_outlined, size: 18),
                            label: const Text("Pick Wallpaper"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () => _pickAndCropWallpaper(context),
                          ),
                        ),
                        if (settings.selectedWallpaperPath != null &&
                            settings.selectedWallpaperPath!.isNotEmpty &&
                            File(settings.selectedWallpaperPath!).existsSync()) ...
                          [
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.crop, color: Colors.white54),
                              tooltip: "Adjust crop",
                              onPressed: () => _adjustWallpaperCrop(context, settings.selectedWallpaperPath!),
                            ),
                          ],
                        if (settings.selectedWallpaperPath != null) ...
                          [
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              tooltip: "Remove wallpaper",
                              onPressed: () {
                                ref.read(systemSettingsProvider.notifier).updateWallpaperPath(null);
                              },
                            ),
                          ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Default Launcher Switch
              const Text(
                "SYSTEM INTEGRATION",
                style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              Card(
                color: const Color(0xFF161616),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text("Set as Default Launcher", style: TextStyle(color: Colors.white)),
                      subtitle: const Text("Open system menu to set reFine as home launcher app", style: TextStyle(color: Colors.white38, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                      onTap: () async {
                        await launcherService.openDefaultHomeSettings();
                        _refreshDefaultLauncherStatus();
                      },
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    FutureBuilder<bool>(
                      future: _isDefaultLauncherFuture,
                      builder: (context, snapshot) {
                        final isDefault = snapshot.data ?? false;
                        return ListTile(
                          title: const Text("Default Launcher Status", style: TextStyle(color: Colors.white)),
                          subtitle: Text(isDefault ? "Currently Active Default" : "Not Set", style: TextStyle(color: isDefault ? Colors.green : Colors.redAccent, fontSize: 12)),
                          trailing: Icon(isDefault ? Icons.check_circle : Icons.error_outline, color: isDefault ? Colors.green : Colors.redAccent),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2b. Gestures
              const Text(
                "GESTURES",
                style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              Card(
                color: const Color(0xFF161616),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white10),
                ),
                child: SwitchListTile(
                  title: const Text("Double Tap to Sleep", style: TextStyle(color: Colors.white)),
                  subtitle: const Text(
                    "Double tap an empty area of the Home screen to lock your phone. Requires Device Admin permission.",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  value: settings.doubleTapToSleepEnabled,
                  activeColor: Colors.white,
                  onChanged: (val) async {
                    if (val) {
                      final service = ref.read(launcherServiceProvider);
                      final isAdmin = await service.isDeviceAdminActive();
                      if (!isAdmin) {
                        await service.requestDeviceAdmin();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Grant Device Admin in the dialog, then turn this on again.")),
                          );
                        }
                        return;
                      }
                    }
                    ref.read(systemSettingsProvider.notifier).updateDoubleTapToSleep(val);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 3. Quotes configuration
              const Text(
                "CONTENT FEED",
                style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              Card(
                color: const Color(0xFF161616),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white10),
                ),
                child: SwitchListTile(
                  title: const Text("Daily Motivation Quotes", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Toggle display of motivational quote of the day on home screen", style: TextStyle(color: Colors.white38, fontSize: 12)),
                  value: settings.quoteEnabled,
                  activeColor: Colors.white,
                  onChanged: (val) {
                    ref.read(systemSettingsProvider.notifier).updateQuoteEnabled(val);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 4. Favorite Apps selection
              const Text(
                "FAVORITE APPS",
                style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              Card(
                color: const Color(0xFF161616),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white10),
                ),
                child: ListTile(
                  title: const Text("Edit Favorite Apps", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Choose apps displayed in the favorites list on the home screen", style: TextStyle(color: Colors.white38, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                  onTap: () => _showFavoritesDialog(context, settings.favoriteApps, launcherState.apps),
                ),
              ),
              const SizedBox(height: 24),

              // 5. Backup & Restore
              const Text(
                "BACKUP & RESTORE",
                style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              Card(
                color: const Color(0xFF161616),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text("Export Backup", style: TextStyle(color: Colors.white)),
                      subtitle: const Text(
                        "Save every todo, task, workout, birthday, journal entry, quote, and setting to a file - use this before uninstalling or switching phones.",
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      trailing: const Icon(Icons.download_outlined, color: Colors.white54),
                      onTap: () => _exportBackup(context),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    ListTile(
                      title: const Text("Import Backup", style: TextStyle(color: Colors.white)),
                      subtitle: const Text(
                        "Restore from a previously exported file. This replaces everything currently in the app.",
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      trailing: const Icon(Icons.upload_outlined, color: Colors.redAccent),
                      onTap: () => _importBackup(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickAndCropWallpaper(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null) return;

    Uint8List? bytes = result.files.single.bytes;
    if (bytes == null && result.files.single.path != null) {
      bytes = await File(result.files.single.path!).readAsBytes();
    }
    if (bytes == null || !context.mounted) return;

    await _openCropAndSave(context, bytes);
  }

  Future<void> _adjustWallpaperCrop(BuildContext context, String currentPath) async {
    final bytes = await File(currentPath).readAsBytes();
    if (!context.mounted) return;
    await _openCropAndSave(context, bytes);
  }

  Future<void> _openCropAndSave(BuildContext context, Uint8List bytes) async {
    final croppedPath = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (context) => WallpaperCropPage(imageBytes: bytes)),
    );
    if (croppedPath != null) {
      ref.read(systemSettingsProvider.notifier).updateWallpaperPath(croppedPath);
    }
  }

  Future<void> _exportBackup(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text("Preparing backup...")));
    try {
      final path = await ref.read(backupServiceProvider).exportBackup();
      if (!context.mounted) return;
      if (path == null) {
        messenger.showSnackBar(const SnackBar(content: Text("Export cancelled.")));
      } else {
        messenger.showSnackBar(SnackBar(content: Text("Backup saved to $path")));
      }
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text("Export failed: $e")));
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        title: const Text("Restore Backup?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          "This will replace everything currently in reFine (todos, tasks, workouts, birthdays, journal, quotes, settings) with the contents of the backup file. This cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("RESTORE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text("Restoring backup...")));
    try {
      final restored = await ref.read(backupServiceProvider).importBackup();
      if (!context.mounted) return;
      if (!restored) {
        messenger.showSnackBar(const SnackBar(content: Text("Import cancelled.")));
        return;
      }
      // Refresh every provider that holds cached data from Isar, since the
      // whole database was just replaced out from under them.
      ref.invalidate(systemSettingsProvider);
      ref.read(appLockNotifierProvider.notifier).resyncFromNative();
      messenger.showSnackBar(const SnackBar(content: Text("Backup restored. Restart reFine to fully refresh all screens.")));
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text("Import failed - backup was not applied: $e")));
    }
  }

  void _showFavoritesDialog(BuildContext context, List<String> currentFavorites, List<AppInfo> allApps) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF161616),
              title: const Text("Select Favorite Apps", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView.separated(
                  itemCount: allApps.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                  itemBuilder: (context, index) {
                    final app = allApps[index];
                    final isFav = currentFavorites.contains(app.packageName);
                    return CheckboxListTile(
                      key: ValueKey(app.packageName),
                      title: Text(app.name, style: const TextStyle(color: Colors.white)),
                      value: isFav,
                      activeColor: Colors.white,
                      checkColor: Colors.black,
                      onChanged: (val) {
                        ref.read(systemSettingsProvider.notifier).toggleFavoriteApp(app.packageName);
                        setDialogState(() {
                          if (val == true) {
                            if (!currentFavorites.contains(app.packageName)) {
                              currentFavorites.add(app.packageName);
                            }
                          } else {
                            currentFavorites.remove(app.packageName);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
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
