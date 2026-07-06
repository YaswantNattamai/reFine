import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'journal_provider.dart';
import '../../database/collections/journal_entry.dart';

class JournalEntriesPage extends ConsumerStatefulWidget {
  const JournalEntriesPage({super.key});

  @override
  ConsumerState<JournalEntriesPage> createState() => _JournalEntriesPageState();
}

class _JournalEntriesPageState extends ConsumerState<JournalEntriesPage> {
  final _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]} ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final entriesState = ref.watch(journalNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Journal Entries & Logs", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: () => _showAddEntryDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase().trim();
                });
              },
              decoration: InputDecoration(
                hintText: "Search thoughts and bypass logs...",
                hintStyle: const TextStyle(color: Colors.white30),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF161616),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Entries List
            Expanded(
              child: entriesState.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
                data: (entries) {
                  final filtered = entries.where((entry) {
                    return entry.title.toLowerCase().contains(_searchQuery) ||
                        entry.content.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        "No matching entries found.",
                        style: TextStyle(color: Colors.white30, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      final entry = filtered[index];
                      final isBypass = entry.title.startsWith("Emergency Bypass:");

                      return Card(
                        color: isBypass ? const Color(0xFF2A1515) : const Color(0xFF161616),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isBypass ? Colors.redAccent.withOpacity(0.3) : Colors.white10,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          title: Row(
                            children: [
                              if (isBypass)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                                ),
                              Expanded(
                                child: Text(
                                  entry.title,
                                  style: TextStyle(
                                    color: isBypass ? Colors.redAccent : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatDate(entry.date),
                                  style: const TextStyle(color: Colors.white30, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.white30),
                            onPressed: () {
                              ref.read(journalNotifierProvider.notifier).deleteEntry(entry.id);
                            },
                          ),
                          onTap: () => _viewEntryDetail(context, entry),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const AddJournalEntryBottomSheet();
      },
    );
  }

  void _viewEntryDetail(BuildContext context, JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        title: Text(entry.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_formatDate(entry.date), style: const TextStyle(color: Colors.white30, fontSize: 12)),
              const SizedBox(height: 16),
              Text(entry.content, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class AddJournalEntryBottomSheet extends ConsumerStatefulWidget {
  const AddJournalEntryBottomSheet({super.key});

  @override
  ConsumerState<AddJournalEntryBottomSheet> createState() => _AddJournalEntryBottomSheetState();
}

class _AddJournalEntryBottomSheetState extends ConsumerState<AddJournalEntryBottomSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle for bottom sheet
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            "Add Journal Entry",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 1. Entry Title
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Title",
              labelStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF222222),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Entry Content
          TextField(
            controller: _contentController,
            style: const TextStyle(color: Colors.white),
            maxLines: 5,
            decoration: InputDecoration(
              labelText: "Write your thoughts...",
              labelStyle: const TextStyle(color: Colors.white54),
              alignLabelWithHint: true,
              filled: true,
              fillColor: const Color(0xFF222222),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Date Picker
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Date", style: TextStyle(color: Colors.white54, fontSize: 12)),
            subtitle: Text(
              "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            trailing: const Icon(Icons.calendar_today, color: Colors.white54),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = DateTime(date.year, date.month, date.day, DateTime.now().hour, DateTime.now().minute);
                });
              }
            },
          ),
          const SizedBox(height: 24),

          // 4. Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final title = _titleController.text.trim();
                final content = _contentController.text.trim();
                if (title.isEmpty || content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in both title and content.")),
                  );
                  return;
                }

                final newEntry = JournalEntry()
                  ..title = title
                  ..content = content
                  ..date = _selectedDate
                  ..createdAt = DateTime.now();

                ref.read(journalNotifierProvider.notifier).addEntry(newEntry);
                Navigator.pop(context);
              },
              child: const Text(
                "SAVE ENTRY",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
