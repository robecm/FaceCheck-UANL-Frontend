import 'package:flutter/material.dart';
import '../../../../services/teacher_api_service.dart';
import '../../../../models/teacher/class/exams/retrieve_exam_results_response.dart';

class ExamResultsScreen extends StatefulWidget {
  final int examId;
  final String examName;

  const ExamResultsScreen({super.key, required this.examId, required this.examName});

  @override
  _ExamResultsScreenState createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends State<ExamResultsScreen> {
  bool isLoading = true;
  List<ExamResult> results = [];

  @override
  void initState() {
    super.initState();
    retrieveExamResults();
  }

  Future<void> retrieveExamResults() async {
    try {
      final apiService = TeacherApiService();
      final response = await apiService.retrieveExamResults(widget.examId.toString());
      setState(() {
        results = response.data ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Failed to load exam results: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados de ${widget.examName}'),
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
            : results.isEmpty
                ? Text('No hay resultados para este examen')
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final result = results[index];
                      return Card(
                        margin: EdgeInsets.all(10),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result.studentName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                  Text(result.studentMatnum),
                                ],
                              ),
                              Text(
                                result.score ?? "N/A",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
      ),
    );
  }
}