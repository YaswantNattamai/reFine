import 'package:isar/isar.dart';

part 'workout_set_progress.g.dart';

@collection
class WorkoutSetProgress {
  Id id = Isar.autoIncrement;

  late int workoutId;
  late DateTime date; // Date of progress (midnight)
  late List<bool> setsCompleted; // list tracking checked states e.g. [true, false, false]
}
