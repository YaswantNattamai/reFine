import 'package:isar/isar.dart';

part 'workout.g.dart';

@collection
class Workout {
  Id id = Isar.autoIncrement;

  late String name;
  late List<int> activeDays; // 1 (Mon) - 7 (Sun)
  int sets = 0;
  int reps = 0;
}
