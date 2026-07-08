import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../database/collections/settings.dart';
import '../../database/collections/daily_stats.dart';
import '../../database/isar_service.dart';
import '../app_locker/app_lock_provider.dart';
import '../timetable/timetable_provider.dart';
import '../../repositories/task_repository.dart';
import '../timetable/current_date_provider.dart';

class SystemSettingsNotifier extends StateNotifier<AsyncValue<Settings>> {
  final IsarService _isarService;

  SystemSettingsNotifier(this._isarService) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      await loadSettings();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadSettings() async {
    try {
      final isar = await _isarService.db;
      var settings = await isar.settings.where().findFirst();
      if (settings == null) {
        settings = Settings()
          ..wallpaperUnlockedThreshold = 0.8
          ..quoteEnabled = true
          ..defaultLauncher = false
          ..favoriteApps = [];
        await isar.writeTxn(() async {
          await isar.settings.put(settings!);
        });
      }
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateThreshold(double threshold) async {
    try {
      final isar = await _isarService.db;
      final settings = state.value;
      if (settings != null) {
        settings.wallpaperUnlockedThreshold = threshold;
        await isar.writeTxn(() async {
          await isar.settings.put(settings);
        });
        state = AsyncValue.data(settings);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateQuoteEnabled(bool enabled) async {
    try {
      final isar = await _isarService.db;
      final settings = state.value;
      if (settings != null) {
        settings.quoteEnabled = enabled;
        await isar.writeTxn(() async {
          await isar.settings.put(settings);
        });
        state = AsyncValue.data(settings);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateWallpaperPath(String? path) async {
    try {
      final isar = await _isarService.db;
      final settings = state.value;
      if (settings != null) {
        settings.selectedWallpaperPath = path;
        await isar.writeTxn(() async {
          await isar.settings.put(settings);
        });
        state = AsyncValue.data(settings);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleFavoriteApp(String packageName) async {
    try {
      final isar = await _isarService.db;
      final settings = state.value;
      if (settings != null) {
        final list = List<String>.from(settings.favoriteApps);
        if (list.contains(packageName)) {
          list.remove(packageName);
        } else {
          list.add(packageName);
        }
        settings.favoriteApps = list;
        await isar.writeTxn(() async {
          await isar.settings.put(settings);
        });
        state = AsyncValue.data(settings);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final systemSettingsProvider = StateNotifierProvider<SystemSettingsNotifier, AsyncValue<Settings>>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return SystemSettingsNotifier(isarService);
});

final todayStatsProvider = FutureProvider<DailyStats?>((ref) async {
  final isar = await ref.watch(isarServiceProvider).db;
  final date = ref.watch(currentDateProvider).value ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  ref.watch(todayCompletionsProvider); // Refresh stats if completions change
  return isar.dailyStats.filter().dateEqualTo(date).findFirst();
});

final weeklyCompletionStatsProvider = FutureProvider<List<DailyStats>>((ref) async {
  final isar = await ref.watch(isarServiceProvider).db;
  final date = ref.watch(currentDateProvider).value ?? DateTime.now();
  final todayMidnight = DateTime(date.year, date.month, date.day);
  final startDay = todayMidnight.subtract(const Duration(days: 6));
  ref.watch(timetableNotifierProvider); // auto-refresh when task completion updates
  ref.watch(todayCompletionsProvider); // auto-refresh when completions update
  final list = await isar.dailyStats.filter()
      .dateBetween(startDay, todayMidnight)
      .sortByDate()
      .findAll();
  return List<dynamic>.from(list).whereType<DailyStats>().toList();
});

class WeeklyProgressDay {
  final DateTime date;
  final int completedCount;
  final int totalCount;
  WeeklyProgressDay({required this.date, required this.completedCount, required this.totalCount});

  double get percentage => totalCount == 0 ? -1.0 : completedCount / totalCount;
}

final currentWeekProgressProvider = FutureProvider<List<WeeklyProgressDay>>((ref) async {
  final isar = await ref.watch(isarServiceProvider).db;
  final tasksState = ref.watch(timetableNotifierProvider);
  ref.watch(todayCompletionsProvider); // force re-evaluation when completions update
  final taskRepo = TaskRepository(isar);
  
  final dateValue = ref.watch(currentDateProvider).value ?? DateTime.now();
  final currentWeekday = dateValue.weekday; // 1 (Mon) - 7 (Sun)
  final sundayOffset = currentWeekday == 7 ? 0 : currentWeekday;
  final sunday = DateTime(dateValue.year, dateValue.month, dateValue.day).subtract(Duration(days: sundayOffset));
  
  final list = <WeeklyProgressDay>[];
  for (int i = 0; i < 7; i++) {
    final date = sunday.add(Duration(days: i));
    final completions = await taskRepo.getCompletionsForDate(date);
    final activeTasks = await taskRepo.getTasksForDate(date);
    
    final activeTaskIds = activeTasks.map((t) => t.id).toSet();
    final completedCount = completions
        .where((c) => c.completed && activeTaskIds.contains(c.taskId))
        .length;
        
    list.add(WeeklyProgressDay(
      date: date,
      completedCount: completedCount,
      totalCount: activeTasks.length,
    ));
  }
  return list;
});
