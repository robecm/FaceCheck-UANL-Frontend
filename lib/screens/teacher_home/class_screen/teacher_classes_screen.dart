import 'package:flutter/material.dart';
import '../../../services/teacher_api_service.dart';
import '../../../models/teacher/retrieve_teacher_classes_response.dart';
import 'modify_class_screen.dart';
import 'create_class_screen.dart';
import 'exams/class_exams_screen.dart'; // Import the ClassExamsScreen

class TeacherClassesScreen extends StatefulWidget {
  final int teacherId;

  const TeacherClassesScreen({super.key, required this.teacherId});

  @override
  TeacherClassesScreenState createState() => TeacherClassesScreenState();
}

class TeacherClassesScreenState extends State<TeacherClassesScreen> {
  late int teacherId;
  bool isLoading = true;
  List<ClassData> classes = [];

  @override
  void initState() {
    super.initState();
    teacherId = widget.teacherId;
    retrieveTeacherClasses();
  }

  Future<void> retrieveTeacherClasses() async {
    try {
      final apiService = TeacherApiService();
      final response = await apiService.retrieveTeacherClasses(teacherId);
      setState(() {
        classes = response.map((data) => ClassData.fromJson(data)).toList();
        classes.sort((a, b) => a.className.compareTo(b.className)); // Sort classes by name
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Failed to load classes: $e');
    }
  }

  void _showClassOptions(BuildContext context, ClassData classInfo) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), // Reduced bottom padding
              child: Text(
                classInfo.className,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Ver estudiantes'),
              onTap: () {
                // TODO Handle 'Ver estudiantes' action
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Ver exámenes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassExamsScreen(
                      classId: classInfo.classId,
                      className: classInfo.className,
                      classHour: classInfo.startTime, // Pass classHour
                      classRoom: classInfo.classRoom, // Pass classRoom
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Modificar Clase'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModifyClassScreen(classData: classInfo),
                  ),
                );
                if (result == true) {
                  retrieveTeacherClasses(); // Refresh the data
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Eliminar Clase'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteClass(context, classInfo.classId.toString(), classInfo.className);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteClass(BuildContext context, String classId, String className) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar la clase "$className"?'),
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
                Navigator.of(context).pop();
                await _deleteClass(classId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteClass(String classId) async {
    try {
      final apiService = TeacherApiService();
      final response = await apiService.deleteClass(classId);
      if (response.success) {
        retrieveTeacherClasses(); // Refresh the data
      } else {
        // Handle error
        print('Failed to delete class: ${response.error}');
      }
    } catch (e) {
      // Handle error
      print('Failed to delete class: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clases'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/teacher_home');
          },
        ),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : classes.isEmpty
                ? Text('No tienes clases asignadas actualmente')
                : ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final classInfo = classes[index];
                      return GestureDetector(
                        onTap: () => _showClassOptions(context, classInfo),
                        child: Card(
                          margin: EdgeInsets.all(10),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  classInfo.className,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28.0,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Salón: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: classInfo.classRoom),
                                    ],
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Grupo: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: classInfo.groupNum),
                                    ],
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: classInfo.startTime == classInfo.endTime
                                        ? '${classInfo.weekDays} ${classInfo.startTime}'
                                        : '${classInfo.weekDays} ${classInfo.startTime} - ${classInfo.endTime}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Semestre: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: '${classInfo.semester}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateClassScreen(teacherId: teacherId),
            ),
          );
          if (result == true) {
            retrieveTeacherClasses(); // Refresh the data
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}