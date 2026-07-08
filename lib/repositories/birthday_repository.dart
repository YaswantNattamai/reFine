import 'package:isar/isar.dart';
import '../database/collections/birthday.dart';

class BirthdayRepository {
  final Isar isar;

  BirthdayRepository(this.isar);

  // Retrieve all birthdays sorted
  Future<List<Birthday>> getBirthdays() async {
    final rawList = await isar.birthdays.where().findAll();
    final list = List<dynamic>.from(rawList).whereType<Birthday>().toList();
    // Sort according to month/day for chronological birth order
    list.sort((a, b) {
      if (a.birthDate.month != b.birthDate.month) {
        return a.birthDate.month.compareTo(b.birthDate.month);
      }
      return a.birthDate.day.compareTo(b.birthDate.day);
    });
    return list;
  }

  // Add/Update birthday
  Future<void> addBirthday(Birthday birthday) async {
    await isar.writeTxn(() async {
      await isar.birthdays.put(birthday);
    });
  }

  // Delete birthday
  Future<void> deleteBirthday(int id) async {
    await isar.writeTxn(() async {
      await isar.birthdays.delete(id);
    });
  }

  // Toggle birthday checkbox today
  Future<void> checkBirthdayToday(int id, bool checked) async {
    await isar.writeTxn(() async {
      final birthday = await isar.birthdays.get(id);
      if (birthday != null) {
        birthday.checkedToday = checked;
        await isar.birthdays.put(birthday);
      }
    });
  }

  // Check if today is someone's birthday
  bool isBirthdayToday(Birthday b, DateTime today) {
    return b.birthDate.month == today.month && b.birthDate.day == today.day;
  }
}
