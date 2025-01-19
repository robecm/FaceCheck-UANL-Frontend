import 'package:flutter/material.dart';
import 'screens/animation/splash_screen.dart';
import 'screens/login/login_selection.dart';
import 'screens/login/student_login_screen.dart';
import 'screens/login/teacher_login_screen.dart';
import 'screens/signup/student_signup_screen.dart';
import 'screens/signup/student_signup_face.dart';
import 'screens/student_home/student_home_screen.dart';

void main() {
  debugPrint = (String? message, {int? wrapWidth}) {};
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/student_home',
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
          password: '',
        ),
        '/student_home': (context) => StudentHomeScreen(),
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