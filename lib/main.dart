import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_selection.dart';
import 'screens/student_login_screen.dart';
import 'screens/teacher_login_screen.dart';
import 'screens/student_signup.dart';
import 'screens/student_face.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/student_signup',
      routes: {
        '/': (context) => SplashScreen(),
        '/login_selection': (context) => LoginSelectionScreen(),
        '/student_login': (context) => StudentLoginScreen(),
        '/teacher_login': (context) => TeacherLoginScreen(),
        '/student_signup': (context) => StudentSignupScreen(),
        '/home': (context) => HomeScreen(),
        '/student_face': (context) => StudentFaceScreen(
          name: '',
          username: '',
          birthDate: DateTime(2000, 1, 1),
          faculty: '',
          matnum: '',
          email: '',
        ),
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