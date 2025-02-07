import 'package:flutter/material.dart';
import '../../../../services/teacher_api_service.dart';
import '../../../../models/teacher/class/exams/retrieve_class_exams_response.dart';
import 'create_class_exam_screen.dart';

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
        exams = response.data != null ? List<ExamData>.from(response.data!) : [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Failed to load exams: $e');
    }
  }

  void _showExamOptions(BuildContext context, ExamData exam) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                exam.examName ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.assessment),
              title: Text('Resultados de examen'),
              onTap: () {
                // TODO: Implement exam results functionality
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Editar examen'),
              onTap: () {
                // TODO: Implement edit exam functionality
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Eliminar examen'),
              onTap: () {
                // TODO: Implement delete exam functionality
                Navigator.pop(context);
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
                      return GestureDetector(
                        onTap: () => _showExamOptions(context, exam),
                        child: Card(
                          margin: EdgeInsets.all(10),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exam.examName ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24.0,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text('Fecha: ${exam.examDate ?? ''}'),
                                Text('Hora: ${exam.startTime ?? ''} - ${exam.endTime ?? ''}'),
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
              builder: (context) => CreateClassExamScreen(
                classId: classId,
                className: className,
              ),
            ),
          );
          if (result == true) {
            retrieveClassExams();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}