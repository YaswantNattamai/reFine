import 'package:isar/isar.dart';

part 'task_completion.g.dart';

@collection
class TaskCompletion {
  Id id = Isar.autoIncrement;

  late int taskId;
  late DateTime date; // Date of completion (midnight)
  bool completed = false;
}
