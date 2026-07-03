import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  late String title;
  late List<int> repeatDays; // 1 (Mon) - 7 (Sun), empty if non-repeatable
  late String startTime;     // "HH:MM"
  late String endTime;       // "HH:MM"
  DateTime? date;            // Null if repeatable, contains date if single instance
  bool isRepeatable = false;
}
