class RetrieveClassExamsResponse {
  final bool success;
  final int statusCode;
  final String? error;
  final List<ExamData>? data;

  RetrieveClassExamsResponse({
    required this.success,
    required this.statusCode,
    this.error,
    this.data,
  });

  factory RetrieveClassExamsResponse.fromJson(Map<String, dynamic> json) {
    return RetrieveClassExamsResponse(
      success: json['success'],
      statusCode: json['status_code'],
      error: json['error'],
      data: json['data'] != null
          ? List<ExamData>.from(json['data'].map((item) => ExamData.fromJson(item)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status_code': statusCode,
      'error': error,
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }
}

class ExamData {
  final int classId;
  final String classRoom;
  final String date;
  final int examId;
  final String examName;
  final String hour;

  ExamData({
    required this.classId,
    required this.classRoom,
    required this.date,
    required this.examId,
    required this.examName,
    required this.hour,
  });

  factory ExamData.fromJson(Map<String, dynamic> json) {
    return ExamData(
      classId: json['class_id'],
      classRoom: json['class_room'],
      date: json['date'],
      examId: json['exam_id'],
      examName: json['exam_name'],
      hour: json['hour'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'class_room': classRoom,
      'date': date,
      'exam_id': examId,
      'exam_name': examName,
      'hour': hour,
    };
  }
}