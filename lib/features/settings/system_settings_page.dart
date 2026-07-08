import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'system_settings_provider.dart';
import '../launcher/launcher_provider.dart';
import '../launcher/app_info.dart';
import '../app_locker/app_lock_provider.dart';
import '../../database/collections/locked_app.dart';

class SystemSettingsPage extends ConsumerStatefulWidget {
  const SystemSettingsPage({super.key});

  @override
  ConsumerState<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends ConsumerState<SystemSettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _appSearchController = TextEditingController();
  String _appSearchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
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
                            onPressed: () async {
                              final result = await FilePicker.platform.pickFiles(
                                type: FileType.image,
                                allowMultiple: false,
                              );
                              if (result != null && result.files.single.path != null) {
                                ref.read(systemSettingsProvider.notifier)
                                    .updateWallpaperPath(result.files.single.path);
                              }
                            },
                          ),
                        ),
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
                      },
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    FutureBuilder<bool>(
                      future: launcherService.isDefaultLauncher(),
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
            ],
          );
        },
      ),
    );
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
