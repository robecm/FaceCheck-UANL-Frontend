import 'package:flutter/material.dart';
import '../../services/student_api_service.dart';
import '../../models/student_response/retrieve_student_exams_response.dart';

class StudentExamsScreen extends StatefulWidget {
  final int studentId;

  const StudentExamsScreen({super.key, required this.studentId});

  @override
  StudentExamsScreenState createState() => StudentExamsScreenState();
}

class StudentExamsScreenState extends State<StudentExamsScreen> {
  late int studentId;
  bool isLoading = true;
  List<ExamData> exams = [];

  @override
  void initState() {
    super.initState();
    studentId = widget.studentId;
    fetchStudentExams();
  }

  Future<void> fetchStudentExams() async {
    final studentApiService = StudentApiService();
    try {
      final response = await studentApiService.retrieveStudentExams(studentId);
      print('Response: $response'); // Print the response to the console
      setState(() {
        exams = response.map((data) => ExamData.fromJson(data)).toList();
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
        title: Text('Exámenes'),
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
            : exams.isEmpty
                ? Text('No tienes exámenes asignados actualmente')
                : ListView.builder(
                    itemCount: exams.length,
                    itemBuilder: (context, index) {
                      final examInfo = exams[index];
                      return Card(
                        margin: EdgeInsets.all(10),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${examInfo.className} - ${examInfo.examName}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.0,
                                  color: Colors.blue,
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Fecha: ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: examInfo.date),
                                  ],
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Hora: ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: examInfo.hour),
                                  ],
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Salón: ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: examInfo.classRoom),
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
                                    TextSpan(text: examInfo.teacherName),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  examInfo.score != null ? 'Calificación: ${examInfo.score.toString()}' : 'No calificado',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0, // Increase the font size
                                    color: Colors.deepPurple, // Set the color to deep purple
                                  ),
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