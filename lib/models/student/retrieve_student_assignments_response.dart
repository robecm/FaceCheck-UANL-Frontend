import 'package:intl/intl.dart';

class RetrieveStudentAssignmentsResponse {
  final bool success;
  final List<StudentAssignmentItem>? data;
  final int statusCode;
  final String? error;

  RetrieveStudentAssignmentsResponse({
    required this.success,
    this.data,
    required this.statusCode,
    this.error,
  });

  factory RetrieveStudentAssignmentsResponse.fromJson(Map<String, dynamic> json) {
    return RetrieveStudentAssignmentsResponse(
      success: json['success'],
      data: json['data'] != null
          ? List<StudentAssignmentItem>.from(json['data'].map((item) => StudentAssignmentItem.fromJson(item)))
          : null,
      statusCode: json['status_code'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((item) => item.toJson()).toList(),
      'status_code': statusCode,
      'error': error,
    };
  }
}

class StudentAssignmentItem {
  final int assignmentId;
  final String title;
  final String description;
  final String dueDate;
  final int classId;
  final String className;
  final String semester;
  final String teacherName;
  final bool submitted;

  StudentAssignmentItem({
    required this.assignmentId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.classId,
    required this.className,
    required this.semester,
    required this.teacherName,
    required this.submitted,
  });

  factory StudentAssignmentItem.fromJson(Map<String, dynamic> json) {
    // Map semester values
    String semester = json['semester'] ?? '';
    switch (semester) {
      case 'agosto':
        semester = 'Agosto - Diciembre';
        break;
      case 'enero':
        semester = 'Enero - Junio';
        break;
      case 'verano':
        semester = 'Veranos';
        break;
    }

    return StudentAssignmentItem(
      assignmentId: json['assignment_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['due_date'] ?? '',
      classId: json['class_id'],
      className: json['class_name'] ?? '',
      semester: semester,
      teacherName: json['teacher_name'] ?? '',
      submitted: json['submitted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignment_id': assignmentId,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'class_id': classId,
      'class_name': className,
      'semester': semester,
      'teacher_name': teacherName,
      'submitted': submitted,
    };
  }

  // Utility method to convert to StudentAssignmentData for UI
  StudentAssignmentData toStudentAssignmentData() {
    return StudentAssignmentData(
      id: assignmentId,
      title: title,
      className: className,
      description: description,
      dueDate: dueDate,
      classId: classId,
      teacherName: teacherName,
      submitted: submitted,
    );
  }
}

class StudentAssignmentData {
  final int id;
  final String title;
  final String className;
  final String description;
  final String dueDate;
  final int classId;
  final String teacherName;
  final bool submitted;

  StudentAssignmentData({
    required this.id,
    required this.title,
    required this.className,
    required this.description,
    required this.dueDate,
    required this.classId,
    required this.teacherName,
    required this.submitted,
  });

  bool isDueDatePassed() {
    try {
      // Try multiple date formats to handle different API responses
      DateTime? due;

      // Try parsing with standard formats
      final formats = [
        'yyyy-MM-dd',
        'EEE, dd MMM yyyy HH:mm:ss',
        'yyyy-MM-ddTHH:mm:ss',
        'yyyy-MM-dd HH:mm:ss'
      ];

      for (var format in formats) {
        try {
          due = DateFormat(format).parse(dueDate);
          break;
        } catch (_) {
          // Continue trying other formats
        }
      }

      // If none of the formats worked, try a direct DateTime parse
      due ??= DateTime.tryParse(dueDate);

      // If we still don't have a valid date, default to a future date
      return due != null ? due.isBefore(DateTime.now()) : false;
    } catch (e) {
      print('Error parsing date: $dueDate - $e');
      return false;
    }
  }
}