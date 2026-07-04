import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:io';
import '../settings/system_settings_provider.dart';
import '../launcher/launcher_provider.dart';
import '../launcher/app_info.dart';
import '../motivation/motivation_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatMonth(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }

  String _formatWeekday(int weekday) {
    const days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    return days[weekday - 1];
  }

  Color _getGridBoxColor(double percentage) {
    if (percentage < 0.0) return Colors.grey.shade800; // Neutral day
    if (percentage == 0.0) return Colors.redAccent.shade700; // 0% completed
    if (percentage < 0.5) return Colors.green.shade900; // Low completion
    if (percentage < 1.0) return Colors.green.shade700; // Moderate completion
    return Colors.green; // 100% completed
  }

  @override
  Widget build(BuildContext context) {
    final hour = _now.hour.toString().padLeft(2, '0');
    final minute = _now.minute.toString().padLeft(2, '0');
    final dateString = "${_now.day} ${_formatMonth(_now.month)}";
    final weekdayString = _formatWeekday(_now.weekday);

    // Watch settings and launcher
    final settingsState = ref.watch(systemSettingsProvider);
    final launcherState = ref.watch(launcherNotifierProvider);
    final quoteText = ref.watch(randomQuoteProvider);
    final weekProgressState = ref.watch(currentWeekProgressProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent to allow launcher shell wallpaper to show
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Time, Day & Date (Premium Top Clock)
              const SizedBox(height: 20),
              Text(
                "$hour:$minute",
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$weekdayString, $dateString",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // 2. Vertical list of chosen apps (Customizable App List Widget)
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E).withOpacity(0.8), // Semi-transparent glassmorphism look
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "FAVORITES",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white38,
                              letterSpacing: 1.5,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white38, size: 14),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _showFavoritesDialog(
                              context,
                              settingsState.maybeWhen(
                                data: (settings) => List<String>.from(settings.favoriteApps),
                                orElse: () => <String>[],
                              ),
                              launcherState.apps,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: settingsState.when(
                          loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                          error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
                          data: (settings) {
                            final favorites = settings.favoriteApps;

                            if (favorites.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "No favorites configured.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white30, fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      icon: const Icon(Icons.add, color: Colors.white, size: 16),
                                      label: const Text("ADD APPS", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                      onPressed: () => _showFavoritesDialog(context, [], launcherState.apps),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: favorites.length,
                              itemBuilder: (context, index) {
                                final pkg = favorites[index];
                                final appInfo = launcherState.apps.firstWhere(
                                  (a) => a.packageName == pkg,
                                  orElse: () => AppInfo(name: pkg.split('.').last, packageName: pkg),
                                );

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: ListTile(
                                    title: Text(
                                      appInfo.name,
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                                    onTap: () {
                                      ref.read(launcherNotifierProvider.notifier).launchApp(pkg);
                                    },
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
              ),
              const SizedBox(height: 32),

              // 3. Week task progress widget (GitHub style 7 boxes)
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "WEEK PROGRESS",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white38,
                            letterSpacing: 1.2,
                          ),
                        ),
                        (() {
                          final days = weekProgressState.valueOrNull;
                          if (days != null) {
                            final todayProgress = days.firstWhere(
                              (d) {
                                final now = DateTime.now();
                                return d.date.year == now.year &&
                                       d.date.month == now.month &&
                                       d.date.day == now.day;
                              },
                              orElse: () => WeeklyProgressDay(date: DateTime.now(), completedCount: 0, totalCount: 0),
                            );
                            final percent = todayProgress.totalCount == 0
                                ? 0
                                : (todayProgress.completedCount / todayProgress.totalCount * 100).round();
                            return Text(
                              "$percent% Completed Today",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white54,
                              ),
                            );
                          }
                          return const Text("0% Completed Today", style: TextStyle(fontSize: 10, color: Colors.white54));
                        })(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    (() {
                      final days = weekProgressState.valueOrNull;
                      if (days != null) {
                        const daysShort = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(7, (index) {
                            final dayProgress = days[index];
                            final todayMidnight = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                            final isFutureDay = dayProgress.date.isAfter(todayMidnight);
                            final boxColor = isFutureDay 
                                ? Colors.grey.shade800
                                : _getGridBoxColor(dayProgress.percentage);

                            return Column(
                              children: [
                                Tooltip(
                                  message: dayProgress.totalCount == 0
                                      ? "No tasks"
                                      : "${dayProgress.completedCount}/${dayProgress.totalCount} completed",
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: boxColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  daysShort[index],
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }),
                        );
                      }
                      return const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                      );
                    })(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Motivation Card Widget (Hidable via Settings)
              settingsState.maybeWhen(
                data: (settings) {
                  if (!settings.quoteEnabled) return const SizedBox(height: 16);
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E).withOpacity(0.8), // Purple tinted glassmorphic card
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.lightbulb_outline, color: Colors.amberAccent, size: 16),
                            SizedBox(width: 8),
                            Text(
                              "DAILY MOTIVATION",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white38,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            "\"$quoteText\"",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  void _showFavoritesDialog(BuildContext context, List<String> currentFavorites, List<AppInfo> allApps) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF161616),
              title: const Text("Select Favorite Apps", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView.separated(
                  itemCount: allApps.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                  itemBuilder: (context, index) {
                    final app = allApps[index];
                    final isFav = currentFavorites.contains(app.packageName);
                    return CheckboxListTile(
                      title: Text(app.name, style: const TextStyle(color: Colors.white)),
                      value: isFav,
                      activeColor: Colors.white,
                      checkColor: Colors.black,
                      onChanged: (val) {
                        ref.read(systemSettingsProvider.notifier).toggleFavoriteApp(app.packageName);
                        setDialogState(() {
                          if (val == true) {
                            if (!currentFavorites.contains(app.packageName)) {
                              currentFavorites.add(app.packageName);
                            }
                          } else {
                            currentFavorites.remove(app.packageName);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
