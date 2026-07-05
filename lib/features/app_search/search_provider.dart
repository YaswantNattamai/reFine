import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../launcher/app_info.dart';
import '../launcher/launcher_provider.dart';

class SearchState {
  final String query;
  final List<AppInfo> filteredApps;

  SearchState({
    required this.query,
    required this.filteredApps,
  });
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;
  final List<AppInfo> _allApps;

  SearchNotifier(this._ref, this._allApps) : super(SearchState(query: '', filteredApps: _allApps)) {
    _filterApps(state.query, _allApps);
  }

  // Set the search query and filter the app list
  void updateQuery(String query) {
    _filterApps(query, _allApps);
  }

  void _filterApps(String query, List<AppInfo> allApps) {
    if (query.trim().isEmpty) {
      state = SearchState(query: query, filteredApps: allApps);
      return;
    }

    final cleanQuery = query.toLowerCase().trim();
    final List<AppInfo> results = [];

    for (var app in allApps) {
      if (_matchesSearch(app.name, cleanQuery)) {
        results.add(app);
      }
    }

    state = SearchState(query: query, filteredApps: results);

    // Auto-launch triggers if query is at least 2 characters and matches exactly one app
    if (results.length == 1 && cleanQuery.length >= 2) {
      _ref.read(launcherNotifierProvider.notifier).launchApp(results.first.packageName);
    }
  }

  bool _matchesSearch(String appLabel, String cleanQuery) {
    final cleanLabel = appLabel.toLowerCase();

    // 1. Direct prefix match
    if (cleanLabel.startsWith(cleanQuery)) return true;

    final List<String> words = cleanLabel.split(' ').where((w) => w.trim().isNotEmpty).toList();

    // 2. Multi-word prefix match (e.g. "maps" matches "Google Maps")
    for (var word in words) {
      if (word.startsWith(cleanQuery)) return true;
    }

    // 3. Abbreviation initials match (e.g. "gm" matches "Google Maps")
    if (words.length > 1) {
      final initials = words.map((w) => w[0]).join('');
      if (initials.startsWith(cleanQuery)) return true;
    }

    return false;
  }
}

final searchNotifierProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final launcherState = ref.watch(launcherNotifierProvider);
  return SearchNotifier(ref, launcherState.apps);
});
