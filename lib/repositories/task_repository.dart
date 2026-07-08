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

      // Check if threshold is met for wallpaper unlock
      if (activeTasks.isNotEmpty) {
        final settings = await isar.settings.where().findFirst();
        final threshold = settings?.wallpaperUnlockedThreshold ?? 0.8;
        final percentage = stats.completedTasksCount / activeTasks.length;

        if (percentage >= threshold) {
          stats.todayWallpaperUnlocked = true;
        } else {
          // Re-lock if tasks are unchecked and threshold no longer met
          stats.todayWallpaperUnlocked = false;
        }
      }

      await isar.dailyStats.put(stats);
    });
  }
}
