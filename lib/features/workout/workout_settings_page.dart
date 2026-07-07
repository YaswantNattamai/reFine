import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'workout_provider.dart';
import '../../database/collections/workout.dart';

class WorkoutSettingsPage extends ConsumerStatefulWidget {
  const WorkoutSettingsPage({super.key});

  @override
  ConsumerState<WorkoutSettingsPage> createState() => _WorkoutSettingsPageState();
}

class _WorkoutSettingsPageState extends ConsumerState<WorkoutSettingsPage> {
  String _formatActiveDays(List<int> activeDays) {
    if (activeDays.isEmpty) return "None";
    if (activeDays.length == 7) return "Everyday";
    const shortDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return activeDays.map((d) => shortDays[d - 1]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final workoutsState = ref.watch(workoutNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Workout Planner", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: () => _showAddWorkoutDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: workoutsState.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
          error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
          data: (workouts) {
            if (workouts.isEmpty) {
              return const Center(
                child: Text(
                  "No workouts added yet.",
                  style: TextStyle(color: Colors.white30, fontSize: 16),
                ),
              );
            }
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: workouts.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    workout.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "${workout.sets} sets x ${workout.reps} reps  |  ${_formatActiveDays(workout.activeDays)}",
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      ref.read(workoutNotifierProvider.notifier).deleteWorkout(workout.id);
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

  void _showAddWorkoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const AddWorkoutBottomSheet();
      },
    );
  }
}

class AddWorkoutBottomSheet extends ConsumerStatefulWidget {
  const AddWorkoutBottomSheet({super.key});

  @override
  ConsumerState<AddWorkoutBottomSheet> createState() => _AddWorkoutBottomSheetState();
}

class _AddWorkoutBottomSheetState extends ConsumerState<AddWorkoutBottomSheet> {
  final _nameController = TextEditingController();
  int _sets = 3;
  int _reps = 10;
  final List<bool> _activeDaysSelection = List.generate(7, (_) => false);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add Workout Routine",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 1. Exercise Name
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Exercise Name (e.g. Pushups)",
              labelStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF222222),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Sets and Reps Counter
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Sets", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                          onPressed: () {
                            if (_sets > 1) setState(() => _sets--);
                          },
                        ),
                        Text("$_sets", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                          onPressed: () => setState(() => _sets++),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Reps per set", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                          onPressed: () {
                            if (_reps > 1) setState(() => _reps--);
                          },
                        ),
                        Text("$_reps", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                          onPressed: () => setState(() => _reps++),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),

          // 3. Active Days Selector
          const Text("Schedule Days", style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isSelected = _activeDaysSelection[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _activeDaysSelection[index] = !isSelected;
                  });
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Center(
                    child: Text(
                      weekdays[index],
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),

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
                final name = _nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter an exercise name.")),
                  );
                  return;
                }

                final activeDays = <int>[];
                for (int i = 0; i < 7; i++) {
                  if (_activeDaysSelection[i]) {
                    activeDays.add(i + 1); // 1 (Mon) - 7 (Sun)
                  }
                }
                if (activeDays.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select at least one day to repeat.")),
                  );
                  return;
                }

                final workout = Workout()
                  ..name = name
                  ..sets = _sets
                  ..reps = _reps
                  ..activeDays = activeDays;

                ref.read(workoutNotifierProvider.notifier).addWorkout(workout);
                Navigator.pop(context);
              },
              child: const Text("SAVE WORKOUT", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
