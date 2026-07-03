import 'package:isar/isar.dart';

part 'motivation.g.dart';

@collection
class Motivation {
  Id id = Isar.autoIncrement;

  late String quote;
}
