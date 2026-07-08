import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/app_search/search_page.dart';
import 'features/home/home_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/settings/settings_page.dart';
import 'features/onboarding/permission_onboarding_page.dart';
import 'features/onboarding/permission_provider.dart';
import 'features/app_locker/app_lock_provider.dart';
import 'package:isar/isar.dart';
import 'database/collections/daily_stats.dart';
import 'database/collections/settings.dart';

void main() {
  runApp(const ProviderScope(child: ReFineLauncherApp()));
}

class ReFineLauncherApp extends StatelessWidget {
  const ReFineLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'reFine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white70,
          background: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: const OnboardingGuard(),
    );
  }
}

class OnboardingGuard extends ConsumerWidget {
  const OnboardingGuard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionNotifierProvider);

    if (permissions.allCriticalGranted) {
      return const LauncherShell();
    } else {
      return const PermissionOnboardingPage();
    }
  }
}

class LauncherShell extends StatefulWidget {
  const LauncherShell({super.key});

  @override
  State<LauncherShell> createState() => _LauncherShellState();
}

class _LauncherShellState extends State<LauncherShell> {
  // Page 2 (HomePage) is index 1. So we start at index 1.
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Dynamic wallpaper background
          const Positioned.fill(
            child: WallpaperBackground(),
          ),
          
          // PageView for launcher pages
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              FocusScope.of(context).unfocus();
            },
            children: const [
              AppListPage(),    // Page 1: App List (Index 0)
              HomePage(),       // Page 2: Home Page (Index 1 - Default)
              DashboardPage(),  // Page 3: Widgets (Index 2)
              SettingsPage(),   // Page 4: Configuration (Index 3)
            ],
          ),
        ],
      ),
    );
  }
}

class WallpaperBackground extends ConsumerStatefulWidget {
  const WallpaperBackground({super.key});

  @override
  ConsumerState<WallpaperBackground> createState() => _WallpaperBackgroundState();
}

class _WallpaperBackgroundState extends ConsumerState<WallpaperBackground> {
  Timer? _pollTimer;
  bool _isUnlocked = false;
  String? _wallpaperPath;
  String? _settingsPath;

  @override
  void initState() {
    super.initState();
    _checkUnlockStatus(); // Check immediately on startup
    // Poll every 15 minutes as long as wallpaper isn't unlocked yet
    _pollTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (!_isUnlocked) {
        _checkUnlockStatus();
      } else {
        _pollTimer?.cancel(); // Stop polling once unlocked
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkUnlockStatus() async {
    try {
      final isarService = ref.read(isarServiceProvider);
      final isar = await isarService.db;
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final stats = await isar.dailyStats.filter().dateEqualTo(today).findFirst();
      final settings = await isar.settings.where().findFirst();

      final unlocked = stats?.todayWallpaperUnlocked ?? false;
      final path = settings?.selectedWallpaperPath;

      if (mounted) {
        setState(() {
          _isUnlocked = unlocked;
          _settingsPath = path;
          _wallpaperPath = (unlocked && path != null && path.isNotEmpty && File(path).existsSync())
              ? path
              : null;
        });
        if (unlocked) {
          _pollTimer?.cancel(); // No more polling needed
        }
      }
    } catch (_) {
      // Keep current state silently on error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUnlocked) {
      if (_wallpaperPath != null) {
        return Image.file(
          File(_wallpaperPath!),
          fit: BoxFit.cover,
        );
      }
      // Unlocked but no image set — premium gradient
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
      );
    }

    // Locked — solid black
    return Container(color: Colors.black);
  }
}

