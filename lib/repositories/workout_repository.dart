import 'package:isar/isar.dart';
import '../database/collections/workout.dart';
import '../database/collections/workout_set_progress.dart';

class WorkoutRepository {
  final Isar isar;

  WorkoutRepository(this.isar);

  // Get active workouts for a weekday
  Future<List<Workout>> getWorkoutsForDate(DateTime date) async {
    final weekday = date.weekday; // 1 (Mon) - 7 (Sun)
    final list = await isar.workouts.filter()
        .activeDaysElementEqualTo(weekday)
        .findAll();
    return List<dynamic>.from(list).whereType<Workout>().toList();
  }

  // Get set progress records for a date
  Future<List<WorkoutSetProgress>> getWorkoutProgressForDate(DateTime date) async {
    final truncatedDate = DateTime(date.year, date.month, date.day);
    final list = await isar.workoutSetProgress.filter()
        .dateEqualTo(truncatedDate)
        .findAll();
    return List<dynamic>.from(list).whereType<WorkoutSetProgress>().toList();
  }

  // Add/Update workout
  Future<void> addWorkout(Workout workout) async {
    await isar.writeTxn(() async {
      await isar.workouts.put(workout);
    });
  }

  // Delete workout and progress records
  Future<void> deleteWorkout(int workoutId) async {
    await isar.writeTxn(() async {
      await isar.workouts.delete(workoutId);
      await isar.workoutSetProgress.filter().workoutIdEqualTo(workoutId).deleteAll();
    });
  }

  // Toggle checklist checkbox for an individual set
  Future<void> toggleWorkoutSet(int workoutId, DateTime date, int setIndex, bool completed) async {
    final truncatedDate = DateTime(date.year, date.month, date.day);

    await isar.writeTxn(() async {
      final workout = await isar.workouts.get(workoutId);
      if (workout == null) return;

      var progress = await isar.workoutSetProgress.filter()
          .workoutIdEqualTo(workoutId)
          .dateEqualTo(truncatedDate)
          .findFirst();

      if (progress == null) {
        // Initialize bool list with false
        final setsCompleted = List<bool>.generate(workout.sets, (_) => false);
        if (setIndex < setsCompleted.length) {
          setsCompleted[setIndex] = completed;
        }
        progress = WorkoutSetProgress()
          ..workoutId = workoutId
          ..date = truncatedDate
          ..setsCompleted = setsCompleted;
      } else {
        // Ensure size compatibility
        final updatedList = List<bool>.from(progress.setsCompleted);
        if (updatedList.length != workout.sets) {
          final adjustedList = List<bool>.generate(workout.sets, (i) => i < updatedList.length ? updatedList[i] : false);
          if (setIndex < adjustedList.length) adjustedList[setIndex] = completed;
          progress.setsCompleted = adjustedList;
        } else {
          if (setIndex < updatedList.length) {
            updatedList[setIndex] = completed;
          }
          progress.setsCompleted = updatedList;
        }
      }
      await isar.workoutSetProgress.put(progress);
    });
  }
}
