import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/teacher/class/exams/update_class_exam_request.dart';
import '../../../../services/teacher_api_service.dart';

class UpdateClassExamScreen extends StatefulWidget {
  final int classId;
  final String className;
  final String classHour;
  final String classRoom;
  final int examId;
  final String examName;
  final String examDate;
  final String examHour;
  final String examRoom;

  const UpdateClassExamScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.classHour,
    required this.classRoom,
    required this.examId,
    required this.examName,
    required this.examDate,
    required this.examHour,
    required this.examRoom,
  });

  @override
  _UpdateClassExamScreenState createState() => _UpdateClassExamScreenState();
}

class _UpdateClassExamScreenState extends State<UpdateClassExamScreen> {
  late TextEditingController examNameController;
  late TextEditingController classRoomController;
  late TextEditingController dateController;
  late TextEditingController hourController;
  bool isLoading = false;
  bool useClassHour = true;
  bool useClassRoom = true;
  String? selectedHour;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    examNameController = TextEditingController(text: widget.examName);
    classRoomController = TextEditingController(text: widget.examRoom);
    dateController = TextEditingController(text: widget.examDate);
    hourController = TextEditingController(text: widget.examHour);
  }

  @override
  void dispose() {
    examNameController.dispose();
    classRoomController.dispose();
    dateController.dispose();
    hourController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      // Parse a string like "Thu, 06 Feb 2025 00:00:00 GMT" with a custom format.
      final format = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
      initialDate = format.parse(widget.examDate, true).toLocal();
    } catch (_) {
      // Fallback if the format is different than expected.
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(widget.examHour.split(':')[0]),
        minute: int.parse(widget.examHour.split(':')[1]),
      ),
    );
    if (picked != null) {
      setState(() {
        hourController.text = picked.format(context);
        selectedHour = picked.format(context);
      });
    }
  }

  Future<void> _updateExam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final request = UpdateClassExamRequest(
      examId: widget.examId,
      examName: examNameController.text,
      classId: widget.classId,
      date: dateController.text,
      classRoom: useClassRoom ? widget.classRoom : classRoomController.text,
      hour: useClassHour ? widget.classHour : selectedHour!,
    );

    try {
      final apiService = TeacherApiService();
      final response = await apiService.updateClassExam(request);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Examen actualizado correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar examen: ${response.error}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
        title: Text('Actualizar Examen de ${widget.className}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: examNameController,
                decoration: InputDecoration(labelText: 'Nombre de Examen'),
                validator: (value) => value == null || value.isEmpty ? 'El nombre del examen no puede estar vacío' : null,
              ),
              ListTile(
                title: Text('Mismo salón de clase'),
                leading: Radio<bool>(
                  value: true,
                  groupValue: useClassRoom,
                  onChanged: (value) {
                    setState(() {
                      useClassRoom = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Seleccionar salón'),
                leading: Radio<bool>(
                  value: false,
                  groupValue: useClassRoom,
                  onChanged: (value) {
                    setState(() {
                      useClassRoom = value!;
                    });
                  },
                ),
              ),
              if (!useClassRoom)
                TextFormField(
                  controller: classRoomController,
                  decoration: InputDecoration(labelText: 'Salón'),
                  validator: (value) => value == null || value.isEmpty ? 'El salón no puede estar vacío' : null,
                ),
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'Fecha'),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) => value == null || value.isEmpty ? 'La fecha no puede estar vacía' : null,
              ),
              ListTile(
                title: Text('Hora Clase'),
                leading: Radio<bool>(
                  value: true,
                  groupValue: useClassHour,
                  onChanged: (value) {
                    setState(() {
                      useClassHour = value!;
                      selectedHour = null;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Seleccionar Hora'),
                leading: Radio<bool>(
                  value: false,
                  groupValue: useClassHour,
                  onChanged: (value) {
                    setState(() {
                      useClassHour = value!;
                    });
                  },
                ),
              ),
              if (!useClassHour)
                TextFormField(
                  controller: hourController,
                  decoration: InputDecoration(labelText: 'Hora (HH:mm)'),
                  readOnly: true,
                  onTap: () => _selectTime(context),
                  validator: (value) {
                    if (!useClassHour && (value == null || value.isEmpty)) {
                      return 'La hora no puede estar vacía';
                    }
                    return null;
                  },
                ),
              SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _updateExam,
                child: Text('Actualizar Examen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}