import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../database/collections/task.dart';
import '../../database/collections/task_completion.dart';
import '../../database/isar_service.dart';
import '../../repositories/task_repository.dart';
import '../app_locker/app_lock_provider.dart';
import 'current_date_provider.dart';

class TimetableNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final IsarService _isarService;
  late TaskRepository _taskRepository;

  TimetableNotifier(this._isarService) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final isar = await _isarService.db;
      _taskRepository = TaskRepository(isar);
      await loadTasks();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadTasks() async {
    try {
      final isar = await _isarService.db;
      final rawList = await isar.tasks.where().findAll();
      final list = List<dynamic>.from(rawList).whereType<Task>().toList();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _taskRepository.addTask(task);
      await loadTasks();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      await _taskRepository.deleteTask(taskId);
      await loadTasks();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleTaskCompletion(int taskId, DateTime date, bool completed) async {
    try {
      await _taskRepository.toggleTaskCompletion(taskId, date, completed);
      await loadTasks();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final timetableNotifierProvider = StateNotifierProvider<TimetableNotifier, AsyncValue<List<Task>>>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return TimetableNotifier(isarService);
});

final todayTasksProvider = FutureProvider<List<Task>>((ref) async {
  final isar = await ref.watch(isarServiceProvider).db;
  final repo = TaskRepository(isar);
  ref.watch(timetableNotifierProvider);
  final date = ref.watch(currentDateProvider).value ?? DateTime.now();
  return repo.getTasksForDate(date);
});

final todayCompletionsProvider = FutureProvider<List<TaskCompletion>>((ref) async {
  final isar = await ref.watch(isarServiceProvider).db;
  final repo = TaskRepository(isar);
  ref.watch(timetableNotifierProvider);
  final date = ref.watch(currentDateProvider).value ?? DateTime.now();
  return repo.getCompletionsForDate(date);
});
