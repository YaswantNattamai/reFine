import 'package:isar/isar.dart';

part 'journal_entry.g.dart';

@collection
class JournalEntry {
  Id id = Isar.autoIncrement;

  late String title;
  late String content;
  late DateTime date; // Date of the entry
  late DateTime createdAt; // Actual creation timestamp
}
