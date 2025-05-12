
class RetrieveClassAttendanceResponse {
  final bool success;
  final List<ClassAttendanceData>? data;
  final int statusCode;
  final String? error;

  RetrieveClassAttendanceResponse({
    required this.success,
    this.data,
    required this.statusCode,
    this.error,
  });

  factory RetrieveClassAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return RetrieveClassAttendanceResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? List<ClassAttendanceData>.from(
              (json['data'] as List).map((item) => ClassAttendanceData.fromJson(item)))
          : null,
      statusCode: json['status_code'] ?? 500,
      error: json['error'],
    );
  }
}

class ClassAttendanceData {
  final int attendanceId;
  final int studentId;
  final int classId;
  final String date;
  final String? time;
  final bool present;
  final String studentName;
  final String studentMatnum;

  ClassAttendanceData({
    required this.attendanceId,
    required this.studentId,
    required this.classId,
    required this.date,
    this.time,
    required this.present,
    required this.studentName,
    required this.studentMatnum,
  });

  factory ClassAttendanceData.fromJson(Map<String, dynamic> json) {
    return ClassAttendanceData(
      attendanceId: json['attendance_id'],
      studentId: json['student_id'],
      classId: json['class_id'],
      date: json['date'],
      time: json['time'],
      present: json['present'],
      studentName: json['student_name'],
      studentMatnum: json['student_matnum'],
    );
  }
}