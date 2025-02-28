import 'package:flutter/material.dart';

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
    fetchTeacherExams();
  }

  Future<void> fetchTeacherExams() async {
    // TODO: Replace with actual API call when ready
    // Simulating API call with dummy data
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      exams = [
        TeacherExamData(
          examId: 1,
          className: 'Matemáticas Avanzadas',
          examName: 'Parcial 1',
          date: '2023-11-15',
          hour: '10:00 AM',
          classRoom: 'A-101',
          studentsCount: 25,
          gradedCount: 20,
        ),
        TeacherExamData(
          examId: 2,
          className: 'Física Cuántica',
          examName: 'Examen Final',
          date: '2023-12-10',
          hour: '12:00 PM',
          classRoom: 'B-203',
          studentsCount: 18,
          gradedCount: 0,
        ),
      ];
      isLoading = false;
    });
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
                      final examInfo = exams[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${examInfo.className} - ${examInfo.examName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.0,
                                  color: Colors.blue,
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
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
                                    const TextSpan(
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
                                    const TextSpan(
                                      text: 'Salón: ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: examInfo.classRoom),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Estudiantes: ${examInfo.studentsCount}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Calificados: ${examInfo.gradedCount}/${examInfo.studentsCount}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: examInfo.gradedCount == 0
                                          ? Colors.red
                                          : examInfo.gradedCount == examInfo.studentsCount
                                              ? Colors.green
                                              : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: Navigate to exam details/grading screen
                                    },
                                    child: const Text('Gestionar'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create new exam screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TeacherExamData {
  final int examId;
  final String className;
  final String examName;
  final String date;
  final String hour;
  final String classRoom;
  final int studentsCount;
  final int gradedCount;

  TeacherExamData({
    required this.examId,
    required this.className,
    required this.examName,
    required this.date,
    required this.hour,
    required this.classRoom,
    required this.studentsCount,
    required this.gradedCount,
  });
}