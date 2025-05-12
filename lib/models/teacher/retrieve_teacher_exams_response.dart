// lib/models/teacher/retrieve_teacher_exams_response.dart
class RetrieveTeacherExamsResponse {
  final bool success;
  final List<TeacherExamData>? data;
  final String? error;
  final int statusCode;

  RetrieveTeacherExamsResponse({
    required this.success,
    this.data,
    this.error,
    required this.statusCode,
  });

  factory RetrieveTeacherExamsResponse.fromJson(Map<String, dynamic> json) {
    var rawData = json['data'];
    List<TeacherExamData>? examData;

    if (rawData != null && rawData is List) {
      examData = rawData
          .map((item) => TeacherExamData.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return RetrieveTeacherExamsResponse(
      success: json['success'] as bool? ?? false,
      data: examData,
      error: json['error'] as String?,
      statusCode: json['status_code'] as int? ?? 500,
    );
  }
}

class TeacherExamData {
  final int examId;
  final String examName;
  final int classId;
  final String className;
  final String classRoom;
  final String date;
  final String hour;
  final int studentsCount;
  final int gradedCount;

  TeacherExamData({
    required this.examId,
    required this.examName,
    required this.classId,
    required this.className,
    required this.classRoom,
    required this.date,
    required this.hour,
    this.studentsCount = 0,
    this.gradedCount = 0,
  });

  factory TeacherExamData.fromJson(Map<String, dynamic> json) {
    return TeacherExamData(
      examId: json['exam_id'] as int,
      examName: json['exam_name'] as String,
      classId: json['class_id'] as int,
      className: json['class_name'] as String? ?? '',
      classRoom: json['class_room'] as String,
      date: json['date'] as String,
      hour: json['hour'] as String,
      // These fields aren't in the API response, so we set defaults
      studentsCount: json['students_count'] as int? ?? 0,
      gradedCount: json['graded_count'] as int? ?? 0,
    );
  }
}