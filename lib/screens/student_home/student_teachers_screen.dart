import 'package:flutter/material.dart';
import '../../services/student_api_service.dart';
import '../../models/student/retrieve_student_teachers_response.dart';

class StudentTeachersScreen extends StatefulWidget {
  final int studentId;

  const StudentTeachersScreen({super.key, required this.studentId});

  @override
  StudentTeachersScreenState createState() => StudentTeachersScreenState();
}

class StudentTeachersScreenState extends State<StudentTeachersScreen> {
  late int studentId;
  bool isLoading = true;
  List<TeacherData> teachers = [];

  @override
  void initState() {
    super.initState();
    studentId = widget.studentId;
    fetchStudentTeachers();
  }

  Future<void> fetchStudentTeachers() async {
    final studentApiService = StudentApiService();
    try {
      final response = await studentApiService.retrieveStudentTeachers(studentId);
      setState(() {
        teachers = response.map((data) => TeacherData.fromJson(data)).toList();
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profesores'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/student_home');
          },
        ),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : teachers.isEmpty
                ? Text('No tienes profesores asignados actualmente')
                : ListView.builder(
                    itemCount: teachers.length,
                    itemBuilder: (context, index) {
                      final teacherInfo = teachers[index];
                      return Card(
                        margin: EdgeInsets.all(10),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                teacherInfo.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.blue,
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Email: ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: teacherInfo.email,
                                    ),
                                  ],
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Clases: ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: teacherInfo.classNames.join(', '),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}