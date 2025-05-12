import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../services/teacher_api_service.dart';
import '../../../models/teacher/retrieve_teacher_exams_response.dart';
import '../class_screen/exams/exam_results_screen.dart';
import '../class_screen/exams/update_class_exam_screen.dart';
import '../class_screen/exams/create_class_exam_screen.dart';

class TeacherExamsScreen extends StatefulWidget {
  final int teacherId;

  const TeacherExamsScreen({super.key, required this.teacherId});

  @override
  TeacherExamsScreenState createState() => TeacherExamsScreenState();
}

class TeacherExamsScreenState extends State<TeacherExamsScreen> {
  late int teacherId;
  bool isLoading = true;
  List<TeacherExamData> exams = [];

  @override
  void initState() {
    super.initState();
    teacherId = widget.teacherId;
    initializeDateFormatting('es_ES', null).then((_) {
      fetchTeacherExams();
    });
  }

  Future<void> fetchTeacherExams() async {
    try {
      final apiService = TeacherApiService();
      final response = await apiService.retrieveTeacherExams(teacherId);
      setState(() {
        exams = response.data != null ? response.data! : [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        exams = [
          TeacherExamData(
            examId: 1,
            classId: 101,
            className: 'Matemáticas Avanzadas',
            examName: 'Parcial 1',
            date: 'Wed, 15 Nov 2023 10:00:00',
            hour: '10:00:00',
            classRoom: 'A-101',
            studentsCount: 25,
            gradedCount: 20,
          ),
          TeacherExamData(
            examId: 2,
            classId: 102,
            className: 'Física Cuántica',
            examName: 'Examen Final',
            date: 'Sun, 10 Dec 2023 12:00:00',
            hour: '12:00:00',
            classRoom: 'B-203',
            studentsCount: 18,
            gradedCount: 0,
          ),
        ];
      });
      print('Failed to load exams: $e');
    }
  }

  Future<void> _confirmDeleteExam(BuildContext context, TeacherExamData exam) async {
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
        fetchTeacherExams();
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

  void _showExamOptions(BuildContext context, TeacherExamData exam) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    exam.examName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    exam.className,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
                      classId: exam.classId,
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
                      classId: exam.classId,
                      className: exam.className,
                      examId: exam.examId,
                      examName: exam.examName,
                      examDate: exam.date,
                      examHour: exam.hour,
                      examRoom: exam.classRoom,
                      classHour: '', // We may not have this info at this level
                      classRoom: '', // We may not have this info at this level
                    ),
                  ),
                );
                if (result == true) {
                  fetchTeacherExams();
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
        title: const Text('Exámenes'),
        centerTitle: true,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : exams.isEmpty
                ? const Text('No tienes exámenes programados actualmente')
                : ListView.builder(
                    itemCount: exams.length,
                    itemBuilder: (context, index) {
                      final exam = exams[index];
                      return GestureDetector(
                        onTap: () => _showExamOptions(context, exam),
                        child: Card(
                          margin: const EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exam.examName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24.0,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  exam.className,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Fecha: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: _formatDate(exam.date)),
                                    ],
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Hora: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: _formatHour(exam.hour)),
                                    ],
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
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
      )
    );
  }
}
