import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/features/todo/data/task_model.dart';

part 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  TodoCubit() : super(const TodoState()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final box = await Hive.openBox<Task>('tasksBox');
    } catch (e) {}
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.tasks.map((e) => e.toJson()).toList());
    await prefs.setString('tasks', encoded);
  }

  void addTask(String title) {
    if (title.trim().isEmpty) return;
    final newTask = Task(title: title.trim());
    final updatedTasks = [newTask, ...state.tasks];
    emit(state.copyWith(tasks: updatedTasks));
    saveTasks();
  }

  void editTask(int index, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    final updatedTasks = List<Task>.from(state.tasks);
    updatedTasks[index] = updatedTasks[index].copyWith(title: newTitle.trim());
    emit(state.copyWith(tasks: updatedTasks));
    saveTasks();
  }

  void deleteTask(int index) {
    final updatedTasks = List<Task>.from(state.tasks);
    updatedTasks.removeAt(index);
    emit(state.copyWith(tasks: updatedTasks));
    saveTasks();
  }

  void toggleDone(int index, bool isDone) {
    final updatedTasks = List<Task>.from(state.tasks);
    updatedTasks[index] = updatedTasks[index].copyWith(isDone: isDone);
    emit(state.copyWith(tasks: updatedTasks));
    saveTasks();
  }

  void updateDate(int index, DateTime? date) {
    final updatedTasks = List<Task>.from(state.tasks);
    updatedTasks[index] = updatedTasks[index].copyWith(date: date);
    emit(state.copyWith(tasks: updatedTasks));
    saveTasks();
  }

  void changeFilter(TaskFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  List<Task> get filteredTasks {
    switch (state.filter) {
      case 'Pending':
        return state.tasks.where((task) => !task.isDone).toList();
      case 'Completed':
        return state.tasks.where((task) => task.isDone).toList();
      case 'All':
      default:
        return state.tasks;
    }
  }
}
