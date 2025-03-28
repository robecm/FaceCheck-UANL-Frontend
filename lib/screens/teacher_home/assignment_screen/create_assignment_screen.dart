import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateAssignmentScreen extends StatefulWidget {
  final int teacherId;

  const CreateAssignmentScreen({super.key, required this.teacherId});

  @override
  _CreateAssignmentScreenState createState() => _CreateAssignmentScreenState();
}

 // TODO Implement API call

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime selectedDueDate;
  late TimeOfDay selectedDueTime;
  bool isLoading = false;

  // For class selection
  int? selectedClassId;
  String selectedClassName = '';
  List<Map<String, dynamic>> teacherClasses = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();

    // Default due date: 1 week from now, at 23:59
    selectedDueDate = DateTime.now().add(Duration(days: 7));
    selectedDueTime = TimeOfDay(hour: 23, minute: 59);

    // Simulate fetching classes (would be API call in real implementation)
    _fetchTeacherClasses();
  }

  Future<void> _fetchTeacherClasses() async {
    // Mock data - would be replaced with actual API call
    await Future.delayed(Duration(milliseconds: 300));
    setState(() {
      teacherClasses = [
        {'id': 1, 'name': 'Matemáticas 101'},
        {'id': 2, 'name': 'Física Avanzada'},
        {'id': 3, 'name': 'Programación'},
        {'id': 4, 'name': 'Ciencias de Datos'},
      ];
    });
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

  void _selectClass() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Seleccionar Clase'),
        children: teacherClasses.map((classItem) =>
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                selectedClassId = classItem['id'] as int;
                selectedClassName = classItem['name'] as String;
              });
              Navigator.pop(context);
            },
            child: Text(classItem['name'] as String),
          )
        ).toList(),
      ),
    );
  }

  Future<void> _createAssignment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona una clase')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Format date to ISO format
      final formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(selectedDueDate);

      // This would be an actual API call in the real implementation
      await Future.delayed(Duration(seconds: 1));

      // Return success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarea creada correctamente')),
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
        title: Text('Nueva Tarea'),
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

              // Class selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clase',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedClassId != null
                                ? selectedClassName
                                : 'Ninguna clase seleccionada',
                              style: TextStyle(
                                fontSize: 16,
                                color: selectedClassId != null ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _selectClass,
                            child: Text('Seleccionar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
              SizedBox(height: 24),

              // Create button
              isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _createAssignment,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'CREAR TAREA',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}