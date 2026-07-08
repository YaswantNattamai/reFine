import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../database/collections/birthday.dart';
import '../../database/isar_service.dart';
import '../../repositories/birthday_repository.dart';
import '../app_locker/app_lock_provider.dart';

class BirthdayNotifier extends StateNotifier<AsyncValue<List<Birthday>>> {
  final IsarService _isarService;
  late BirthdayRepository _birthdayRepository;
  static const _channel = MethodChannel('com.example.refine/launcher');

  BirthdayNotifier(this._isarService) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final isar = await _isarService.db;
      _birthdayRepository = BirthdayRepository(isar);
      await loadBirthdays();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadBirthdays() async {
    try {
      final list = await _birthdayRepository.getBirthdays();
      state = AsyncValue.data(list);
      _syncAlarmsToNative(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addBirthday(Birthday birthday) async {
    state = const AsyncValue.loading();
    try {
      await _birthdayRepository.addBirthday(birthday);
      await loadBirthdays();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteBirthday(int id) async {
    state = const AsyncValue.loading();
    try {
      await _birthdayRepository.deleteBirthday(id);
      await loadBirthdays();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleCheckedToday(int id, bool checked) async {
    try {
      await _birthdayRepository.checkBirthdayToday(id, checked);
      await loadBirthdays();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _syncAlarmsToNative(List<Birthday> list) async {
    try {
      final List<Map<String, dynamic>> alarmList = list.map((b) => {
        'id': b.id,
        'name': b.name,
        'month': b.birthDate.month,
        'day': b.birthDate.day,
        'checkedToday': b.checkedToday,
      }).toList();
      await _channel.invokeMethod('setBirthdayAlarms', {'birthdays': alarmList});
    } catch (e) {
      print("Error syncing birthday alarms to native: $e");
    }
  }
}

final birthdayNotifierProvider = StateNotifierProvider<BirthdayNotifier, AsyncValue<List<Birthday>>>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return BirthdayNotifier(isarService);
});
