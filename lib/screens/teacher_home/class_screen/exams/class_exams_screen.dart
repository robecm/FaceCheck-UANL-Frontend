// lib/screens/teacher_home/class_screen/class_exams_screen.dart
import 'package:flutter/material.dart';
import '../../../../services/teacher_api_service.dart';
import '../../../../models/teacher/class/retrieve_class_exams_response.dart';

class ClassExamsScreen extends StatefulWidget {
  final int classId;
  final String className;

  const ClassExamsScreen({super.key, required this.classId, required this.className});

  @override
  ClassExamsScreenState createState() => ClassExamsScreenState();
}

class ClassExamsScreenState extends State<ClassExamsScreen> {
  late int classId;
  late String className;
  bool isLoading = true;
  List<ExamData> exams = [];

  @override
  void initState() {
    super.initState();
    classId = widget.classId;
    className = widget.className;
    retrieveClassExams();
  }

  Future<void> retrieveClassExams() async {
    try {
      final apiService = TeacherApiService();
      final response = await apiService.retrieveClassExams(classId);
      setState(() {
        exams = response.map((data) => ExamData.fromJson(data)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Failed to load exams: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exámenes de $className'),
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
            : exams.isEmpty
                ? Text('No hay exámenes asignados a esta clase')
                : ListView.builder(
                    itemCount: exams.length,
                    itemBuilder: (context, index) {
                      final exam = exams[index];
                      return Card(
                        margin: EdgeInsets.all(10),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exam.examName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.0,
                                  color: Colors.blue,
                                ),
                              ),
                              Text('Fecha: ${exam.examDate}'),
                              Text('Hora: ${exam.startTime} - ${exam.endTime}'),
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