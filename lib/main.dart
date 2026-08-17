import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/app_search/search_page.dart';
import 'features/home/home_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/settings/settings_page.dart';
import 'features/onboarding/permission_onboarding_page.dart';
import 'features/onboarding/permission_provider.dart';
import 'features/settings/system_settings_provider.dart';

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

class LauncherShell extends ConsumerStatefulWidget {
  const LauncherShell({super.key});

  @override
  ConsumerState<LauncherShell> createState() => _LauncherShellState();
}

class _LauncherShellState extends ConsumerState<LauncherShell> with WidgetsBindingObserver {
  // Page 2 (HomePage) is index 1. So we start at index 1.
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  // Critical permissions (accessibility/overlay/usage-stats) can be revoked
  // from system settings at any time, not just during onboarding. The
  // onboarding page only re-checks while it itself is mounted, so once past
  // it nothing ever noticed a revoke - app-lock enforcement (and this guard)
  // would silently keep believing permissions were still granted. Re-check
  // on every resume regardless of which screen is showing.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(permissionNotifierProvider.notifier).checkPermissions();
    }
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
  // Locally cached last-known-good values. todayStatsProvider re-executes
  // on every task completion anywhere in the app (it watches
  // todayCompletionsProvider), and briefly reporting "no value yet" during
  // that refresh - even for a frame - was making the whole background
  // flash to black/gradient and back. We only ever overwrite these when a
  // provider actually has fresh data, so a transient reload never regresses
  // the displayed wallpaper.
  bool _isUnlocked = false;
  String? _wallpaperPath;

  @override
  Widget build(BuildContext context) {
    // Driven directly by the same providers the timetable/settings screens use,
    // so the wallpaper unlocks/updates immediately when tasks are completed or
    // the wallpaper is changed - previously this polled Isar directly on a
    // 15-minute timer and stopped polling entirely once unlocked, so an unlock
    // (or a wallpaper path change) could take up to 15 minutes to show up, or
    // never show up at all within the same session.
    final statsAsync = ref.watch(todayStatsProvider);
    final settingsAsync = ref.watch(systemSettingsProvider);

    if (statsAsync.hasValue) {
      _isUnlocked = statsAsync.value?.todayWallpaperUnlocked ?? false;
    }
    String? path = _wallpaperPath;
    if (settingsAsync.hasValue) {
      path = settingsAsync.value?.selectedWallpaperPath;
    }
    _wallpaperPath = path;

    final isUnlocked = _isUnlocked;
    final wallpaperPath = (isUnlocked && path != null && path.isNotEmpty && File(path).existsSync())
        ? path
        : null;

    if (isUnlocked) {
      if (wallpaperPath != null) {
        return Image.file(
          File(wallpaperPath),
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

