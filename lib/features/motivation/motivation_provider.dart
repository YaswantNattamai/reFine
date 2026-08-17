import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/collections/motivation.dart';
import '../../database/isar_service.dart';
import '../../repositories/motivation_repository.dart';
import '../app_locker/app_lock_provider.dart';

class MotivationNotifier extends StateNotifier<AsyncValue<List<Motivation>>> {
  final IsarService _isarService;
  late MotivationRepository _motivationRepository;

  MotivationNotifier(this._isarService) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final isar = await _isarService.db;
      _motivationRepository = MotivationRepository(isar);
      await loadQuotes();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadQuotes() async {
    try {
      final list = await _motivationRepository.getQuotes();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addQuote(String quoteText) async {
    // No intermediate loading flash - randomQuoteProvider derives the
    // home-screen quote from this state and falls back to a hardcoded
    // default while loading, so clearing state here made the displayed
    // quote visibly jump to the default text on every single add/delete.
    final quote = Motivation()..quote = quoteText;
    try {
      await _motivationRepository.addQuote(quote);
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncValue.data([...current, quote]);
      } else {
        await loadQuotes();
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      await loadQuotes();
    }
  }

  Future<void> deleteQuote(int id) async {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(current.where((q) => q.id != id).toList());
    }
    try {
      await _motivationRepository.deleteQuote(id);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      await loadQuotes();
    }
  }
}

final motivationNotifierProvider = StateNotifierProvider<MotivationNotifier, AsyncValue<List<Motivation>>>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return MotivationNotifier(isarService);
});

final randomQuoteProvider = Provider<String>((ref) {
  final quotesState = ref.watch(motivationNotifierProvider);
  return quotesState.when(
    data: (quotes) {
      if (quotes.isEmpty) return "Focus is a matter of deciding what things you're not going to do.";
      final now = DateTime.now();
      final daysSinceEpoch = now.difference(DateTime(1970, 1, 1)).inDays;
      final index = daysSinceEpoch % quotes.length;
      return quotes[index].quote;
    },
    loading: () => "Focus is a matter of deciding what things you're not going to do.",
    error: (_, __) => "Focus is a matter of deciding what things you're not going to do.",
  );
});
