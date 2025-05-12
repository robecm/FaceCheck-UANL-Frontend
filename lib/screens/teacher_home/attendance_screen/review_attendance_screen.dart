import 'package:flutter/material.dart';
import '../../../models/attendance/retrieve_class_attendance_response.dart';
import '../../../services/teacher_api_service.dart';

class ReviewAttendanceScreen extends StatefulWidget {
  final int classId;
  final String className;

  const ReviewAttendanceScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<ReviewAttendanceScreen> createState() => _ReviewAttendanceScreenState();
}

class _ReviewAttendanceScreenState extends State<ReviewAttendanceScreen> {
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  List<ClassAttendanceData> attendanceRecords = [];
  Map<String, List<ClassAttendanceData>> attendanceByDate = {};
  String? selectedDateString;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final apiService = TeacherApiService();
      final response = await apiService.retrieveClassAttendance(widget.classId.toString());

      if (response.success && response.data != null) {
        // Group attendance records by date
        final Map<String, List<ClassAttendanceData>> groupedByDate = {};
        for (var record in response.data!) {
          if (!groupedByDate.containsKey(record.date)) {
            groupedByDate[record.date] = [];
          }
          groupedByDate[record.date]!.add(record);
        }

        // Sort each date's records by matnum
        groupedByDate.forEach((date, records) {
          records.sort((a, b) => int.parse(a.studentMatnum).compareTo(int.parse(b.studentMatnum)));
        });

        // Format selected date for comparison
        final formattedSelectedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

        setState(() {
          attendanceByDate = groupedByDate;
          selectedDateString = formattedSelectedDate;
          attendanceRecords = groupedByDate[formattedSelectedDate] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          attendanceRecords = [];
          isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Error retrieving attendance records'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Error handling remains unchanged
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // Set last date to the end of next year
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
      final formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

      setState(() {
        selectedDate = picked;
        selectedDateString = formattedDate;
        attendanceRecords = attendanceByDate[formattedDate] ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceSummary = attendanceRecords.isEmpty
        ? "No hay registros de asistencia"
        : "Presentes: ${attendanceRecords.where((r) => r.present).length}, "
        "Ausentes: ${attendanceRecords.where((r) => !r.present).length}";

    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte de Asistencia - ${widget.className}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Date selector
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

          // Attendance summary
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              attendanceSummary,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Attendance list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : attendanceRecords.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.event_busy,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay registros de asistencia para ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: attendanceRecords.length,
                        itemBuilder: (context, index) {
                          final record = attendanceRecords[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: record.present ? Colors.green : Colors.red,
                                child: Icon(
                                  record.present ? Icons.check : Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                record.studentName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                record.studentMatnum,
                              ),
                              trailing: Text(
                                record.present ? 'Presente' : 'Ausente',
                                style: TextStyle(
                                  color: record.present ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}