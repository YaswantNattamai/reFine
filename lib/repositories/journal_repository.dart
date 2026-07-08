import 'package:isar/isar.dart';
import '../database/collections/journal_entry.dart';

class JournalRepository {
  final Isar isar;

  JournalRepository(this.isar);

  // Get all entries sorted descending by date
  Future<List<JournalEntry>> getJournalEntries() async {
    final rawList = await isar.journalEntrys.where()
        .sortByDateDesc()
        .thenByCreatedAtDesc()
        .findAll();
    return List<dynamic>.from(rawList).whereType<JournalEntry>().toList();
  }

  // Add/Update journal entry
  Future<void> addJournalEntry(JournalEntry entry) async {
    await isar.writeTxn(() async {
      await isar.journalEntrys.put(entry);
    });
  }

  // Delete journal entry
  Future<void> deleteJournalEntry(int id) async {
    await isar.writeTxn(() async {
      await isar.journalEntrys.delete(id);
    });
  }
}
