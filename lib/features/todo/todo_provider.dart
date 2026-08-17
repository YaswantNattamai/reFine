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

  Future<TodoList?> addTodoList(String title) async {
    try {
      final list = await _todoRepository.addTodoList(title);
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncValue.data([...current, list]);
      } else {
        await loadTodoLists();
      }
      return list;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  Future<void> deleteTodoList(int listId) async {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(current.where((l) => l.id != listId).toList());
    }
    try {
      await _todoRepository.deleteTodoList(listId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      await loadTodoLists();
    }
  }

  Future<void> addTodoItem(int listId, String text) async {
    final item = TodoItem()
      ..text = text
      ..isCompleted = false;
    try {
      await _todoRepository.addTodoItem(listId, item);
      final current = state.valueOrNull;
      if (current != null) {
        for (var list in current) {
          if (list.id == listId) {
            list.items.add(item);
            break;
          }
        }
        state = AsyncValue.data(List.of(current));
      } else {
        await loadTodoLists();
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      await loadTodoLists();
    }
  }

  Future<void> toggleTodoItem(int itemId, bool completed) async {
    // Apply locally first so the checkbox responds instantly instead of
    // waiting on a full DB round-trip + list re-fetch (which was visible as
    // a jarring full-page "reload" on every single tap).
    final current = state.valueOrNull;
    if (current != null) {
      for (var list in current) {
        for (var item in list.items) {
          if (item.id == itemId) {
            item.isCompleted = completed;
          }
        }
      }
      state = AsyncValue.data(List.of(current));
    }
    try {
      await _todoRepository.toggleTodoItem(itemId, completed);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      await loadTodoLists();
    }
  }

  Future<void> deleteTodoItem(int itemId) async {
    final current = state.valueOrNull;
    if (current != null) {
      for (var list in current) {
        list.items.removeWhere((item) => item.id == itemId);
      }
      state = AsyncValue.data(List.of(current));
    }
    try {
      await _todoRepository.deleteTodoItem(itemId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      await loadTodoLists();
    }
  }
}

final todoNotifierProvider = StateNotifierProvider<TodoNotifier, AsyncValue<List<TodoList>>>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return TodoNotifier(isarService);
});
