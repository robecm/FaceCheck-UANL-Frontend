import 'package:flutter/material.dart';
import '../../../services/teacher_api_service.dart';
import '../../../models/teacher/class/retrieve_class_students_response.dart';

class CheckAttendanceScreen extends StatefulWidget {
  final int classId;
  final String className;

  const CheckAttendanceScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<CheckAttendanceScreen> createState() => _CheckAttendanceScreenState();
}

class _CheckAttendanceScreenState extends State<CheckAttendanceScreen> {
  bool isLoading = true;
  List<StudentData> students = [];
  Map<int, bool> attendanceMap = {};
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    retrieveClassStudents();
  }

  Future<void> retrieveClassStudents() async {
    try {
      final apiService = TeacherApiService();
      final response = await apiService.retrieveClassStudents(widget.classId.toString());

      if (response.data != null) {
        // Sort students by matnum in ascending order
        final sortedStudents = response.data!..sort((a, b) =>
            int.parse(a.matnum).compareTo(int.parse(b.matnum)));

        // Initialize attendance map with all students marked present by default
        final initialAttendance = {
          for (var student in sortedStudents) student.id: false,
        };

        setState(() {
          students = sortedStudents;
          attendanceMap = initialAttendance;
          isLoading = false;
        });
      } else {
        setState(() {
          students = [];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load students: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _confirmAttendance() {
    // Check if there are any students
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay estudiantes en esta clase para registrar asistencia'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Count present and absent students
    int presentCount = 0;
    int absentCount = 0;

    attendanceMap.forEach((_, isPresent) {
      if (isPresent) {
        presentCount++;
      } else {
        absentCount++;
      }
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar asistencia'),
          content: Text(
            'Se registrarán $presentCount estudiantes como presentes y $absentCount como ausentes. ¿Desea continuar?'
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () {
                Navigator.pop(context);
                _submitAttendance();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitAttendance() async {
    // Store context reference and check if mounted throughout the function
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Registrando asistencia..."),
              ],
            ),
          ),
        );
      },
    );

    try {
      final apiService = TeacherApiService();

      // Group students by attendance status
      List<int> presentStudentIds = [];
      List<int> absentStudentIds = [];

      attendanceMap.forEach((studentId, isPresent) {
        if (isPresent) {
          presentStudentIds.add(studentId);
        } else {
          absentStudentIds.add(studentId);
        }
      });

      bool presentSuccess = true;
      bool absentSuccess = true;
      String errorMessage = '';

      // Register present students
      if (presentStudentIds.isNotEmpty) {
        final presentResponse = await apiService.modifyAttendance(
          widget.classId,
          presentStudentIds,
          true,
          attendanceDate: formattedDate,
        );

        if (!presentResponse.success) {
          presentSuccess = false;
          errorMessage = presentResponse.error ?? 'Error al registrar estudiantes presentes';
        }
      }

      // Register absent students
      if (absentStudentIds.isNotEmpty) {
        final absentResponse = await apiService.modifyAttendance(
          widget.classId,
          absentStudentIds,
          false,
          attendanceDate: formattedDate,
        );

        if (!absentResponse.success) {
          absentSuccess = false;
          errorMessage = errorMessage.isEmpty
              ? (absentResponse.error ?? 'Error al registrar estudiantes ausentes')
              : '$errorMessage y también hubo error con ausentes';
        }
      }

      // Close loading dialog (check if still mounted first)
      if (mounted) {
        navigator.pop();

        if (presentSuccess && absentSuccess) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Asistencia registrada correctamente'),
              backgroundColor: Colors.green,
            ),
          );

          // Return to previous screen
          navigator.pop();
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Error: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog (check if still mounted first)
      if (mounted) {
        navigator.pop();

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startSmartAttendance() {
    // To be implemented later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de asistencia inteligente en desarrollo')),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    // Set last date to the end of next year to allow more flexibility
    final now = DateTime.now();
    final lastDate = DateTime(now.year + 1, 12, 31);

    // Make sure initialDate is not after lastDate
    final initialDate = selectedDate.isAfter(lastDate) ? now : selectedDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: lastDate,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tomar Asistencia - ${widget.className}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Current date display
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Fecha: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Student list with attendance checkboxes
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : students.isEmpty
                    ? const Center(child: Text('No hay estudiantes en esta clase'))
                    : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Student info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          student.matnum,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Attendance checkbox
                                  Checkbox(
                                    value: attendanceMap[student.id] ?? false,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        attendanceMap[student.id] = value ?? false;
                                      });
                                    },
                                    activeColor: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Footer with action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(76), // 0.3 * 255 ≈ 76
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ElevatedButton(
                      onPressed: _confirmAttendance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Confirmar Asistencia',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ElevatedButton(
                      onPressed: _startSmartAttendance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Asistencia Inteligente',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}