import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/collections/journal_entry.dart';
import '../../database/isar_service.dart';
import '../../repositories/journal_repository.dart';
import '../app_locker/app_lock_provider.dart';

class JournalNotifier extends StateNotifier<AsyncValue<List<JournalEntry>>> {
  final IsarService _isarService;
  late JournalRepository _journalRepository;

  JournalNotifier(this._isarService) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final isar = await _isarService.db;
      _journalRepository = JournalRepository(isar);
      await loadEntries();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadEntries() async {
    try {
      final list = await _journalRepository.getJournalEntries();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addEntry(JournalEntry entry) async {
    state = const AsyncValue.loading();
    try {
      await _journalRepository.addJournalEntry(entry);
      await loadEntries();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteEntry(int id) async {
    state = const AsyncValue.loading();
    try {
      await _journalRepository.deleteJournalEntry(id);
      await loadEntries();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final journalNotifierProvider = StateNotifierProvider<JournalNotifier, AsyncValue<List<JournalEntry>>>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return JournalNotifier(isarService);
});
