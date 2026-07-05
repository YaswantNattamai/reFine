import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'search_provider.dart';
import '../launcher/launcher_provider.dart';

class AppListPage extends ConsumerStatefulWidget {
  const AppListPage({super.key});

  @override
  ConsumerState<AppListPage> createState() => _AppListPageState();
}

class _AppListPageState extends ConsumerState<AppListPage> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearchChanged);
    // Auto-focus search bar when entering this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchNotifierProvider.notifier).updateQuery(_searchController.text);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _searchController.clear();
      ref.read(searchNotifierProvider.notifier).updateQuery('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);
    final launcherState = ref.watch(launcherNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black, // Pure black background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // 1. Search Bar on top
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: "Search apps...",
                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 18),
                  prefixIcon: const Icon(Icons.search, color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF121212),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Apps Scrollable List
              Expanded(
                child: launcherState.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : launcherState.error != null
                        ? Center(child: Text("Error: ${launcherState.error}", style: const TextStyle(color: Colors.red)))
                        : searchState.filteredApps.isEmpty
                            ? const Center(
                                child: Text(
                                  "No apps match search.",
                                  style: TextStyle(color: Colors.white30, fontSize: 16),
                                ),
                              )
                            : ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                itemCount: searchState.filteredApps.length,
                                separatorBuilder: (context, index) => const Divider(
                                  color: Colors.white10,
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final app = searchState.filteredApps[index];
                                  return ListTile(
                                    title: Text(
                                      app.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                    onTap: () {
                                      _searchController.clear();
                                      ref.read(searchNotifierProvider.notifier).updateQuery('');
                                      ref.read(launcherNotifierProvider.notifier).launchApp(app.packageName);
                                    },
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
