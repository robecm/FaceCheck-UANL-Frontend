import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../services/teacher_api_service.dart';
import '../../../../models/teacher/class/exams/retrieve_class_exams_response.dart';
import 'create_class_exam_screen.dart';
import 'update_class_exam_screen.dart';
import 'exam_results_screen.dart';

class ClassExamsScreen extends StatefulWidget {
  final int classId;
  final String className;
  final String classHour;
  final String classRoom;

  const ClassExamsScreen({super.key, required this.classId, required this.className, required this.classHour, required this.classRoom});

  @override
  ClassExamsScreenState createState() => ClassExamsScreenState();
}

class ClassExamsScreenState extends State<ClassExamsScreen> {
  late int classId;
  late String className;
  late String classHour;
  late String classRoom;
  bool isLoading = true;
  List<ExamData> exams = [];

  @override
  void initState() {
    super.initState();
    classId = widget.classId;
    className = widget.className;
    classHour = widget.classHour;
    classRoom = widget.classRoom;
    initializeDateFormatting('es_ES', null).then((_) {
      retrieveClassExams();
    });
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

  Future<void> _confirmDeleteExam(BuildContext context, ExamData exam) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar el examen "${exam.examName}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteExam(exam.examId);
    }
  }

  Future<void> _deleteExam(int examId) async {
    try {
      final apiService = TeacherApiService();
      final response = await apiService.deleteClassExam(examId.toString());
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Examen eliminado correctamente')),
        );
        retrieveClassExams();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar examen: ${response.error}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
                exam.examName,
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
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExamResultsScreen(
                      examId: exam.examId,
                      examName: exam.examName,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Editar examen'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateClassExamScreen(
                      classId: classId,
                      className: className,
                      classHour: classHour,
                      classRoom: classRoom,
                      examId: exam.examId,
                      examName: exam.examName,
                      examDate: exam.date,
                      examHour: exam.hour,
                      examRoom: exam.classRoom,
                    ),
                  ),
                );
                if (result == true) {
                  retrieveClassExams();
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Eliminar examen'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteExam(context, exam);
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(date, true).toLocal();
    final DateFormat formatter = DateFormat('EEEE, dd/MM/yyyy', 'es_ES');
    String formattedDate = formatter.format(parsedDate);
    return formattedDate[0].toUpperCase() + formattedDate.substring(1);
  }

  String _formatHour(String hour) {
    final DateTime parsedHour = DateFormat('HH:mm:ss').parse(hour);
    final DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(parsedHour);
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
                                  exam.examName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24.0,
                                    color: Colors.blue,
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: [
                                      TextSpan(
                                        text: 'Fecha: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: _formatDate(exam.date)),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: [
                                      TextSpan(
                                        text: 'Hora: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: _formatHour(exam.hour)),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: [
                                      TextSpan(
                                        text: 'Salón: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: exam.classRoom),
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
              builder: (context) => CreateClassExamScreen(
                classId: classId,
                className: className,
                classHour: classHour,
                classRoom: classRoom,
              ),
            ),
          );
          if (result == true) {
            retrieveClassExams();
          }
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}