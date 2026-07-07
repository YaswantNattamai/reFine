import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/collections/todo_list.dart';
import '../../database/collections/todo_item.dart';
import '../../database/isar_service.dart';
import '../../repositories/todo_repository.dart';
import '../app_locker/app_lock_provider.dart';

class TodoNotifier extends StateNotifier<AsyncValue<List<TodoList>>> {
  final IsarService _isarService;
  late TodoRepository _todoRepository;

  TodoNotifier(this._isarService) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final isar = await _isarService.db;
      _todoRepository = TodoRepository(isar);
      await loadTodoLists();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadTodoLists() async {
    try {
      final list = await _todoRepository.getTodoLists();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTodoList(String title) async {
    try {
      await _todoRepository.addTodoList(title);
      await loadTodoLists();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTodoList(int listId) async {
    try {
      await _todoRepository.deleteTodoList(listId);
      await loadTodoLists();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTodoItem(int listId, String text) async {
    try {
      final item = TodoItem()
        ..text = text
        ..isCompleted = false;
      await _todoRepository.addTodoItem(listId, item);
      await loadTodoLists();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleTodoItem(int itemId, bool completed) async {
    try {
      await _todoRepository.toggleTodoItem(itemId, completed);
      await loadTodoLists();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTodoItem(int itemId) async {
    try {
      await _todoRepository.deleteTodoItem(itemId);
      await loadTodoLists();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final todoNotifierProvider = StateNotifierProvider<TodoNotifier, AsyncValue<List<TodoList>>>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return TodoNotifier(isarService);
});
