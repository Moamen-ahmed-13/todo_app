import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo_app/features/todo/data/task_model.dart';
import 'package:todo_app/features/todo/logic/cubit/todo_cubit.dart';
import 'package:todo_app/features/todo/logic/todo_repo.dart';
import 'package:todo_app/features/todo/presentation/pages/todo_app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final sl = GetIt.instance;

Future<void> setup() async {
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    final box = await Hive.openBox<Task>('tasksBox');
    sl.registerSingleton<TodoRepository>(TodoRepository(box));
  } catch (e, stackTrace) {
    debugPrint('Hive error: $e, $stackTrace');
    rethrow;
  }
}

Future<void> closeHiveBoxes() async {
  await Hive.close();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();

  final repo = sl<TodoRepository>();
  runApp(
    BlocProvider(
      create: (context) => TodoCubit(repo),
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
  void dispose() {
    closeHiveBoxes();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoApp(
        isDarkMode: _isDarkMode,
        onToggleTheme: toggleTheme,
      ),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF2196F3),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF2196F3),
          secondary: const Color(0xFF64B5F6),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2196F3),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0D47A1),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF0D47A1),
          secondary: const Color(0xFF1976D2),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D47A1),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
