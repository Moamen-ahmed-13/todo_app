import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/features/todo/logic/todo_cubit.dart';

class TodoApp extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const TodoApp({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TodoCubit>();
    final isDark = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Tasks",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.deepPurple.shade900, Colors.black]
                  : [Colors.deepPurple, Colors.purpleAccent],
            ),
          ),
        ),
        actions: [
          PopupMenuButton<TaskFilter>(
            tooltip: 'Filter tasks',
            onSelected: (TaskFilter filter) {
              cubit.changeFilter(filter);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: TaskFilter.all, child: Text('All')),
              PopupMenuItem(value: TaskFilter.pending, child: Text('Pending')),
              PopupMenuItem(value: TaskFilter.completed, child: Text('Completed')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: widget.onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Add a new task...",
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
                prefixIcon: const Icon(Icons.edit_note),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _controller.clear()),
                        tooltip: 'Clear input',
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (value) {
                cubit.addTask(value);
                _controller.clear();
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<TodoCubit, TodoState>(
              builder: (context, state) {
                final tasks = cubit.filteredTasks;
                if (tasks.isEmpty) {
                  return Center(
                    child: Text(
                      'No tasks yet 🎉',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.6),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final originalIndex = state.tasks.indexOf(task);
                    final isOverdue = task.date != null &&
                        task.date!.isBefore(DateTime.now()) &&
                        !task.isDone;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isDone,
                          onChanged: (value) =>
                              cubit.toggleDone(originalIndex, value ?? false),
                        ),
                        title: Text(
                          task.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: task.isDone
                                ? Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withOpacity(0.5)
                                : Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        subtitle: task.date != null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: isOverdue
                                        ? Colors.redAccent
                                        : Theme.of(context)
                                            .colorScheme
                                            .onBackground
                                            .withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 125,
                                    child: Text(
                                      "Due: ${DateFormat.yMMMd().format(task.date!)}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: isOverdue
                                            ? Colors.redAccent
                                            : Theme.of(context)
                                                .colorScheme
                                                .onBackground
                                                .withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : null,
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blueAccent),
                              onPressed: () => _showEditDialog(
                                  context, cubit, originalIndex, task.title),
                              tooltip: 'Edit Task',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () => _showDeleteDialog(
                                  context, cubit, originalIndex),
                              tooltip: 'Delete Task',
                            ),
                          ],
                        ),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: task.date ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            cubit.updateDate(originalIndex, pickedDate);
                          }
                        },
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        tileColor: isDark ? Colors.grey[900] : Colors.grey[100],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final text = _controller.text.trim();
          if (text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a task'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
          cubit.addTask(text);
          _controller.clear();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor:
            isDark ? Colors.deepPurple.shade900 : Colors.deepPurple,
        tooltip: 'Add Task',
        child: const Icon(
          Icons.add,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, TodoCubit cubit, int index,
      String currentTitle) async {
    final controller = TextEditingController(text: currentTitle);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter new task name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save'),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      cubit.editTask(index, newName);
    }
  }

  Future<void> _showDeleteDialog(
      BuildContext context, TodoCubit cubit, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      cubit.deleteTask(index);
    }
  }
}
