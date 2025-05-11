import 'package:flutter/material.dart';
import '../../../models/assignment/retrieve_assignment_evidences_response.dart';
import '../../../utils/file_utils.dart';

class GradeSubmissionSheet extends StatefulWidget {
  final AssignmentEvidence submission;
  final Function(String evidenceId, double grade, String? feedback) onGradeSubmitted;

  const GradeSubmissionSheet({
    Key? key,
    required this.submission,
    required this.onGradeSubmitted,
  }) : super(key: key);

  @override
  _GradeSubmissionSheetState createState() => _GradeSubmissionSheetState();
}

class _GradeSubmissionSheetState extends State<GradeSubmissionSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _gradeController;
  late TextEditingController _feedbackController;
  bool _isGraded = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _isGraded = widget.submission.grade != null;
    _gradeController = TextEditingController(
      text: _isGraded ? widget.submission.grade.toString() : '',
    );
    _feedbackController = TextEditingController(
      text: widget.submission.feedback ?? '',
    );
  }

  @override
  void dispose() {
    _gradeController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _downloadAndOpenFile() async {
    if (widget.submission.fileData == null || widget.submission.fileData!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay datos de archivo disponibles')),
      );
      return;
    }

    setState(() => _isDownloading = true);

    final fileName = widget.submission.fileName ?? 'evidence_${widget.submission.evidenceId}.pdf';

    try {
      await FileUtils.saveBase64File(
        context,
        widget.submission.fileData!,
        fileName,
      );
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Calificar Entrega',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(),
              SizedBox(height: 8),
              Text(
                'Estudiante: ${widget.submission.studentName}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Archivo: ${widget.submission.fileName ?? "Sin nombre"}'),
              Text('Fecha de entrega: ${widget.submission.submissionDate}'),
              SizedBox(height: 16),

              // Download evidence button
              if (widget.submission.fileData != null && widget.submission.fileData!.isNotEmpty)
                _isDownloading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: Icon(Icons.download),
                      label: Text('Ver Evidencia'),
                      onPressed: _downloadAndOpenFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),

              SizedBox(height: 16),
              TextFormField(
                controller: _gradeController,
                decoration: InputDecoration(
                  labelText: 'Calificación',
                  border: OutlineInputBorder(),
                  hintText: 'Ingrese un valor entre 0 y 100',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una calificación';
                  }
                  final grade = double.tryParse(value);
                  if (grade == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  if (grade < 0 || grade > 100) {
                    return 'La calificación debe estar entre 0 y 100';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _feedbackController,
                decoration: InputDecoration(
                  labelText: 'Retroalimentación (opcional)',
                  border: OutlineInputBorder(),
                  hintText: 'Ingrese comentarios para el estudiante',
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final grade = double.parse(_gradeController.text);
                      final feedback = _feedbackController.text.isEmpty
                          ? null
                          : _feedbackController.text;

                      widget.onGradeSubmitted(
                        widget.submission.evidenceId,
                        grade,
                        feedback,
                      );
                    }
                  },
                  child: Text(_isGraded ? 'Actualizar Calificación' : 'Enviar Calificación'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}