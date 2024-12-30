import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_selection.dart';
import 'student_login_screen.dart';
import 'teacher_login_screen.dart';

void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login_selection': (context) => LoginSelectionScreen(),
        '/student_login': (context) => StudentLoginScreen(),
        '/teacher_login': (context) => TeacherLoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Bienvenido a la pantalla principal')),
    );
  }
}
