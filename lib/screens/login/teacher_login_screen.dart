import 'package:flutter/material.dart';
import '../../services/user_api_service.dart';
import '../../models/login/login_response.dart';
import 'teacher_login_face.dart';

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  TeacherLoginScreenState createState() => TeacherLoginScreenState();
}

class TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  bool isLoading = false;

  String _worknum = '';
  String _password = '';

  void _submit(String loginType) async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoading = true;
      });

      try {
        LoginResponse response;
        if (loginType == 'teacher') {
          response = await apiService.teacherLogin(_worknum, _password);
        } else {
          response = await apiService.studentLogin(_worknum, _password);
        }

        setState(() {
          isLoading = false;
        });

        if (response.success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherLoginFaceScreen(
                faceCode: response.faceImg ?? '',
                teacherId: response.teacherId ?? 0),
            ),
          );
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
        leading: const BackButton(),
        title: const Text('Iniciar sesión'),
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
                  const Text(
                    'Docentes',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                 const SizedBox(height: 40),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Número de empleado'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduce tu número de empleado';
                      }
                      if (value.length != 6 || int.tryParse(value) == null) {
                        return 'Introduce un número de empleado válido de 6 dígitos';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _worknum = value!;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Contraseña'),
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
                  const SizedBox(height: 40),
                  isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () => _submit('teacher'),
                          child: const Text('Iniciar sesión'),
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