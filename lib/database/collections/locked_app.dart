import 'package:isar/isar.dart';

part 'locked_app.g.dart';

@collection
class LockedApp {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String packageName;

  int dailyLimitMinutes = 0;
  int todayUsageMinutes = 0;
  DateTime? bypassUntil;
  DateTime? lastResetDate;
}
