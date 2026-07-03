import 'package:isar/isar.dart';
import 'todo_item.dart';

part 'todo_list.g.dart';

@collection
class TodoList {
  Id id = Isar.autoIncrement;

  late String title;
  
  final items = IsarLinks<TodoItem>();
}
