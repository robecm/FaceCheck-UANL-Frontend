import 'package:flutter/material.dart';
// TODO Screens
import 'screens/splash_screen.dart';
import 'screens/login_selection.dart';

void main() {
  // Desactiva logs detallados
  debugPrint = (String? message, {int? wrapWidth}) {};

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      // TODO Routes
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginSelectionScreen(),
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
