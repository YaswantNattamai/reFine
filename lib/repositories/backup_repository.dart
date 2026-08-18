import 'dart:convert';
import 'package:isar/isar.dart';
import '../database/collections/settings.dart';
import '../database/collections/locked_app.dart';
import '../database/collections/widget_config.dart';
import '../database/collections/daily_stats.dart';
import '../database/collections/task.dart';
import '../database/collections/task_completion.dart';
import '../database/collections/birthday.dart';
import '../database/collections/workout.dart';
import '../database/collections/workout_set_progress.dart';
import '../database/collections/journal_entry.dart';
import '../database/collections/motivation.dart';
import '../database/collections/todo_list.dart';
import '../database/collections/todo_item.dart';

// Exports/imports every user-facing Isar collection as a single JSON document,
// so the app's whole state (birthdays, tasks, todos, workouts, journal,
// motivation quotes, settings, app-lock rules, stats) can be migrated across
// an uninstall/reinstall. Import fully replaces existing data (not a merge) -
// that's the correct semantics for a "restore my backup" flow.
class BackupRepository {
  final Isar isar;
  BackupRepository(this.isar);

  static const int backupVersion = 1;

  String? _dateStr(DateTime? d) => d?.toIso8601String();
  DateTime? _parseDateOrNull(dynamic v) => v == null ? null : DateTime.parse(v as String);
  DateTime _parseDate(dynamic v) => DateTime.parse(v as String);

