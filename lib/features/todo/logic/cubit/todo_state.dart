part of 'todo_cubit.dart';

enum TaskFilter { all, pending, completed }

class TodoState extends Equatable {
  final List<Task> tasks;
  final TaskFilter filter;
  final bool isLoading;
  final String? error;

  const TodoState({
    this.tasks = const [],
    this.filter = TaskFilter.pending,
    this.isLoading = false,
    this.error,
  });

  List<Task> get filteredTasks {
    switch (filter) {
      case TaskFilter.completed:
        return tasks.where((e) => e.isDone).toList();
      case TaskFilter.pending:
        return tasks.where((e) => !e.isDone).toList();
      default:
        return tasks;
    }
  }

  TodoState copyWith({
    List<Task>? tasks,
    TaskFilter? filter,
    bool? isLoading,
    String? error,
  }) {
    return TodoState(
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [tasks, filter, isLoading, error];
}
