import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timetable_provider.dart';
import '../../database/collections/task.dart';

class TimetableSettingsPage extends ConsumerStatefulWidget {
  const TimetableSettingsPage({super.key});

  @override
  ConsumerState<TimetableSettingsPage> createState() => _TimetableSettingsPageState();
}

class _TimetableSettingsPageState extends ConsumerState<TimetableSettingsPage> {
  
  // Format weekday short strings
  String _formatRepeatDays(List<int> repeatDays) {
    if (repeatDays.isEmpty) return "One-time";
    if (repeatDays.length == 7) return "Everyday";
    const shortDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return repeatDays.map((d) => shortDays[d - 1]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(timetableNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Timetable Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: () => _showAddTaskDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: tasksState.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
          error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
          data: (tasks) {
            if (tasks.isEmpty) {
              return const Center(
                child: Text(
                  "No tasks yet.",
                  style: TextStyle(color: Colors.white30, fontSize: 16),
                ),
              );
            }
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: tasks.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    task.title,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "${task.startTime} - ${task.endTime}  |  ${_formatRepeatDays(task.repeatDays)}",
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      ref.read(timetableNotifierProvider.notifier).deleteTask(task.id);
                    },
                  ),
                  onTap: () => _showAddTaskDialog(context, taskToEdit: task),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, {Task? taskToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AddTaskBottomSheet(taskToEdit: taskToEdit);
      },
    );
  }
}

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  final Task? taskToEdit;
  const AddTaskBottomSheet({super.key, this.taskToEdit});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _titleController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  DateTime _selectedDate = DateTime.now();
  bool _isRepeatable = false;
  final List<bool> _repeatDaysSelection = List.generate(7, (_) => false);

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      final task = widget.taskToEdit!;
      _titleController.text = task.title;
      _isRepeatable = task.isRepeatable;
      
      try {
        final startParts = task.startTime.split(':');
        _startTime = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
        
        final endParts = task.endTime.split(':');
        _endTime = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
      } catch (_) {}

      if (_isRepeatable) {
        for (var day in task.repeatDays) {
          if (day >= 1 && day <= 7) {
            _repeatDaysSelection[day - 1] = true;
          }
        }
      } else {
        _selectedDate = task.date ?? DateTime.now();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
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
          Text(
            widget.taskToEdit != null ? "Edit Timetable Task" : "Add Timetable Task",
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 1. Task Title
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Task Title",
              labelStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF222222),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Time Pickers (Start & End)
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text("Start Time", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  subtitle: Text(_formatTime(_startTime), style: const TextStyle(color: Colors.white, fontSize: 16)),
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: _startTime);
                    if (time != null) setState(() => _startTime = time);
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text("End Time", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  subtitle: Text(_formatTime(_endTime), style: const TextStyle(color: Colors.white, fontSize: 16)),
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: _endTime);
                    if (time != null) setState(() => _endTime = time);
                  },
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10),

          // 3. Repeatable Switch
          SwitchListTile(
            title: const Text("Repeatable Task", style: TextStyle(color: Colors.white)),
            subtitle: const Text("Repeat this task weekly on specified days", style: TextStyle(color: Colors.white38, fontSize: 12)),
            value: _isRepeatable,
            activeColor: Colors.white,
            onChanged: (val) {
              setState(() => _isRepeatable = val);
            },
          ),

          // 4. Repeat days selector or Date Picker
          if (_isRepeatable) ...[
            const SizedBox(height: 8),
            const Text("Repeat Days", style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final isSelected = _repeatDaysSelection[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _repeatDaysSelection[index] = !isSelected;
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
          ] else ...[
            ListTile(
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
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
          ],
          const SizedBox(height: 32),

          // 5. Submit Button
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
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a task title.")),
                  );
                  return;
                }

                final repeatDays = <int>[];
                if (_isRepeatable) {
                  for (int i = 0; i < 7; i++) {
                    if (_repeatDaysSelection[i]) {
                      repeatDays.add(i + 1); // 1 (Mon) - 7 (Sun)
                    }
                  }
                  if (repeatDays.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select at least one day to repeat.")),
                    );
                    return;
                  }
                }

                // Add or update task
                final newTask = Task()
                  ..title = title
                  ..startTime = _formatTime(_startTime)
                  ..endTime = _formatTime(_endTime)
                  ..isRepeatable = _isRepeatable
                  ..repeatDays = repeatDays
                  ..date = _isRepeatable ? null : DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

                if (widget.taskToEdit != null) {
                  newTask.id = widget.taskToEdit!.id;
                }

                ref.read(timetableNotifierProvider.notifier).addTask(newTask);
                Navigator.pop(context);
              },
              child: Text(
                widget.taskToEdit != null ? "UPDATE TASK" : "ADD TASK",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
