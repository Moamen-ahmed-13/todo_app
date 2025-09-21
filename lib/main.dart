import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo_app/features/todo/data/task_model.dart';
import 'package:todo_app/features/todo/logic/cubit/todo_cubit.dart';
import 'package:todo_app/features/todo/logic/todo_repo.dart';
import 'package:todo_app/features/todo/presentation/pages/todo_app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final sl = GetIt.instance;

void setup() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  final box = await Hive.openBox<Task>('tasksBox');
  sl.registerSingleton<TodoRepository>(TodoRepository(box));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final box = await Hive.openBox<Task>('tasksBox');
  runApp(
    BlocProvider(
      create: (context) => TodoCubit(
        TodoRepository(box),
      ),
      child: const TheRoot(),
    ),
  );
}

class TheRoot extends StatefulWidget {
  const TheRoot({super.key});

  @override
  State<TheRoot> createState() => _TheRootState();
}

class _TheRootState extends State<TheRoot> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoApp(
        isDarkMode: _isDarkMode,
        onToggleTheme: toggleTheme,
      ),
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
    );
  }
}
