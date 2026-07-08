import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../timetable/timetable_provider.dart';
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

    // Helper to check if a task is completed today
    bool isTaskDone(Task task) {
      return completions.any((c) => c.taskId == task.id && c.completed);
    }

    // Sort order:
    // 1. Active & Uncompleted (White tile)
    // 2. Active & Completed (Green tile)
    // 3. Inactive & Uncompleted (Dark blue/grey tile)
    // 4. Inactive & Completed (Green tile)
    final activeUncompleted = tasks.where((t) => _isTaskActive(t, now) && !isTaskDone(t)).toList();
    final activeCompleted = tasks.where((t) => _isTaskActive(t, now) && isTaskDone(t)).toList();
    final inactiveUncompleted = tasks.where((t) => !_isTaskActive(t, now) && !isTaskDone(t)).toList();
    final inactiveCompleted = tasks.where((t) => !_isTaskActive(t, now) && isTaskDone(t)).toList();

    return [
      ...activeUncompleted,
      ...activeCompleted,
      ...inactiveUncompleted,
      ...inactiveCompleted,
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

          // 1. Timetable Widget (Dark Blue Background, 220h, expandable)
          GestureDetector(
            onTap: () {
              setState(() {
                _timetableExpanded = true;
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFF0F1B29), // Dark blue background
                borderRadius: BorderRadius.circular(16),
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

          // 2. Workout Planner Widget (80% width, expandable on tap)
          GestureDetector(
            onTap: () {
              setState(() {
                _workoutExpanded = true;
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
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
                  const SizedBox(height: 16),
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
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isWorkoutDone ? Colors.green : const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
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
                                          ref.read(workoutNotifierProvider.notifier).toggleWorkoutSet(
                                                workout.id,
                                                DateTime.now(),
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

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: sortedTasks.length,
      itemBuilder: (context, index) {
        final task = sortedTasks[index];
        final isDone = completions.any((c) => c.taskId == task.id && c.completed);
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

        return Padding(
          padding: EdgeInsets.only(bottom: isExpanded ? 12.0 : 8.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
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
                  ref
                      .read(timetableNotifierProvider.notifier)
                      .toggleTaskCompletion(task.id, DateTime.now(), val ?? false);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
