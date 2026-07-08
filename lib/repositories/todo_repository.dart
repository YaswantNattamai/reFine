import 'package:isar/isar.dart';
import '../database/collections/todo_list.dart';
import '../database/collections/todo_item.dart';

class TodoRepository {
  final Isar isar;

  TodoRepository(this.isar);

  // Retrieve all Todo lists (categories) with items loaded
  Future<List<TodoList>> getTodoLists() async {
    final rawLists = await isar.todoLists.where().findAll();
    final lists = List<dynamic>.from(rawLists).whereType<TodoList>().toList();
    for (var list in lists) {
      await list.items.load();
    }
    return lists;
  }

  // Add a new Todo list (category)
  Future<void> addTodoList(String title) async {
    await isar.writeTxn(() async {
      final list = TodoList()..title = title;
      await isar.todoLists.put(list);
    });
  }

  // Delete a Todo list and all its associated items
  Future<void> deleteTodoList(int listId) async {
    await isar.writeTxn(() async {
      final list = await isar.todoLists.get(listId);
      if (list != null) {
        await list.items.load();
        // Delete all items in this list first
        final itemIds = list.items.map((e) => e.id).toList();
        await isar.todoItems.deleteAll(itemIds);
        // Delete the list itself
        await isar.todoLists.delete(listId);
      }
    });
  }

  // Add an item to a list
  Future<void> addTodoItem(int listId, TodoItem item) async {
    await isar.writeTxn(() async {
      await isar.todoItems.put(item);
      final list = await isar.todoLists.get(listId);
      if (list != null) {
        list.items.add(item);
        await list.items.save();
      }
    });
  }

  // Toggle Todo item completed state
  Future<void> toggleTodoItem(int itemId, bool completed) async {
    await isar.writeTxn(() async {
      final item = await isar.todoItems.get(itemId);
      if (item != null) {
        item.isCompleted = completed;
        await isar.todoItems.put(item);
      }
    });
  }

  // Delete a Todo item
  Future<void> deleteTodoItem(int itemId) async {
    await isar.writeTxn(() async {
      await isar.todoItems.delete(itemId);
    });
  }
}
