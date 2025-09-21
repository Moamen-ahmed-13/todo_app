import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/features/todo/data/task_model.dart';
import 'package:todo_app/features/todo/logic/todo_repo.dart';

part 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
final TodoRepository todoRepository;

  TodoCubit(this.todoRepository) : super(const TodoState()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final tasks = await todoRepository.loadTasks();
      emit(state.copyWith(tasks: tasks, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to load tasks: $e'));
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    try {
      final box = await Hive.openBox<Task>('tasksBox');
      await box.clear();
      await box.addAll(tasks);
      emit(state.copyWith(tasks: tasks, isLoading: false, error: null));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to save tasks'));
    }
  }

  Future<void> _update(
      FutureOr<List<Task>> Function(List<Task> tasks) updateFn) async {
    try {
      final updated = await updateFn(List<Task>.from(state.tasks));
      emit(state.copyWith(tasks: updated));
      await saveTasks(updated);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update tasks: $e'));
    }
  }

  void addTask(String title, {DateTime? date}) async {
    try {
      if (title.trim().isEmpty) return;
      final newTask = Task(title: title.trim(), date: date);
      await _update((tasks) => [...tasks, newTask]);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add task: $e'));
    }
  }

  Future<void> editTask(int index, String newTitle) async {
    try {
      if (newTitle.trim().isEmpty) return;
      await _update((tasks) async {
        tasks[index] = tasks[index].copyWith(title: newTitle.trim());
        return tasks;
      });
    } catch (e) {
      emit(state.copyWith(error: 'Failed to edit task: $e'));
    }
  }

  Future<void> deleteTask(int index) async {
    try {
      await _update((tasks) async {
        tasks.removeAt(index);
        return tasks;
      });
    } catch (e) {
      emit(state.copyWith(error: 'Failed to delete task: $e'));
    }
  }

  Future<void> toggleDone(int index, bool isDone) async {
    try {
      await _update((tasks) async {
        tasks[index] = tasks[index].copyWith(isDone: isDone);
        return tasks;
      });
    } catch (e) {
      emit(state.copyWith(error: 'Failed to toggle task: $e'));
    }
  }

  Future<void> updateDate(int index, DateTime? date) async {
    try {
      await _update((tasks) async {
        tasks[index]=tasks[index].copyWith(date: date);
        return tasks;
      });
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update task: $e'));
    }
  }

  Future<void> changeFilter(TaskFilter filter) async{
    emit(state.copyWith(filter: filter));
  }

  List<Task> get filteredTasks{
    final tasks = List<Task>.from(state.tasks);
    final filter = state.filter;
    switch(filter){
      case TaskFilter.completed:
        return  tasks.where((e)=> e.isDone).toList();
      case TaskFilter.pending:
        return tasks.where((e)=> !e.isDone).toList();
      default:
        return tasks;    
    }

}

}
