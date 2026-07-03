import 'package:isar/isar.dart';

part 'birthday.g.dart';

@collection
class Birthday {
  Id id = Isar.autoIncrement;

  late String name;
  late DateTime birthDate;
  bool checkedToday = false; // Reset daily at midnight
}
