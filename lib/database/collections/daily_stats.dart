import 'package:isar/isar.dart';

part 'daily_stats.g.dart';

@collection
class DailyStats {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late DateTime date; // Truncated to midnight

  List<int> completedTaskIds = [];
  int completedTasksCount = 0;
  bool todayWallpaperUnlocked = false; // Remains true for today even if tasks are added
}
