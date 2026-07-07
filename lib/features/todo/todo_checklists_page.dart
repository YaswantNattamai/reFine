import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_provider.dart';
import '../../database/collections/todo_list.dart';

class TodoChecklistsPage extends ConsumerStatefulWidget {
  const TodoChecklistsPage({super.key});

  @override
  ConsumerState<TodoChecklistsPage> createState() => _TodoChecklistsPageState();
}

class _TodoChecklistsPageState extends ConsumerState<TodoChecklistsPage> {
  final _listNameController = TextEditingController();

  @override
  void dispose() {
    _listNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Todo Checklists", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Add custom list category
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _listNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Create a new list category (e.g. Personal)...",
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: const Color(0xFF161616),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final text = _listNameController.text.trim();
                    if (text.isEmpty) return;
                    ref.read(todoNotifierProvider.notifier).addTodoList(text);
                    _listNameController.clear();
                    FocusScope.of(context).unfocus();
                  },
                  child: const Icon(Icons.add, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Categories list
            Expanded(
              child: todoState.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
                data: (todoLists) {
                  if (todoLists.isEmpty) {
                    return const Center(
                      child: Text(
                        "No todo checklists created yet.",
                        style: TextStyle(color: Colors.white30, fontSize: 14),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: todoLists.length,
                    itemBuilder: (context, index) {
                      final list = todoLists[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Card(
                          color: const Color(0xFF161616),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white10),
                          ),
                          child: ExpansionTile(
                            iconColor: Colors.white,
                            collapsedIconColor: Colors.white54,
                            title: Text(
                              list.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () {
                                ref.read(todoNotifierProvider.notifier).deleteTodoList(list.id);
                              },
                            ),
                            children: [
                              const Divider(color: Colors.white10),
                              
                              // List Items
                              ...list.items.map((item) {
                                final isDone = item.isCompleted;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isDone ? Colors.green : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: isDone ? Colors.transparent : Colors.white12),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                      dense: true,
                                      title: Text(
                                        item.text,
                                        style: TextStyle(
                                          color: isDone ? Colors.black : Colors.white70,
                                          fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                                          decoration: isDone ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            activeColor: Colors.black,
                                            checkColor: Colors.green,
                                            value: isDone,
                                            onChanged: (val) {
                                              ref.read(todoNotifierProvider.notifier).toggleTodoItem(item.id, val ?? false);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                                            onPressed: () {
                                              ref.read(todoNotifierProvider.notifier).deleteTodoItem(item.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),

                              // Add item input row inside the list expansion
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: AddTodoItemInputRow(listId: list.id),
                              ),
                            ],
                          ),
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
}

class AddTodoItemInputRow extends ConsumerStatefulWidget {
  final int listId;
  const AddTodoItemInputRow({super.key, required this.listId});

  @override
  ConsumerState<AddTodoItemInputRow> createState() => _AddTodoItemInputRowState();
}

class _AddTodoItemInputRowState extends ConsumerState<AddTodoItemInputRow> {
  final _itemController = TextEditingController();

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _itemController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: "Add item...",
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF222222),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.white, size: 28),
          onPressed: () {
            final text = _itemController.text.trim();
            if (text.isEmpty) return;
            ref.read(todoNotifierProvider.notifier).addTodoItem(widget.listId, text);
            _itemController.clear();
          },
        ),
      ],
    );
  }
}
