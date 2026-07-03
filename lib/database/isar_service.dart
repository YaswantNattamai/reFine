import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'collections/locked_app.dart';
import 'collections/widget_config.dart';
import 'collections/settings.dart';
import 'collections/daily_stats.dart';
import 'collections/task.dart';
import 'collections/task_completion.dart';
import 'collections/birthday.dart';
import 'collections/workout.dart';
import 'collections/workout_set_progress.dart';
import 'collections/journal_entry.dart';
import 'collections/motivation.dart';
import 'collections/todo_list.dart';
import 'collections/todo_item.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = initDb();
  }

  Future<Isar> initDb() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      final isar = await Isar.open(
        [
          LockedAppSchema,
          WidgetConfigSchema,
          SettingsSchema,
          DailyStatsSchema,
          TaskSchema,
          TaskCompletionSchema,
          BirthdaySchema,
          WorkoutSchema,
          WorkoutSetProgressSchema,
          JournalEntrySchema,
          MotivationSchema,
          TodoListSchema,
          TodoItemSchema,
        ],
        directory: dir.path,
        name: 'refine_db',
      );

      // Seed database with default configurations if empty
      await _seedDefaults(isar);

      return isar;
    }
    return Isar.getInstance('refine_db')!;
  }

  Future<void> _seedDefaults(Isar isar) async {
    await isar.writeTxn(() async {
      // 1. Seed WidgetConfig defaults
      final widgetConfigsCount = await isar.widgetConfigs.count();
      if (widgetConfigsCount == 0) {
        final timetableConfig = WidgetConfig()
          ..widgetType = 'timetable'
          ..height = 250.0
          ..position = 0
          ..isVisible = true;

        final workoutConfig = WidgetConfig()
          ..widgetType = 'workout'
          ..height = 200.0
          ..position = 1
          ..isVisible = true;

        final motivationConfig = WidgetConfig()
          ..widgetType = 'motivation'
          ..height = 100.0
          ..position = 2
          ..isVisible = true;

        await isar.widgetConfigs.putAll([timetableConfig, workoutConfig, motivationConfig]);
      }

      // 2. Seed Settings defaults
      final settingsCount = await isar.settings.count();
      if (settingsCount == 0) {
        final defaultSettings = Settings()
          ..wallpaperUnlockedThreshold = 0.8
          ..quoteEnabled = true
          ..defaultLauncher = false;
        await isar.settings.put(defaultSettings);
      }

      // 3. Seed Motivation quotes defaults
      final motivationCount = await isar.motivations.count();
      if (motivationCount == 0) {
        final defaultQuotes = [
          Motivation()..quote = "Focus is a matter of deciding what things you're not going to do.",
          Motivation()..quote = "Amateurs sit and wait for inspiration, the rest of us just get up and go to work.",
          Motivation()..quote = "Simplicity is the ultimate sophistication.",
          Motivation()..quote = "Don't count the days, make the days count.",
          Motivation()..quote = "Productivity is being able to do things that you were never able to do before.",
        ];
        await isar.motivations.putAll(defaultQuotes);
      }
    });
  }
}
