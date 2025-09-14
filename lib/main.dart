import 'package:flutter/material.dart';
import 'package:todo_app/features/todo/logic/todo_cubit.dart';
import 'package:todo_app/features/todo/presentation/pages/todo_app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
      BlocProvider(create: (context) => TodoCubit(), child: const TheRoot()));
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
