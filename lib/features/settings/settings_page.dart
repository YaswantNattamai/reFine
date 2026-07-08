import 'package:flutter/material.dart';
import '../timetable/timetable_settings_page.dart';
import '../workout/workout_settings_page.dart';
import '../birthday/birthday_settings_page.dart';
import '../journal/journal_entries_page.dart';
import '../motivation/motivation_bank_page.dart';
import '../todo/todo_checklists_page.dart';
import 'system_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Build a grid/list of cards to open configuration sections
  final List<Map<String, dynamic>> _configs = [
    {"title": "Timetable Settings", "desc": "Setup schedules & repeatable days", "icon": Icons.calendar_today, "color": const Color(0xFF0F1B29)},
    {"title": "Workout Planner", "desc": "Edit exercise sets and rep counts", "icon": Icons.fitness_center, "color": const Color(0xFF1B2A1C)},
    {"title": "Birthday Registry", "desc": "Track birthdays & configure alarms", "icon": Icons.cake, "color": const Color(0xFF2E1A1A)},
    {"title": "Journal Entries", "desc": "Review daily entries & thoughts log", "icon": Icons.book, "color": const Color(0xFF2A2E1A)},
    {"title": "Motivation Bank", "desc": "Manage your daily quote bank", "icon": Icons.lightbulb, "color": const Color(0xFF2A1A2E)},
    {"title": "Todo Checklists", "desc": "Manage custom categories & goals", "icon": Icons.checklist, "color": const Color(0xFF1A2A2E)},
    {"title": "System Settings", "desc": "Setup locker limits & custom wallpaper", "icon": Icons.settings, "color": const Color(0xFF2E2E2E)},
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
                          color: item["color"],
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
                          leading: Icon(item["icon"], color: Colors.white, size: 28),
                          title: Text(
                            item["title"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              item["desc"],
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white30),
                          onTap: () {
                            Widget targetPage;
                            switch (index) {
                              case 0:
                                targetPage = const TimetableSettingsPage();
                                break;
                              case 1:
                                targetPage = const WorkoutSettingsPage();
                                break;
                              case 2:
                                targetPage = const BirthdaySettingsPage();
                                break;
                              case 3:
                                targetPage = const JournalEntriesPage();
                                break;
                              case 4:
                                targetPage = const MotivationBankPage();
                                break;
                              case 5:
                                targetPage = const TodoChecklistsPage();
                                break;
                              case 6:
                                targetPage = const SystemSettingsPage();
                                break;
                              default:
                                return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => targetPage),
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
