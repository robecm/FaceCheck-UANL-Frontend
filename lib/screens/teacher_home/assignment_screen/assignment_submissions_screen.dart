import 'package:flutter/material.dart';
import '../../../services/teacher_api_service.dart';
import '../../../models/assignment/retrieve_assignment_evidences_response.dart';
import 'grade_submission_sheet.dart';

class AssignmentSubmissionsScreen extends StatefulWidget {
  final int assignmentId;
  final String assignmentTitle;

  const AssignmentSubmissionsScreen({
    Key? key,
    required this.assignmentId,
    required this.assignmentTitle,
  }) : super(key: key);

  @override
  _AssignmentSubmissionsScreenState createState() => _AssignmentSubmissionsScreenState();
}

class _AssignmentSubmissionsScreenState extends State<AssignmentSubmissionsScreen> {
  final TeacherApiService _apiService = TeacherApiService();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<AssignmentEvidence> _submissions = [];

  @override
  void initState() {
    super.initState();
    _fetchSubmissions();
  }

  Future<void> _fetchSubmissions() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await _apiService.retrieveAssignmentEvidences(widget.assignmentId.toString());

      if (response.success && response.data != null) {
        setState(() {
          _submissions = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = response.error ?? 'No se pudieron cargar las entregas';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entregas'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error al cargar las entregas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(_errorMessage),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchSubmissions,
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay entregas para esta tarea',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _submissions.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final submission = _submissions[index];
        final bool isGraded = submission.grade != null;

        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                submission.studentName.isNotEmpty
                    ? submission.studentName.substring(0, 1)
                    : '?'
              ),
            ),
            title: Text(submission.studentName),
            subtitle: Text('Entregado: ${submission.submissionDate}'),
            trailing: isGraded
                ? Chip(
                    label: Text('${submission.grade}'),
                    backgroundColor: Colors.green.shade100,
                  )
                : Chip(
                    label: Text('Pendiente'),
                    backgroundColor: Colors.orange.shade100,
                  ),
            onTap: () => _showGradingDialog(submission),
          ),
        );
      },
    );
  }

  void _showGradingDialog(AssignmentEvidence submission) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => GradeSubmissionSheet(
        submission: submission,
        onGradeSubmitted: (evidenceId, grade, feedback) async {
          Navigator.pop(context);
          setState(() => _isLoading = true);

          try {
            final response = await _apiService.gradeAssignmentEvidence(
              evidenceId: evidenceId,
              grade: grade,
              feedback: feedback,
            );

            if (response.success) {
              _fetchSubmissions();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calificación registrada correctamente')),
              );
            } else {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${response.error}')),
              );
            }
          } catch (e) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        },
      ),
    );
  }
}