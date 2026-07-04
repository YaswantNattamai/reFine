import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_info.dart';
import 'launcher_service.dart';
import '../app_locker/app_lock_provider.dart';

class LauncherState {
  final List<AppInfo> apps;
  final bool isLoading;
  final String? error;

  LauncherState({
    required this.apps,
    required this.isLoading,
    this.error,
  });

  LauncherState.initial()
      : apps = [],
        isLoading = true,
        error = null;

  LauncherState copyWith({
    List<AppInfo>? apps,
    bool? isLoading,
    String? error,
  }) {
    return LauncherState(
      apps: apps ?? this.apps,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class LauncherNotifier extends StateNotifier<LauncherState> {
  final LauncherService _launcherService;
  final Ref _ref;

  LauncherNotifier(this._launcherService, this._ref) : super(LauncherState.initial()) {
    loadApps();
    _launcherService.setLauncherCallbacks(
      onAppsChanged: () {
        loadApps();
      },
      onEmergencyBypass: (packageName, minutes) {
        _handleEmergencyBypass(packageName, minutes);
      },
    );
  }

  void _handleEmergencyBypass(String packageName, int minutes) {
    _ref.read(appLockNotifierProvider.notifier).handleEmergencyBypass(packageName, minutes);
  }

  Future<void> loadApps() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final List<AppInfo> appsList = await _launcherService.getInstalledApps();
      // Sort apps alphabetically by name
      appsList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      state = LauncherState(apps: appsList, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> launchApp(String packageName) async {
    return await _launcherService.launchApp(packageName);
  }
}

final launcherServiceProvider = Provider<LauncherService>((ref) {
  return LauncherService();
});

final launcherNotifierProvider = StateNotifierProvider<LauncherNotifier, LauncherState>((ref) {
  final service = ref.watch(launcherServiceProvider);
  return LauncherNotifier(service, ref);
});
