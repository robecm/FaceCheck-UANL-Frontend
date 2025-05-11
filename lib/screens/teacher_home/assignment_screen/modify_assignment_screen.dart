import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/teacher/retrieve_teacher_assignments_response.dart';

class ModifyAssignmentScreen extends StatefulWidget {
  final TeacherAssignmentData assignment;

  const ModifyAssignmentScreen({super.key, required this.assignment});

  @override
  _ModifyAssignmentScreenState createState() => _ModifyAssignmentScreenState();
}

// TODO Implement API call

class _ModifyAssignmentScreenState extends State<ModifyAssignmentScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime selectedDueDate;
  late TimeOfDay selectedDueTime;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.assignment.title);
    descriptionController = TextEditingController(text: widget.assignment.description);

    // Parse the due date
    try {
      final formats = [
        'yyyy-MM-dd',
        'EEE, dd MMM yyyy HH:mm:ss',
        'yyyy-MM-ddTHH:mm:ss',
        'yyyy-MM-dd HH:mm:ss'
      ];

      DateTime? parsedDate;
      for (var format in formats) {
        try {
          parsedDate = DateFormat(format).parse(widget.assignment.dueDate);
          break;
        } catch (_) {
          // Try next format
        }
      }

      parsedDate ??= DateTime.tryParse(widget.assignment.dueDate) ?? DateTime.now().add(Duration(days: 7));

      selectedDueDate = parsedDate;
      selectedDueTime = TimeOfDay(hour: parsedDate.hour, minute: parsedDate.minute);
    } catch (e) {
      // Default fallback
      selectedDueDate = DateTime.now().add(Duration(days: 7));
      selectedDueTime = TimeOfDay(hour: 23, minute: 59);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null && picked != selectedDueDate) {
      setState(() {
        selectedDueDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedDueTime.hour,
          selectedDueTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedDueTime,
    );

    if (picked != null && picked != selectedDueTime) {
      setState(() {
        selectedDueTime = picked;
        selectedDueDate = DateTime(
          selectedDueDate.year,
          selectedDueDate.month,
          selectedDueDate.day,
          selectedDueTime.hour,
          selectedDueTime.minute,
        );
      });
    }
  }

  String get formattedDueDate {
    return "${DateFormat('yyyy-MM-dd').format(selectedDueDate)} a las ${selectedDueTime.format(context)}";
  }

  Future<void> _modifyAssignment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));

      // For now, just return success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarea actualizada correctamente')),
      );
      Navigator.pop(context, true); // Pass true to indicate success
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
        title: Text('Modificar Tarea'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Assignment title field
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Título de la Tarea',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título no puede estar vacío';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Assignment description field
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripción no puede estar vacía';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Due date field
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha de Entrega',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        formattedDueDate,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: Icon(Icons.calendar_today),
                            label: Text('Cambiar Fecha'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _selectTime(context),
                            icon: Icon(Icons.access_time),
                            label: Text('Cambiar Hora'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Read-only class info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información de la Clase',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildInfoRow('Clase:', widget.assignment.className),
                      _buildInfoRow('ID de Clase:', widget.assignment.classId.toString()),
                      _buildInfoRow('Entregas:', '${widget.assignment.submissionCount} de ${widget.assignment.totalStudents}'),
                      _buildInfoRow('Calificados:', '${widget.assignment.gradedCount} de ${widget.assignment.submissionCount}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Save button
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _modifyAssignment,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'GUARDAR CAMBIOS',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}