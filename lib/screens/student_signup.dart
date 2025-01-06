import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/duplicate_response.dart';
import 'student_face.dart';

class StudentSignupScreen extends StatefulWidget {
  const StudentSignupScreen({super.key});

  @override
  StudentSignupScreenState createState() => StudentSignupScreenState();
}

class StudentSignupScreenState extends State<StudentSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _name = '';
  String _username = '';
  DateTime? _birthDate;
  String _faculty = '';
  String _matnum = '';
  String _password = '';
  String _confirmPassword = '';
  final String _faceImg = '';
  String _email = '';

  final List<String> _faculties = [
    'FIME',
    'FACPYA',
    'FOD',
    'FACDyC',
    'FARQ',
    'FIC',
    'FCB',
  ];

  void _submit() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoading = true;
      });

      try {
        // Check for duplicates
        DuplicateResponse duplicateResponse = await apiService.checkDuplicate(_email, _matnum, _username);

        setState(() {
          isLoading = false;
        });

        if (duplicateResponse.success) {
          // No duplicates found, navigate to the next screen with data
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StudentFaceScreen(
                name: _name,
                username: _username,
                birthDate: _birthDate!,
                faculty: _faculty,
                matnum: _matnum,
                email: _email,
                password: _password, // Pass the password field
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SizedBox(
                height: 40.0,
                child: Center(
                  child: Text(
                    duplicateResponse.duplicateField == 'email'
                        ? 'This email is already registered'
                        : duplicateResponse.duplicateField == 'username'
                            ? 'This username is already registered'
                            : duplicateResponse.duplicateField == 'matnum'
                                ? 'This matriculation number is already registered'
                                : duplicateResponse.duplicateField != null
                                    ? 'The ${duplicateResponse.duplicateField} is already registered'
                                    : '${duplicateResponse.error ?? ''}\nDuplicate field: ${duplicateResponse.duplicateField ?? ''}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error connecting to the server: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Registro de Estudiante'),
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
                    'Registro de Estudiante',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 40),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduce tu nombre';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value!;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nombre de usuario'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduce tu nombre de usuario';
                      }
                      if (value.length < 4 || value.length > 25) {
                        return 'El nombre de usuario debe tener entre 4 y 25 caracteres';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _username = value!;
                    },
                  ),
                  SizedBox(height: 20),
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
                    decoration: InputDecoration(labelText: 'Correo electrónico'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduce tu correo electrónico';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value!;
                    },
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Facultad'),
                    items: _faculties.map((String faculty) {
                      return DropdownMenuItem<String>(
                        value: faculty,
                        child: Text(faculty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _faculty = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona tu facultad';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Fecha de nacimiento',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _birthDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: _birthDate == null ? '' : _birthDate!.toLocal().toString().split(' ')[0],
                    ),
                    validator: (value) {
                      if (_birthDate == null) {
                        return 'Selecciona tu fecha de nacimiento';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduce tu contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Confirmar Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirma tu contraseña';
                      }
                      if (value != _password) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _confirmPassword = value;
                      });
                    },
                  ),
                  SizedBox(height: 40),
                  isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _submit,
                    child: Text('Registrarse'),
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