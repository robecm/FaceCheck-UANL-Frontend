import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../services/teacher_api_service.dart';
import '../../../../models/teacher/class/exams/retrieve_exam_results_response.dart';
import '../../../../models/teacher/class/exams/modify_exam_results_request.dart';

class ExamResultsScreen extends StatefulWidget {
  final int examId;
  final String examName;
  final int classId;

  const ExamResultsScreen({
    super.key,
    required this.examId,
    required this.examName,
    required this.classId,
  });

  @override
  _ExamResultsScreenState createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends State<ExamResultsScreen> {
  bool isLoading = true;
  bool isEditing = false;
  List<ExamResult> results = [];
  List<TextEditingController> controllers = [];

  @override
  void initState() {
    super.initState();
    retrieveExamResults();
  }

  Future<void> retrieveExamResults() async {
    setState(() {
      isLoading = true;
    });

    try {
      final apiService = TeacherApiService();
      final response = await apiService.retrieveExamResults(widget.examId.toString());
      print('API Response: ${json.encode(response)}');

      if (response.data != null) {
        setState(() {
          results = response.data!;
          controllers = results.map((result) =>
            TextEditingController(text: result.score)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          results = [];
          controllers = [];
          isLoading = false;
        });
        print('No data received from API');
      }
    } catch (e, stackTrace) {
      print('Error loading exam results: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        isLoading = false;
      });
    }
  }

  void modifyResults() async {
    if (isEditing) {
      bool hasChanges = false;
      List<ExamResultModification> modifiedResults = [];

      for (var i = 0; i < results.length; i++) {
        String originalScore = results[i].score ?? '';
        String newScore = controllers[i].text;

        if (newScore != originalScore) {
          hasChanges = true;
          modifiedResults.add(ExamResultModification(
            resultId: results[i].resultId,
            score: newScore.isNotEmpty ? double.parse(newScore) : null,
            studentId: results[i].studentId,
            examId: widget.examId,
            classId: widget.classId,  // Use the classId from widget
          ));
        }
      }

      if (hasChanges) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text('Confirmar cambios'),
              content: Text('¿Desea confirmar los cambios realizados?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    // First close the dialog
                    Navigator.of(dialogContext).pop();

                    // Set loading state
                    if (!mounted) return;
                    setState(() {
                      isLoading = true;
                      isEditing = false;
                    });

                    try {
                      final apiService = TeacherApiService();
                      final request = ModifyExamResultsRequest(results: modifiedResults);
                      print('Sending modify results request: ${json.encode(request.toJson())}');
                      final response = await apiService.modifyExamResults(request);

                      if (!mounted) return;

                      if (response.success) {
                        // Refresh data first
                        await retrieveExamResults();

                        // Show success message
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response.message ?? 'Cambios guardados correctamente'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        if (!mounted) return;
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al guardar cambios: ${response.error ?? 'Error desconocido'}'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      setState(() {
                        isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: Text('Confirmar cambios'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    setState(() {
                      for (var i = 0; i < results.length; i++) {
                        controllers[i].text = results[i].score ?? '';
                      }
                      isEditing = false;
                    });
                  },
                  child: Text('Eliminar cambios'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Cancelar'),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          isEditing = false;
        });
      }
    } else {
      setState(() {
        isEditing = true;
      });
    }
  }

  String formatScore(String? score) {
    if (score == null) return "N/A";
    if (score.endsWith(".00")) {
      return score.substring(0, score.length - 3);
    }
    return score;
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
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
                      final controller = controllers[index];
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
                              isEditing
                                  ? SizedBox(
                                      width: 100,
                                      height: 48,
                                      child: TextFormField(
                                        controller: controller,
                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                        textAlign: TextAlign.center,
                                        inputFormatters: [
                                          DecimalTextInputFormatter(decimalRange: 2),
                                          FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,2}')),
                                        ],
                                        decoration: InputDecoration(
                                          hintText: '---',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Text(
                                        formatScore(result.score),
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: modifyResults,
        backgroundColor: Colors.blue,
        child: Icon(isEditing ? Icons.check : Icons.edit),
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange >= 0);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text == '') {
      return newValue;
    }

    final double? value = double.tryParse(newValue.text);
    if (value == null || value < 0 || value > 100) {
      return oldValue;
    }

    final parts = newValue.text.split('.');
    if (parts[0].length > 3 || (parts.length > 1 && parts[1].length > decimalRange)) {
      return oldValue;
    }

    return newValue;
  }
}