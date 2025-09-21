import 'package:hive/hive.dart';
import 'package:todo_app/features/todo/data/task_model.dart';

class TodoRepository {
  final Box<Task> box;
  TodoRepository(this.box);

  Future<List<Task>> loadTasks() async => box.values.toList();

  Future<void> saveTasks(List<Task> tasks) async {
    await box.clear();
    await box.addAll(tasks);
  }
}
