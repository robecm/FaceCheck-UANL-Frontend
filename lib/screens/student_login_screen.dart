// lib/screens/student_login_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/login_response.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  StudentLoginScreenState createState() => StudentLoginScreenState();
}

class StudentLoginScreenState extends State<StudentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  bool isLoading = false;

  String _matnum = '';
  String _password = '';

  void _submit(String loginType) async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoading = true;
      });

      try {
        LoginResponse response;
        if (loginType == 'student') {
          response = await apiService.studentLogin(_matnum, _password);
        } else {
          response = await apiService.teacherLogin(_matnum, _password);
        }

        setState(() {
          isLoading = false;
        });

        if (response.success) {
          Navigator.pushReplacementNamed(context, '/home');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? 'Inicio de sesión exitoso')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.error ?? 'Credenciales incorrectas')),
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar con el servidor: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Iniciar sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Estudiantes',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 40),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Matrícula'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduce tu matrícula';
                      }
                      if (value.length != 7 || int.tryParse(value) == null) {
                        return 'Introduce una matrícula válida de 7 dígitos';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _matnum = value!;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduce tu contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value!;
                    },
                  ),
                  SizedBox(height: 40),
                  isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () => _submit('student'),
                          child: Text('Iniciar sesión'),
                        ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/student_signup');
                    },
                    child: Text('¿No tienes cuenta? Regístrate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}