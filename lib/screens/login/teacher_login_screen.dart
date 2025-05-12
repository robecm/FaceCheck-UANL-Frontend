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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(
                            Icons.person_pin,
                            size: 40,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Docentes',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Número de empleado',
                            prefixIcon: const Icon(Icons.badge),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
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
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
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
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: () => _submit('teacher'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Iniciar sesión',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}