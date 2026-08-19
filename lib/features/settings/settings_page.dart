import 'package:flutter/material.dart';
import '../timetable/timetable_settings_page.dart';
import '../workout/workout_settings_page.dart';
import '../birthday/birthday_settings_page.dart';
import '../journal/journal_entries_page.dart';
import '../motivation/motivation_bank_page.dart';
import '../todo/todo_checklists_page.dart';
import '../app_locker/app_lock_screen_time_page.dart';
import 'system_settings_page.dart';

class _ConfigEntry {
  final String title;
  final String desc;
  final IconData icon;
  final WidgetBuilder pageBuilder;

  const _ConfigEntry({required this.title, required this.desc, required this.icon, required this.pageBuilder});
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<_ConfigEntry> _configs = [
    _ConfigEntry(
      title: "Timetable Settings",
      desc: "Setup schedules & repeatable days",
      icon: Icons.calendar_today,
      pageBuilder: (context) => const TimetableSettingsPage(),
    ),
    _ConfigEntry(
      title: "App Lock & Screen Time",
      desc: "Check permissions, usage, and lock limits",
      icon: Icons.lock_clock,
      pageBuilder: (context) => const AppLockScreenTimePage(),
    ),
    _ConfigEntry(
      title: "Workout Planner",
      desc: "Edit exercise sets and rep counts",
      icon: Icons.fitness_center,
      pageBuilder: (context) => const WorkoutSettingsPage(),
    ),
    _ConfigEntry(
      title: "Birthday Registry",
      desc: "Track birthdays & configure alarms",
      icon: Icons.cake,
      pageBuilder: (context) => const BirthdaySettingsPage(),
    ),
    _ConfigEntry(
      title: "Journal Entries",
      desc: "Review daily entries & thoughts log",
      icon: Icons.book,
      pageBuilder: (context) => const JournalEntriesPage(),
    ),
    _ConfigEntry(
      title: "Todo Checklists",
      desc: "Manage custom categories & goals",
      icon: Icons.checklist,
      pageBuilder: (context) => const TodoChecklistsPage(),
    ),
    _ConfigEntry(
      title: "Motivation Bank",
      desc: "Manage your daily quote bank",
      icon: Icons.lightbulb,
      pageBuilder: (context) => const MotivationBankPage(),
    ),
    _ConfigEntry(
      title: "System Settings",
      desc: "Setup wallpaper, backup & launcher config",
      icon: Icons.settings,
      pageBuilder: (context) => const SystemSettingsPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "reFine CONFIG",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Configure lists, lock limits and default profiles",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _configs.length,
                  itemBuilder: (context, index) {
                    final item = _configs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF000000),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                          leading: Icon(item.icon, color: Colors.white, size: 28),
                          title: Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              item.desc,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white30),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: item.pageBuilder),
                            );
                          },
                        ),
                      ),
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
