import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/teacher/class/exams/create_class_exam_request.dart';
import '../../../../services/teacher_api_service.dart';

class CreateClassExamScreen extends StatefulWidget {
  final int classId;
  final String className;

  const CreateClassExamScreen({super.key, required this.classId, required this.className});

  @override
  _CreateClassExamScreenState createState() => _CreateClassExamScreenState();
}

class _CreateClassExamScreenState extends State<CreateClassExamScreen> {
  late TextEditingController examNameController;
  late TextEditingController classRoomController;
  late TextEditingController dateController;
  String? selectedHour;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final List<String> hourOptions = [
    'M1', 'M2', 'M3', 'M4', 'M5', 'M6',
    'V1', 'V2', 'V3', 'V4', 'V5', 'V6',
    'N1', 'N2', 'N3', 'N4', 'N5', 'N6',
  ];

  @override
  void initState() {
    super.initState();
    examNameController = TextEditingController();
    classRoomController = TextEditingController();
    dateController = TextEditingController();
  }

  @override
  void dispose() {
    examNameController.dispose();
    classRoomController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _createExam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final request = CreateClassExamRequest(
      examName: examNameController.text,
      classId: widget.classId,
      date: dateController.text,
      classRoom: classRoomController.text,
      hour: selectedHour!,
    );

    try {
      final apiService = TeacherApiService();
      final response = await apiService.createClassExam(request);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exam created successfully')),
        );
        Navigator.pop(context, true); // Pass true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create exam: ${response.error}')),
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
        title: Text('Create Exam for ${widget.className}'),
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
                decoration: InputDecoration(
                  labelText: 'Exam Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Exam name cannot be empty';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: classRoomController,
                decoration: InputDecoration(
                  labelText: 'Class Room',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Class room cannot be empty';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Date cannot be empty';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedHour,
                decoration: InputDecoration(
                  labelText: 'Hour',
                ),
                items: hourOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedHour = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Hour cannot be empty';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _createExam,
                      child: Text('Save Changes'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}