import 'package:isar/isar.dart';
import '../database/collections/task.dart';
import '../database/collections/task_completion.dart';
import '../database/collections/daily_stats.dart';
import '../database/collections/settings.dart';

class TaskRepository {
  final Isar isar;

  TaskRepository(this.isar);

  // Get tasks that are active on a specific day
  Future<List<Task>> getTasksForDate(DateTime date) async {
    final weekday = date.weekday; // 1 (Mon) - 7 (Sun)
    final truncatedDate = DateTime(date.year, date.month, date.day);

    final rawList = await isar.tasks.filter()
        .isRepeatableEqualTo(true)
        .repeatDaysElementEqualTo(weekday)
        .or()
        .isRepeatableEqualTo(false)
        .dateEqualTo(truncatedDate)
        .findAll();
    return List<dynamic>.from(rawList).whereType<Task>().toList();
  }

  // Get completion statuses for a date
  Future<List<TaskCompletion>> getCompletionsForDate(DateTime date) async {
    final truncatedDate = DateTime(date.year, date.month, date.day);
    final rawList = await isar.taskCompletions.filter()
        .dateEqualTo(truncatedDate)
        .findAll();
    return List<dynamic>.from(rawList).whereType<TaskCompletion>().toList();
  }

  // Add a task
  Future<void> addTask(Task task) async {
    await isar.writeTxn(() async {
      await isar.tasks.put(task);
    });
  }

  // Delete a task and its completions
  Future<void> deleteTask(int taskId) async {
    await isar.writeTxn(() async {
      await isar.tasks.delete(taskId);
      // Clean up completions
      await isar.taskCompletions.filter().taskIdEqualTo(taskId).deleteAll();
    });
  }

  int _timeToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return 0;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  // One-time (non-repeatable) tasks should disappear once their day is over
  // - but a task that crosses midnight (e.g. 10 PM - 3 AM) is still relevant
  // through the following morning, so it isn't "expired" until the day
  // *after* that, not the literal calendar day it was created for.
  Future<void> deleteExpiredOneTimeTasks(DateTime today) async {
    final todayTruncated = DateTime(today.year, today.month, today.day);

    final rawList = await isar.tasks.filter().isRepeatableEqualTo(false).findAll();
    final oneTimeTasks = List<dynamic>.from(rawList).whereType<Task>().toList();

    final expiredIds = <int>[];
    for (final task in oneTimeTasks) {
      final taskDate = task.date;
      if (taskDate == null) continue;

      final truncatedTaskDate = DateTime(taskDate.year, taskDate.month, taskDate.day);
      final crossesMidnight = _timeToMinutes(task.startTime) > _timeToMinutes(task.endTime);
      final lastActiveDate = crossesMidnight
          ? truncatedTaskDate.add(const Duration(days: 1))
          : truncatedTaskDate;

      if (todayTruncated.isAfter(lastActiveDate)) {
        expiredIds.add(task.id);
      }
    }

    if (expiredIds.isEmpty) return;

    await isar.writeTxn(() async {
      for (final id in expiredIds) {
        await isar.tasks.delete(id);
        await isar.taskCompletions.filter().taskIdEqualTo(id).deleteAll();
      }
    });
  }

  // Toggle completion inside an atomic transaction
  Future<void> toggleTaskCompletion(int taskId, DateTime date, bool completed) async {
    final truncatedDate = DateTime(date.year, date.month, date.day);

    await isar.writeTxn(() async {
      // 1. Update or create TaskCompletion
      var completion = await isar.taskCompletions.filter()
          .taskIdEqualTo(taskId)
          .dateEqualTo(truncatedDate)
          .findFirst();

      if (completion == null) {
        completion = TaskCompletion()
          ..taskId = taskId
          ..date = truncatedDate
          ..completed = completed;
      } else {
        completion.completed = completed;
      }
      await isar.taskCompletions.put(completion);

      // 2. Fetch all active tasks for today to recalculate stats
      final rawActiveTasks = await isar.tasks.filter()
          .isRepeatableEqualTo(true)
          .repeatDaysElementEqualTo(truncatedDate.weekday)
          .or()
          .isRepeatableEqualTo(false)
          .dateEqualTo(truncatedDate)
          .findAll();
      final activeTasks = List<dynamic>.from(rawActiveTasks).whereType<Task>().toList();

      final activeTaskIds = activeTasks.map((t) => t.id).toSet();

      // 3. Fetch completed tasks for today that are still active
      final rawTodayCompletions = await isar.taskCompletions.filter()
          .dateEqualTo(truncatedDate)
          .completedEqualTo(true)
          .findAll();
      final todayCompletions = List<dynamic>.from(rawTodayCompletions).whereType<TaskCompletion>().toList();

      final completedTaskIds = todayCompletions
          .map((c) => c.taskId)
          .where((id) => activeTaskIds.contains(id))
          .toList();

      // 4. Update DailyStats
      var stats = await isar.dailyStats.filter()
          .dateEqualTo(truncatedDate)
          .findFirst();

      if (stats == null) {
        stats = DailyStats()
          ..date = truncatedDate
          ..completedTaskIds = completedTaskIds
          ..completedTasksCount = completedTaskIds.length
          ..todayWallpaperUnlocked = false;
      } else {
        stats.completedTaskIds = completedTaskIds;
        stats.completedTasksCount = completedTaskIds.length;
      }

      // Check if threshold is met for wallpaper unlock. This is a one-way
      // unlock for the day (see DailyStats.todayWallpaperUnlocked) - the
      // WallpaperBackground widget stops polling once it observes unlocked,
      // so flipping it back to false here would leave the UI showing a
      // stale "unlocked" state while the DB disagrees. Only ever set true.
      if (activeTasks.isNotEmpty) {
        final settings = await isar.settings.where().findFirst();
        final threshold = settings?.wallpaperUnlockedThreshold ?? 0.8;
        final percentage = stats.completedTasksCount / activeTasks.length;

        if (percentage >= threshold) {
          stats.todayWallpaperUnlocked = true;
        }
      }

      await isar.dailyStats.put(stats);
    });
  }
}
