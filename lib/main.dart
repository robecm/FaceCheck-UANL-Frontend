import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/animation/splash_screen.dart';
import 'screens/login/login_selection.dart';
import 'screens/login/student_login_screen.dart';
import 'screens/login/teacher_login_screen.dart';
import 'screens/signup/student_signup_screen.dart';
import 'screens/signup/student_signup_face.dart';
import 'screens/student_home/student_home_screen.dart';
import 'screens/teacher_home/teacher_home_screen.dart';
import 'models/session/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // final sessionManager = SessionManager();
  // sessionManager.teacherId = 124;

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
        '/student_signup': (context) => StudentSignupScreen(),
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
        '/teacher_home': (context) => TeacherHomeScreen(),
      },
    );
  }
}

