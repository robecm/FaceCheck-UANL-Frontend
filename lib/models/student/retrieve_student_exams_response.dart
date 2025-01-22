class RetrieveStudentExamsResponse {
  final bool success;
  final List<ExamData>? data;
  final int statusCode;
  final String? error;

  RetrieveStudentExamsResponse({
    required this.success,
    this.data,
    required this.statusCode,
    this.error,
  });

  factory RetrieveStudentExamsResponse.fromJson(Map<String, dynamic> json) {
    return RetrieveStudentExamsResponse(
      success: json['success'],
      data: json['data'] != null
          ? List<ExamData>.from(json['data'].map((item) => ExamData.fromJson(item)))
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

class ExamData {
  final int examId;
  final String examName;
  final int classId;
  final String date;
  final String classRoom;
  final String hour;
  final double? score;
  final String className;
  final String teacherName;

  ExamData({
    required this.examId,
    required this.examName,
    required this.classId,
    required this.date,
    required this.classRoom,
    required this.hour,
    this.score,
    required this.className,
    required this.teacherName,
  });

  factory ExamData.fromJson(Map<String, dynamic> json) {
    return ExamData(
      examId: json['exam_id'],
      examName: json['exam_name'],
      classId: json['class_id'],
      date: json['date'],
      classRoom: json['class_room'],
      hour: json['hour'],
      score: json['score'] != null ? double.parse(json['score'].toString()) : null,
      className: json['class_name'],
      teacherName: json['teacher_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exam_id': examId,
      'exam_name': examName,
      'class_id': classId,
      'date': date,
      'class_room': classRoom,
      'hour': hour,
      'score': score,
      'class_name': className,
      'teacher_name': teacherName,
    };
  }
}