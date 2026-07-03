import 'package:isar/isar.dart';

part 'todo_item.g.dart';

@collection
class TodoItem {
  Id id = Isar.autoIncrement;

  late String text;
  bool isCompleted = false;
}
