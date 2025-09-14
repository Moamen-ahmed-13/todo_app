part of 'todo_cubit.dart';

class TodoState extends Equatable {
  final List<Task> tasks;
  final String filter;

  const TodoState({
    this.tasks = const [],
    this.filter = 'All',
  });

  TodoState copyWith({
    List<Task>? tasks,
    String? filter,
  }) {
    return TodoState(
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object> get props => [tasks, filter];
}