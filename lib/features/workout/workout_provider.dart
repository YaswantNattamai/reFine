import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../database/collections/workout.dart';
import '../../database/collections/workout_set_progress.dart';
import '../../database/isar_service.dart';
import '../../repositories/workout_repository.dart';
import '../app_locker/app_lock_provider.dart';
import '../timetable/current_date_provider.dart';

class WorkoutNotifier extends StateNotifier<AsyncValue<List<Workout>>> {
  final IsarService _isarService;
  final Ref _ref;
  late WorkoutRepository _workoutRepository;

  WorkoutNotifier(this._isarService, this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final isar = await _isarService.db;
      _workoutRepository = WorkoutRepository(isar);
      await loadWorkouts();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadWorkouts() async {
    try {
      final isar = await _isarService.db;
      final rawList = await isar.workouts.where().findAll();
      final list = List<dynamic>.from(rawList).whereType<Workout>().toList();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addWorkout(Workout workout) async {
    state = const AsyncValue.loading();
    try {
      await _workoutRepository.addWorkout(workout);
      await loadWorkouts();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteWorkout(int id) async {
    state = const AsyncValue.loading();
    try {
      await _workoutRepository.deleteWorkout(id);
      await loadWorkouts();
      _ref.invalidate(todayWorkoutProgressProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleWorkoutSet(int workoutId, DateTime date, int setIndex, bool completed) async {
    try {
      await _workoutRepository.toggleWorkoutSet(workoutId, date, setIndex, completed);
      _ref.invalidate(todayWorkoutProgressProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final workoutNotifierProvider = StateNotifierProvider<WorkoutNotifier, AsyncValue<List<Workout>>>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return WorkoutNotifier(isarService, ref);
});

final todayWorkoutProgressProvider = FutureProvider<List<WorkoutSetProgress>>((ref) async {
  try {
    final isar = await ref.watch(isarServiceProvider).db;
    final repo = WorkoutRepository(isar);
    final date = ref.watch(currentDateProvider).value ?? DateTime.now();
    final progress = await repo.getWorkoutProgressForDate(date);
    print("DEBUG WORKOUT: progress = $progress");
    return progress;
  } catch (e, stack) {
    print("DEBUG WORKOUT ERROR: $e");
    print("DEBUG WORKOUT STACK: $stack");
    rethrow;
  }
});

final todayWorkoutsProvider = Provider<List<Workout>>((ref) {
  final workoutsState = ref.watch(workoutNotifierProvider);
  final date = ref.watch(currentDateProvider).value ?? DateTime.now();
  return workoutsState.when(
    data: (list) {
      final weekday = date.weekday;
      return list.where((w) => w.activeDays.contains(weekday)).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
