import 'package:intl/intl.dart';

class RetrieveTeacherAssignmentsResponse {
  final bool success;
  final List<AssignmentData>? data;
  final int statusCode;
  final String? error;

  RetrieveTeacherAssignmentsResponse({
    required this.success,
    this.data,
    required this.statusCode,
    this.error,
  });

  factory RetrieveTeacherAssignmentsResponse.fromJson(Map<String, dynamic> json) {
    return RetrieveTeacherAssignmentsResponse(
      success: json['success'],
      data: json['data'] != null
          ? List<AssignmentData>.from(json['data'].map((item) => AssignmentData.fromJson(item)))
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

class AssignmentData {
  final int assignmentId;
  final String title;
  final String description;
  final String dueDate;
  final int classId;
  final String className;
  final String semester;
  final String groupNum;
  final int submissionsCount;

  AssignmentData({
    required this.assignmentId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.classId,
    required this.className,
    required this.semester,
    required this.groupNum,
    required this.submissionsCount,
  });

  factory AssignmentData.fromJson(Map<String, dynamic> json) {
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

    // Format group_num if it's an integer
    String groupNum = json['group_num'].toString();
    if (json['group_num'] is int) {
      int groupNumInt = json['group_num'];
      groupNum = groupNumInt < 10
          ? '00$groupNumInt'
          : groupNumInt < 100
              ? '0$groupNumInt'
              : '$groupNumInt';
    }

    return AssignmentData(
      assignmentId: json['assignment_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['due_date'] ?? '',
      classId: json['class_id'],
      className: json['class_name'] ?? '',
      semester: semester,
      groupNum: groupNum,
      submissionsCount: json['submissions_count'] ?? 0,
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
      'group_num': groupNum,
      'submissions_count': submissionsCount,
    };
  }

  // Utility method to convert to TeacherAssignmentData
  TeacherAssignmentData toTeacherAssignmentData({int totalStudents = 30, int gradedCount = 0}) {
    return TeacherAssignmentData(
      id: assignmentId,
      title: title,
      className: className,
      description: description,
      dueDate: dueDate,
      classId: classId,
      submissionCount: submissionsCount,
      totalStudents: totalStudents,
      gradedCount: gradedCount,
    );
  }
}

class TeacherAssignmentData {
  final int id;
  final String title;
  final String className;
  final String description;
  final String dueDate;
  final int classId;
  final int submissionCount;
  final int totalStudents;
  final int gradedCount;

  TeacherAssignmentData({
    required this.id,
    required this.title,
    required this.className,
    required this.description,
    required this.dueDate,
    required this.classId,
    required this.submissionCount,
    required this.totalStudents,
    required this.gradedCount,
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