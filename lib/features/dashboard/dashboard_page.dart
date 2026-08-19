import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../timetable/timetable_provider.dart';
import '../timetable/current_date_provider.dart';
import '../workout/workout_provider.dart';
import '../../database/collections/task.dart';
import '../../database/collections/task_completion.dart';
import '../../database/collections/workout.dart';
import '../../database/collections/workout_set_progress.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _workoutExpanded = false;
  bool _timetableExpanded = false;
  // Optimistic local overrides so the checkbox and its color transition play
  // instantly on tap instead of waiting on the DB write + FutureProvider
  // round-trip. Cleared once that round-trip lands (success or failure), at
  // which point the real data already agrees with what was shown.
  final Map<int, bool> _pendingCompletionOverrides = {};

  // Tasks that were just checked off are kept in their current spot in the
  // sort order for a beat, so the checkbox turns green in place before the
  // tile glides down to join the completed group - rather than jumping there
  // instantly. Unchecking a task always sorts it back immediately.
  final Set<int> _sortHoldIds = {};
  final Map<int, int> _sortHoldGeneration = {};
  static const _sortHoldDuration = Duration(seconds: 1);

  bool _isTaskDoneEffective(int taskId, List<TaskCompletion> completions) {
    return _pendingCompletionOverrides[taskId] ??
        completions.any((c) => c.taskId == taskId && c.completed);
  }

  bool _isTaskDoneForSort(int taskId, List<TaskCompletion> completions) {
    if (_sortHoldIds.contains(taskId)) return false;
    return _isTaskDoneEffective(taskId, completions);
  }

  void _toggleTaskCompletion(int taskId, bool completed) {
    setState(() {
      _pendingCompletionOverrides[taskId] = completed;
      if (completed) {
        _sortHoldIds.add(taskId);
        final generation = (_sortHoldGeneration[taskId] ?? 0) + 1;
        _sortHoldGeneration[taskId] = generation;
        Future.delayed(_sortHoldDuration, () {
          if (mounted && _sortHoldGeneration[taskId] == generation) {
            setState(() => _sortHoldIds.remove(taskId));
          }
        });
      } else {
        _sortHoldGeneration[taskId] = (_sortHoldGeneration[taskId] ?? 0) + 1;
        _sortHoldIds.remove(taskId);
      }
    });
    final date = ref.read(currentDateProvider).value ?? DateTime.now();
    ref.read(timetableNotifierProvider.notifier).toggleTaskCompletion(taskId, date, completed).whenComplete(() {
      if (mounted) {
        setState(() {
          _pendingCompletionOverrides.remove(taskId);
        });
      }
    });
  }

  int _timeToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return 0;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  bool _isTaskActive(Task task, DateTime now) {
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = _timeToMinutes(task.startTime);
    final endMinutes = _timeToMinutes(task.endTime);

    if (startMinutes <= endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Crosses midnight
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  List<Task> _sortTasksWithActiveOnTop(List<Task> tasks, List<TaskCompletion> completions) {
    final now = DateTime.now();

    // Helper to check if a task is completed today, for sort purposes -
    // holds a just-checked task in its old spot for a beat (see
    // _sortHoldIds) so it doesn't jump to the bottom instantly.
    bool isTaskDone(Task task) {
      return _isTaskDoneForSort(task.id, completions);
    }

    int byStartTime(Task a, Task b) => _timeToMinutes(a.startTime).compareTo(_timeToMinutes(b.startTime));

    // Sort order:
    // 1. Active & Uncompleted, chronological (White tile - "happening now")
    // 2. Everything else uncompleted, chronological (Dark blue/grey tile)
    // 3. Everything completed, chronological, in its own group at the bottom
    //    (Green tile) - regardless of whether it's still "active" right now.
    final activeUncompleted = tasks.where((t) => _isTaskActive(t, now) && !isTaskDone(t)).toList()..sort(byStartTime);
    final inactiveUncompleted = tasks.where((t) => !_isTaskActive(t, now) && !isTaskDone(t)).toList()..sort(byStartTime);
    final completed = tasks.where(isTaskDone).toList()..sort(byStartTime);

    return [
      ...activeUncompleted,
      ...inactiveUncompleted,
      ...completed,
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Watch today's workouts and set progress
    final todayWorkouts = ref.watch(todayWorkoutsProvider);
    final workoutProgressState = ref.watch(todayWorkoutProgressProvider);

    // Check if ALL sets of ALL workouts today are completed
    bool allSetsChecked = false;
    if (todayWorkouts.isNotEmpty) {
      allSetsChecked = workoutProgressState.maybeWhen(
        skipLoadingOnReload: true,
        data: (progressList) {
          int completedCount = 0;
          for (var workout in todayWorkouts) {
            WorkoutSetProgress? progress;
            for (var p in progressList) {
              if (p.workoutId == workout.id) {
                progress = p;
                break;
              }
            }
            if (progress != null &&
                progress.setsCompleted.length == workout.sets &&
                progress.setsCompleted.every((val) => val)) {
              completedCount++;
            }
          }
          return completedCount == todayWorkouts.length;
        },
        orElse: () => false,
      );
    }

    final todayTasksState = ref.watch(todayTasksProvider);
    final completionsState = ref.watch(todayCompletionsProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: _workoutExpanded
              ? _buildExpandedWorkoutView(todayWorkouts, workoutProgressState)
              : _timetableExpanded
                  ? _buildExpandedTimetableView(context, todayTasksState, completionsState)
                  : _buildDashboardWidgetsView(context, allSetsChecked, todayWorkouts, workoutProgressState),
        ),
      ),
    );
  }

  Widget _buildDashboardWidgetsView(
    BuildContext context,
    bool allSetsChecked,
    List<Workout> todayWorkouts,
    AsyncValue<List<WorkoutSetProgress>> workoutProgressState,
  ) {
    final todayTasksState = ref.watch(todayTasksProvider);
    final completionsState = ref.watch(todayCompletionsProvider);

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "TODAY",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white60,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),

          // 1. Timetable Widget (Dark Blue Background, expandable) - given
          // the larger share of vertical space since it's the widget with
          // actual scrollable content, unlike the workout summary below.
          GestureDetector(
            onTap: () {
              setState(() {
                _timetableExpanded = true;
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 320,
              decoration: BoxDecoration(
                color: const Color(0xFF000000),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "TIMETABLE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white38,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Icon(
                        Icons.open_in_full,
                        size: 14,
                        color: Colors.white38,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _buildTimetableList(context, todayTasksState, completionsState, isExpanded: false),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),

          // 2. Workout Planner Widget (80% width, expandable on tap) - kept
          // compact since it only ever shows a one-line summary here, not a
          // scrollable list like the timetable widget above.
          GestureDetector(
            onTap: () {
              setState(() {
                _workoutExpanded = true;
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF000000),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "WORKOUT PLANNER",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white38,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Icon(
                        Icons.open_in_full,
                        size: 14,
                        color: Colors.white38,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: allSetsChecked ? Colors.green : const Color(0xFF2E2E2E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                todayWorkouts.isEmpty
                                    ? "No workouts for today"
                                    : todayWorkouts.length == 1
                                        ? "${todayWorkouts.first.name} (${todayWorkouts.first.sets} sets x ${todayWorkouts.first.reps})"
                                        : "${todayWorkouts.length} Workouts Scheduled",
                                style: TextStyle(
                                  color: allSetsChecked ? Colors.black : Colors.white,
                                  fontWeight: allSetsChecked ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            Icon(
                              allSetsChecked ? Icons.check_circle : Icons.arrow_drop_down,
                              color: allSetsChecked ? Colors.black : Colors.white54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildExpandedTimetableView(
    BuildContext context,
    AsyncValue<List<Task>> todayTasksState,
    AsyncValue<List<TaskCompletion>> completionsState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _timetableExpanded = false;
            });
          },
        ),
        const SizedBox(height: 16),
        const Text(
          "TODAY'S TIMETABLE",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: _buildTimetableList(context, todayTasksState, completionsState, isExpanded: true),
        ),
      ],
    );
  }

  Widget _buildExpandedWorkoutView(
    List<Workout> todayWorkouts,
    AsyncValue<List<WorkoutSetProgress>> workoutProgressState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _workoutExpanded = false;
            });
          },
        ),
        const SizedBox(height: 16),
        const Text(
          "TODAY'S WORKOUTS",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: todayWorkouts.isEmpty
              ? const Center(
                  child: Text("No workouts scheduled for today.", style: TextStyle(color: Colors.white38, fontSize: 14)),
                )
              : workoutProgressState.when(
                  skipLoadingOnReload: true,
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                  error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
                  data: (progressList) {
                    return ListView.builder(
                      itemCount: todayWorkouts.length,
                      itemBuilder: (context, index) {
                        final workout = todayWorkouts[index];
                        WorkoutSetProgress? progress;
                        for (var p in progressList) {
                          if (p.workoutId == workout.id) {
                            progress = p;
                            break;
                          }
                        }

                        // Extract completed sets status list
                        final setsCompleted = progress != null
                            ? List<bool>.from(progress.setsCompleted)
                            : List<bool>.generate(workout.sets, (_) => false);

                        final isWorkoutDone = setsCompleted.length == workout.sets &&
                            setsCompleted.every((val) => val);

                        return Padding(
                          key: ValueKey(workout.id),
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isWorkoutDone ? Colors.green : const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              // Material 3's ExpansionTile draws a visible top/bottom
                              // border by default - remove it, the Container already
                              // has its own background/border.
                              shape: const Border(),
                              collapsedShape: const Border(),
                              iconColor: isWorkoutDone ? Colors.black : Colors.white,
                              collapsedIconColor: isWorkoutDone ? Colors.black : Colors.white,
                              title: Text(
                                workout.name,
                                style: TextStyle(
                                  color: isWorkoutDone ? Colors.black : Colors.white,
                                  fontWeight: isWorkoutDone ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                "${workout.sets} sets x ${workout.reps} reps",
                                style: TextStyle(
                                  color: isWorkoutDone ? Colors.black54 : Colors.white60,
                                ),
                              ),
                              children: List.generate(workout.sets, (setIdx) {
                                final isSetDone = setIdx < setsCompleted.length ? setsCompleted[setIdx] : false;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isSetDone ? Colors.green : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: isSetDone ? Colors.transparent : Colors.white10),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        "Set ${setIdx + 1}: ${workout.reps} reps",
                                        style: TextStyle(
                                          color: isSetDone ? Colors.black : Colors.white70,
                                          fontWeight: isSetDone ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      trailing: Checkbox(
                                        activeColor: Colors.black,
                                        checkColor: Colors.green,
                                        value: isSetDone,
                                        onChanged: (val) {
                                          final date = ref.read(currentDateProvider).value ?? DateTime.now();
                                          ref.read(workoutNotifierProvider.notifier).toggleWorkoutSet(
                                                workout.id,
                                                date,
                                                setIdx,
                                                val ?? false,
                                              );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTimetableList(
    BuildContext context,
    AsyncValue<List<Task>> todayTasksState,
    AsyncValue<List<TaskCompletion>> completionsState, {
    required bool isExpanded,
  }) {
    final tasks = todayTasksState.valueOrNull;
    final completions = completionsState.valueOrNull;

    if (tasks == null || completions == null) {
      if (todayTasksState.hasError) {
        return Center(
          child: Text("Error: ${todayTasksState.error}", style: const TextStyle(color: Colors.red)),
        );
      }
      if (completionsState.hasError) {
        return Center(
          child: Text("Error: ${completionsState.error}", style: const TextStyle(color: Colors.red)),
        );
      }
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (tasks.isEmpty) {
      return Center(
        child: Text(
          "No tasks scheduled for today.",
          style: TextStyle(
            color: Colors.white38,
            fontSize: isExpanded ? 14 : 13,
          ),
        ),
      );
    }

    final sortedTasks = _sortTasksWithActiveOnTop(tasks, completions);
    final spacing = isExpanded ? 12.0 : 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final heights = [
          for (final task in sortedTasks) _computeTileHeight(task.title, constraints.maxWidth, isExpanded),
        ];
        final tops = <double>[];
        double running = 0;
        for (final h in heights) {
          tops.add(running);
          running += h + spacing;
        }
        final totalHeight = heights.isEmpty ? 0.0 : running - spacing;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: totalHeight,
            child: Stack(
              children: [
                for (int index = 0; index < sortedTasks.length; index++)
                  AnimatedPositioned(
                    key: ValueKey(sortedTasks[index].id),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInOutCubic,
                    top: tops[index],
                    left: 0,
                    right: 0,
                    height: heights[index],
                    child: _buildTimetableTile(sortedTasks[index], completions, isExpanded),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Tiles need to grow when a long task title wraps to multiple lines,
  // otherwise the time-range subtitle gets pushed out and clipped past the
  // tile's fixed bottom edge. Measures how much taller the title becomes
  // once wrapped at the tile's actual width, and adds that on top of the
  // single-line base height.
  double _computeTileHeight(String title, double tileWidth, bool isExpanded) {
    const titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    // Space the title text doesn't get: tile's own horizontal padding, the
    // trailing checkbox, and the gap between title and trailing widget.
    final availableTextWidth = (tileWidth - 100.0).clamp(1.0, double.infinity);

    final singleLine = TextPainter(
      text: TextSpan(text: title, style: titleStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final wrapped = TextPainter(
      text: TextSpan(text: title, style: titleStyle),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: availableTextWidth);

    final extraHeight = (wrapped.size.height - singleLine.size.height).clamp(0.0, double.infinity);
    final baseHeight = isExpanded ? 88.0 : 68.0;
    return baseHeight + extraHeight;
  }

  Widget _buildTimetableTile(Task task, List<TaskCompletion> completions, bool isExpanded) {
    final isDone = _isTaskDoneEffective(task.id, completions);
    final isActive = _isTaskActive(task, DateTime.now());

    Color tileColor;
    Color textColor;
    Color subtitleColor;
    Color checkColor;
    Color activeColor;

    if (isDone) {
      tileColor = Colors.green;
      textColor = Colors.black;
      subtitleColor = Colors.black;
      checkColor = Colors.green;
      activeColor = Colors.black;
    } else if (isActive) {
      tileColor = Colors.white;
      textColor = Colors.black;
      subtitleColor = Colors.black;
      checkColor = Colors.black;
      activeColor = Colors.white;
    } else {
      tileColor = const Color(0xFF1E2D3D);
      textColor = Colors.white;
      subtitleColor = Colors.white;
      checkColor = Colors.white;
      activeColor = const Color(0xFF1E2D3D);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: isExpanded
            ? const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
            : null,
        title: Text(
          task.title,
          style: TextStyle(
            color: textColor,
            fontWeight: (isDone || isActive) ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          "${task.startTime} - ${task.endTime}",
          style: TextStyle(
            color: subtitleColor,
            fontSize: 12,
          ),
        ),
        trailing: Checkbox(
          activeColor: activeColor,
          checkColor: checkColor,
          side: BorderSide(color: textColor.withOpacity(0.6), width: 2),
          value: isDone,
          onChanged: (val) {
            _toggleTaskCompletion(task.id, val ?? false);
          },
        ),
      ),
    );
  }
}