  Future<String> exportToJson() async {
    final settings = await isar.settings.where().findFirst();
    final lockedApps = List<dynamic>.from(await isar.lockedApps.where().findAll()).whereType<LockedApp>().toList();
    final widgetConfigs = List<dynamic>.from(await isar.widgetConfigs.where().findAll()).whereType<WidgetConfig>().toList();
    final dailyStats = List<dynamic>.from(await isar.dailyStats.where().findAll()).whereType<DailyStats>().toList();
    final tasks = List<dynamic>.from(await isar.tasks.where().findAll()).whereType<Task>().toList();
    final taskCompletions = List<dynamic>.from(await isar.taskCompletions.where().findAll()).whereType<TaskCompletion>().toList();
    final birthdays = List<dynamic>.from(await isar.birthdays.where().findAll()).whereType<Birthday>().toList();
    final workouts = List<dynamic>.from(await isar.workouts.where().findAll()).whereType<Workout>().toList();
    final workoutProgress = List<dynamic>.from(await isar.workoutSetProgress.where().findAll()).whereType<WorkoutSetProgress>().toList();
    final journalEntries = List<dynamic>.from(await isar.journalEntrys.where().findAll()).whereType<JournalEntry>().toList();
    final motivations = List<dynamic>.from(await isar.motivations.where().findAll()).whereType<Motivation>().toList();
    final todoLists = List<dynamic>.from(await isar.todoLists.where().findAll()).whereType<TodoList>().toList();
    for (final list in todoLists) {
      await list.items.load();
    }

    final data = {
      'backupVersion': backupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings == null
          ? null
          : {
              'wallpaperUnlockedThreshold': settings.wallpaperUnlockedThreshold,
              'quoteEnabled': settings.quoteEnabled,
              'selectedWallpaperPath': settings.selectedWallpaperPath,
              'defaultLauncher': settings.defaultLauncher,
              'favoriteApps': settings.favoriteApps,
              'doubleTapToSleepEnabled': settings.doubleTapToSleepEnabled,
            },
      'lockedApps': lockedApps
          .map((a) => {
                'packageName': a.packageName,
                'dailyLimitMinutes': a.dailyLimitMinutes,
                'todayUsageMinutes': a.todayUsageMinutes,
                'bypassUntil': _dateStr(a.bypassUntil),
                'lastResetDate': _dateStr(a.lastResetDate),
              })
          .toList(),
      'widgetConfigs': widgetConfigs
          .map((w) => {
                'widgetType': w.widgetType,
                'height': w.height,
                'position': w.position,
                'isVisible': w.isVisible,
              })
          .toList(),
      'dailyStats': dailyStats
          .map((d) => {
                'date': _dateStr(d.date),
                'completedTaskIds': d.completedTaskIds,
                'completedTasksCount': d.completedTasksCount,
                'todayWallpaperUnlocked': d.todayWallpaperUnlocked,
              })
          .toList(),
      // 'oldId' is only carried along to remap taskCompletions/dailyStats
      // references on import - it's never reused as the real Isar id.
      'tasks': tasks
          .map((t) => {
                'oldId': t.id,
                'title': t.title,
                'repeatDays': t.repeatDays,
                'startTime': t.startTime,
                'endTime': t.endTime,
                'date': _dateStr(t.date),
                'isRepeatable': t.isRepeatable,
              })
          .toList(),
      'taskCompletions': taskCompletions
          .map((c) => {
                'oldTaskId': c.taskId,
                'date': _dateStr(c.date),
                'completed': c.completed,
              })
          .toList(),
      'birthdays': birthdays
          .map((b) => {
                'name': b.name,
                'birthDate': _dateStr(b.birthDate),
                'checkedToday': b.checkedToday,
              })
          .toList(),
      'workouts': workouts
          .map((w) => {
                'oldId': w.id,
                'name': w.name,
                'activeDays': w.activeDays,
                'sets': w.sets,
                'reps': w.reps,
              })
          .toList(),
      'workoutSetProgress': workoutProgress
          .map((p) => {
                'oldWorkoutId': p.workoutId,
                'date': _dateStr(p.date),
                'setsCompleted': p.setsCompleted,
              })
          .toList(),
      'journalEntries': journalEntries
          .map((j) => {
                'title': j.title,
                'content': j.content,
                'date': _dateStr(j.date),
                'createdAt': _dateStr(j.createdAt),
              })
          .toList(),
      'motivations': motivations.map((m) => {'quote': m.quote}).toList(),
      'todoLists': todoLists
          .map((l) => {
                'title': l.title,
                'items': l.items.map((i) => {'text': i.text, 'isCompleted': i.isCompleted}).toList(),
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<void> importFromJson(String jsonStr) async {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    if (data['backupVersion'] == null) {
      throw const FormatException('Not a reFine backup file');
    }

    await isar.writeTxn(() async {
      // Full restore, not a merge - clear everything first. This runs inside
      // one Isar transaction, so if anything below throws (malformed data),
      // the whole thing rolls back and the existing data is left untouched.
      await isar.settings.clear();
      await isar.lockedApps.clear();
      await isar.widgetConfigs.clear();
      await isar.dailyStats.clear();
      await isar.tasks.clear();
      await isar.taskCompletions.clear();
      await isar.birthdays.clear();
      await isar.workouts.clear();
      await isar.workoutSetProgress.clear();
      await isar.journalEntrys.clear();
      await isar.motivations.clear();
      await isar.todoItems.clear();
      await isar.todoLists.clear();

      final settingsJson = data['settings'] as Map<String, dynamic>?;
      if (settingsJson != null) {
        final settings = Settings()
          ..wallpaperUnlockedThreshold = (settingsJson['wallpaperUnlockedThreshold'] as num?)?.toDouble() ?? 0.8
          ..quoteEnabled = settingsJson['quoteEnabled'] as bool? ?? true
          ..selectedWallpaperPath = settingsJson['selectedWallpaperPath'] as String?
          ..defaultLauncher = settingsJson['defaultLauncher'] as bool? ?? false
          ..favoriteApps = List<String>.from(settingsJson['favoriteApps'] as List? ?? [])
          ..doubleTapToSleepEnabled = settingsJson['doubleTapToSleepEnabled'] as bool? ?? false;
        await isar.settings.put(settings);
      }

      for (final raw in (data['lockedApps'] as List? ?? [])) {
        final j = raw as Map<String, dynamic>;
        final app = LockedApp()
          ..packageName = j['packageName'] as String
          ..dailyLimitMinutes = j['dailyLimitMinutes'] as int? ?? 0
          ..todayUsageMinutes = j['todayUsageMinutes'] as int? ?? 0
          ..bypassUntil = _parseDateOrNull(j['bypassUntil'])
          ..lastResetDate = _parseDateOrNull(j['lastResetDate']);
        await isar.lockedApps.put(app);
      }

      for (final raw in (data['widgetConfigs'] as List? ?? [])) {
        final j = raw as Map<String, dynamic>;
        final wc = WidgetConfig()
          ..widgetType = j['widgetType'] as String
          ..height = (j['height'] as num?)?.toDouble() ?? 200.0
          ..position = j['position'] as int? ?? 0
          ..isVisible = j['isVisible'] as bool? ?? true;
        await isar.widgetConfigs.put(wc);
      }

      final taskIdMap = <int, int>{};
      for (final raw in (data['tasks'] as List? ?? [])) {
        final j = raw as Map<String, dynamic>;
        final oldId = j['oldId'] as int;
        final task = Task()
          ..title = j['title'] as String
          ..repeatDays = List<int>.from(j['repeatDays'] as List? ?? [])
          ..startTime = j['startTime'] as String
          ..endTime = j['endTime'] as String
          ..date = _parseDateOrNull(j['date'])
          ..isRepeatable = j['isRepeatable'] as bool? ?? false;
        final newId = await isar.tasks.put(task);
        taskIdMap[oldId] = newId;
      }

      for (final raw in (data['taskCompletions'] as List? ?? [])) {
        final j = raw as Map<String, dynamic>;
        final newTaskId = taskIdMap[j['oldTaskId'] as int];
        if (newTaskId == null) continue; // task it referred to no longer exists
        final completion = TaskCompletion()
          ..taskId = newTaskId
          ..date = _parseDate(j['date'])
          ..completed = j['completed'] as bool? ?? false;
        await isar.taskCompletions.put(completion);
      }

      for (final raw in (data['dailyStats'] as List? ?? [])) {
        final j = raw as Map<String, dynamic>;
        final oldIds = List<int>.from(j['completedTaskIds'] as List? ?? []);
        final remappedIds = oldIds.map((id) => taskIdMap[id]).whereType<int>().toList();
        final stats = DailyStats()
          ..date = _parseDate(j['date'])
          ..completedTaskIds = remappedIds
          ..completedTasksCount = j['completedTasksCount'] as int? ?? remappedIds.length
          ..todayWallpaperUnlocked = j['todayWallpaperUnlocked'] as bool? ?? false;
        await isar.dailyStats.put(stats);
      }

      for (final raw in (data['birthdays'] as List? ?? [])) {
        final j = raw as Map<String, dynamic>;
        final b = Birthday()
          ..name = j['name'] as String
          ..birthDate = _parseDate(j['birthDate'])
          ..checkedToday = j['checkedToday'] as bool? ?? false;
        await isar.birthdays.put(b);
      }

      final workoutIdMap = <int, int>{};
      for (final raw in (data['workouts'] as List? ?? [])) {
        final j = raw as Map<String, dynamic>;
        final oldId = j['oldId'] as int;
        final w = Workout()
          ..name = j['name'] as String
          ..activeDays = List<int>.from(j['activeDays'] as List? ?? [])
          ..sets = j['sets'] as int? ?? 0
          ..reps = j['reps'] as int? ?? 0;
        final newId = await isar.workouts.put(w);
        workoutIdMap[oldId] = newId;
      }

      for (final raw in (data['workoutSetProgress'] as List? ?? [])) {
        final j = raw as Map<String, dynamic>;
        final newWorkoutId = workoutIdMap[j['oldWorkoutId'] as int];
        if (newWorkoutId == null) continue;
        final p = WorkoutSetProgress()
          ..workoutId = newWorkoutId
          ..date = _parseDate(j['date'])
          ..setsCompleted = List<bool>.from(j['setsCompleted'] as List? ?? []);
        await isar.workoutSetProgress.put(p);
      }

      for (final raw in (data['journalEntries'] as List? ?? [])) {
        final j = raw as Map<String, dynamic>;
        final entry = JournalEntry()
          ..title = j['title'] as String
          ..content = j['content'] as String
          ..date = _parseDate(j['date'])
          ..createdAt = _parseDate(j['createdAt']);
        await isar.journalEntrys.put(entry);
      }

      for (final raw in (data['motivations'] as List? ?? [])) {
        final j = raw as Map<String, dynamic>;
        final m = Motivation()..quote = j['quote'] as String;
        await isar.motivations.put(m);
      }

      for (final raw in (data['todoLists'] as List? ?? [])) {
        final j = raw as Map<String, dynamic>;
        final list = TodoList()..title = j['title'] as String;
        await isar.todoLists.put(list);
        for (final rawItem in (j['items'] as List? ?? [])) {
          final ij = rawItem as Map<String, dynamic>;
          final item = TodoItem()
            ..text = ij['text'] as String
            ..isCompleted = ij['isCompleted'] as bool? ?? false;
          await isar.todoItems.put(item);
          list.items.add(item);
        }
        await list.items.save();
      }
    });
  }
}
