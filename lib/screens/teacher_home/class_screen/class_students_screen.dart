import 'package:flutter/material.dart';
import '../../../services/teacher_api_service.dart';
import '../../../models/teacher/class/retrieve_class_students_response.dart';
import '../../../models/teacher/class/class_add_student_request.dart';
import '../../../models/teacher/class/class_delete_student_request.dart';

class ClassStudentsScreen extends StatefulWidget {
  final int classId;
  final String className;

  const ClassStudentsScreen({super.key, required this.classId, required this.className});

  @override
  _ClassStudentsScreenState createState() => _ClassStudentsScreenState();
}

class _ClassStudentsScreenState extends State<ClassStudentsScreen> {
  bool isLoading = true;
  List<StudentData> students = [];

  @override
  void initState() {
    super.initState();
    retrieveClassStudents();
  }

  Future<void> retrieveClassStudents() async {
    try {
      final apiService = TeacherApiService();
      final response = await apiService.retrieveClassStudents(widget.classId.toString());
      setState(() {
        students = response.data ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Failed to load students: $e');
    }
  }

  Future<void> addStudentToClass(int studentId) async {
    try {
      print('Adding student with ID: $studentId to class with ID: ${widget.classId}');
      final apiService = TeacherApiService();
      final request = ClassAddStudentRequest(matnum: studentId, classId: widget.classId);
      final response = await apiService.addStudentToClass(request);
      if (response.success) {
        retrieveClassStudents();
        Navigator.of(context).pop();
      } else if (response.error == 'Student not found.') {
        _showErrorDialog('Student not found.');
      } else {
        _showErrorDialog('Failed to add student: ${response.error}');
      }
    } catch (e) {
      _showErrorDialog('Failed to add student: $e');
    }
  }

  Future<void> deleteStudentFromClass(int studentId) async {
    try {
      final apiService = TeacherApiService();
      final request = ClassDeleteStudentRequest(classId: widget.classId.toString(), studentId: studentId.toString());
      final response = await apiService.deleteStudentFromClass(request);
      if (response.success) {
        retrieveClassStudents();
        Navigator.of(context).pop();
      } else {
        _showErrorDialog('Failed to delete student: ${response.error}');
      }
    } catch (e) {
      _showErrorDialog('Failed to delete student: $e');
    }
  }

  void _showAddStudentDialog() {
    final TextEditingController matriculaController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Agregar estudiante a ${widget.className}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: matriculaController,
                    decoration: InputDecoration(
                      hintText: 'Ingrese número de matrícula',
                      errorText: errorMessage,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Agregar'),
                  onPressed: () async {
                    final String matriculaText = matriculaController.text;
                    if (matriculaText.length != 7 || int.tryParse(matriculaText) == null) {
                      setState(() {
                        errorMessage = 'Inserte una matrícula de 7 dígitos válida.';
                      });
                      return;
                    }
                    final int studentId = int.parse(matriculaText);
                    await addStudentToClass(studentId);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteStudentDialog(int studentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar estudiante'),
          content: Text('¿Está seguro de que desea eliminar a este estudiante de la clase?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () async {
                await deleteStudentFromClass(studentId);
              },
            ),
          ],
        );
      },
    );
  }

  void _showStudentOptions(int studentId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Eliminar estudiante de clase'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteStudentDialog(studentId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estudiantes de ${widget.className}'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : students.isEmpty
                ? Text('No hay estudiantes asignados a esta clase')
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return GestureDetector(
                        onTap: () => _showStudentOptions(student.id),
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text('Matrícula: ${student.matnum}', style: TextStyle(fontSize: 14.0)),
                                Text('Correo: ${student.email}', style: TextStyle(fontSize: 14.0)),
                                Text('Facultad: ${student.faculty}', style: TextStyle(fontSize: 14.0)),
                                Text('Usuario: ${student.username}', style: TextStyle(fontSize: 14.0)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}