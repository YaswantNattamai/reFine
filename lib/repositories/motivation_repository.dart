import 'package:isar/isar.dart';
import '../database/collections/motivation.dart';

class MotivationRepository {
  final Isar isar;

  MotivationRepository(this.isar);

  // Retrieve all quotes
  Future<List<Motivation>> getQuotes() async {
    final rawList = await isar.motivations.where().findAll();
    return List<dynamic>.from(rawList).whereType<Motivation>().toList();
  }

  // Add a new quote
  Future<void> addQuote(Motivation quote) async {
    await isar.writeTxn(() async {
      await isar.motivations.put(quote);
    });
  }

  // Delete a quote by id
  Future<void> deleteQuote(int id) async {
    await isar.writeTxn(() async {
      await isar.motivations.delete(id);
    });
  }
}
