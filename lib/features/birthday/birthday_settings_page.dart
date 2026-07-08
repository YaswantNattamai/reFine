import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'birthday_provider.dart';
import '../../database/collections/birthday.dart';

class BirthdaySettingsPage extends ConsumerStatefulWidget {
  const BirthdaySettingsPage({super.key});

  @override
  ConsumerState<BirthdaySettingsPage> createState() => _BirthdaySettingsPageState();
}

class _BirthdaySettingsPageState extends ConsumerState<BirthdaySettingsPage> {
  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final birthdaysState = ref.watch(birthdayNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Birthday Registry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: () => _showAddBirthdayDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: birthdaysState.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
          error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
          data: (birthdays) {
            if (birthdays.isEmpty) {
              return const Center(
                child: Text(
                  "No birthdays tracked yet.",
                  style: TextStyle(color: Colors.white30, fontSize: 16),
                ),
              );
            }
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: birthdays.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                final birthday = birthdays[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    birthday.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _formatDate(birthday.birthDate),
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      ref.read(birthdayNotifierProvider.notifier).deleteBirthday(birthday.id);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showAddBirthdayDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const AddBirthdayBottomSheet();
      },
    );
  }
}

class AddBirthdayBottomSheet extends ConsumerStatefulWidget {
  const AddBirthdayBottomSheet({super.key});

  @override
  ConsumerState<AddBirthdayBottomSheet> createState() => _AddBirthdayBottomSheetState();
}

class _AddBirthdayBottomSheetState extends ConsumerState<AddBirthdayBottomSheet> {
  final _nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 25));

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add Birthday Record",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 1. Person's Name
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Name",
              labelStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF222222),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Birth Date Selector
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Date of Birth", style: TextStyle(color: Colors.white54, fontSize: 12)),
            subtitle: Text(
              "${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.calendar_today, color: Colors.white70),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
          ),
          const Divider(color: Colors.white10, height: 24),
          const SizedBox(height: 16),

          // 3. Save Button
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
                final name = _nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a name.")),
                  );
                  return;
                }

                final birthday = Birthday()
                  ..name = name
                  ..birthDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
                  ..checkedToday = false;

                ref.read(birthdayNotifierProvider.notifier).addBirthday(birthday);
                Navigator.pop(context);
              },
              child: const Text("SAVE BIRTHDAY", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
