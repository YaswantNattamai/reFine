import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/collections/birthday.dart';
import '../../database/collections/todo_list.dart';
import '../../database/isar_service.dart';
import '../../repositories/birthday_repository.dart';
import '../app_locker/app_lock_provider.dart';
import '../todo/todo_provider.dart';

class BirthdayNotifier extends StateNotifier<AsyncValue<List<Birthday>>> {
  final Ref _ref;
  final IsarService _isarService;
  late BirthdayRepository _birthdayRepository;
  static const _channel = MethodChannel('com.example.refine/launcher');

  BirthdayNotifier(this._ref, this._isarService) : super(const AsyncValue.loading()) {
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
      await _checkAndAddBirthdayTodos(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _checkAndAddBirthdayTodos(List<Birthday> birthdays) async {
    final now = DateTime.now();

    // Reset the "handled today" flag for any birthday whose day has passed,
    // so the reminder isn't permanently suppressed on future occurrences.
    // Also clean up its now-stale "Wish X" item so the Today list doesn't
    // accumulate reminders from birthdays that have already passed.
    bool anyFlagChanged = false;
    for (var birthday in birthdays) {
      final isToday = birthday.birthDate.month == now.month && birthday.birthDate.day == now.day;
      if (!isToday && birthday.checkedToday) {
        await _birthdayRepository.checkBirthdayToday(birthday.id, false);
        anyFlagChanged = true;

        final taskText = 'Wish "${birthday.name}"';
        final todoLists = _ref.read(todoNotifierProvider).valueOrNull ?? [];
        for (var list in todoLists) {
          for (var item in list.items) {
            if (item.text == taskText) {
              await _ref.read(todoNotifierProvider.notifier).deleteTodoItem(item.id);
            }
          }
        }
      }
    }

    final todayBirthdays = birthdays.where((b) {
      return b.birthDate.month == now.month && b.birthDate.day == now.day && !b.checkedToday;
    }).toList();

    if (todayBirthdays.isEmpty) {
      if (anyFlagChanged) {
        final refreshed = await _birthdayRepository.getBirthdays();
        await _syncAlarmsToNative(refreshed);
      }
      return;
    }

    // Ensure todo lists are loaded
    final todoState = _ref.read(todoNotifierProvider);
    if (todoState is! AsyncData) {
      await _ref.read(todoNotifierProvider.notifier).loadTodoLists();
    }

    var todoLists = _ref.read(todoNotifierProvider).valueOrNull ?? [];

    // Resolve (or create) the 'Today' list once up front. Previously this was
    // done per-birthday against a snapshot of todoLists that was never
    // refreshed inside the loop, so when 2+ birthdays fell on the same day,
    // each one independently found "no Today list yet" and created its own,
    // leaving duplicate 'Today' lists behind.
    int? todayListId;
    var existingToday = todoLists.firstWhere(
      (l) => l.title.trim().toLowerCase() == 'today',
      orElse: () => TodoList()..id = -999,
    );
    if (existingToday.id != -999) {
      todayListId = existingToday.id;
    }

    for (var birthday in todayBirthdays) {
      final taskText = 'Wish "${birthday.name}"';

      // Check if already exists in any list
      bool exists = false;
      for (var list in todoLists) {
        if (list.items.any((item) => item.text == taskText)) {
          exists = true;
          break;
        }
      }

      if (!exists) {
        if (todayListId == null) {
          final createdList = await _ref.read(todoNotifierProvider.notifier).addTodoList('Today');
          if (createdList == null) {
            // Creation failed this cycle; skip and retry on next load.
            continue;
          }
          todayListId = createdList.id;
        }

        await _ref.read(todoNotifierProvider.notifier).addTodoItem(todayListId, taskText);
        // Reflect the new item locally so subsequent iterations' "exists" check sees it.
        todoLists = _ref.read(todoNotifierProvider).valueOrNull ?? todoLists;
      }

      // Mark handled for today so re-running this check (e.g. after the user
      // deletes the generated todo item) doesn't resurrect it.
      await _birthdayRepository.checkBirthdayToday(birthday.id, true);
    }

    // Push the updated checkedToday flags to native immediately so the alarm
    // receiver doesn't fire a redundant notification later today using a
    // stale cached copy.
    final refreshed = await _birthdayRepository.getBirthdays();
    await _syncAlarmsToNative(refreshed);
  }

  Future<void> addBirthday(Birthday birthday) async {
    // No intermediate loading flash over the existing list for a simple add.
    try {
      await _birthdayRepository.addBirthday(birthday);
      await loadBirthdays();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteBirthday(int id) async {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(current.where((b) => b.id != id).toList());
    }
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
  return BirthdayNotifier(ref, isarService);
});
