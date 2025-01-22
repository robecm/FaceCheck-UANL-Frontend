import 'package:flutter/material.dart';
import '../../services/student_api_service.dart';
import '../../models/student/retrieve_student_classes_response.dart';

class StudentClassesScreen extends StatefulWidget {
  final int studentId;

  const StudentClassesScreen({super.key, required this.studentId});

  @override
  StudentClassesScreenState createState() => StudentClassesScreenState();
}

class StudentClassesScreenState extends State<StudentClassesScreen> {
  late int studentId;
  bool isLoading = true;
  List<ClassData> classes = [];

  @override
  void initState() {
    super.initState();
    studentId = widget.studentId;
    fetchStudentClasses();
  }

  Future<void> fetchStudentClasses() async {
    final studentApiService = StudentApiService();
    try {
      final response = await studentApiService.retrieveStudentClasses(studentId);
      setState(() {
        classes = response.map((data) => ClassData.fromJson(data)).toList();
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
        title: Text('Clases'),
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
            : classes.isEmpty
                ? Text('No estás inscrito en ninguna clase actualmente')
                : ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final classInfo = classes[index];
                      return Card(
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
                                      text: 'Profesor: ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: classInfo.teacherName),
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
                      );
                    },
                  ),
      ),
    );
  }
}