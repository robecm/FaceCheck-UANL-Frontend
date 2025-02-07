class RetrieveClassExamsResponse {
  final bool success;
  final List<ExamData>? data;
  final int statusCode;
  final String? error;

  RetrieveClassExamsResponse({
    required this.success,
    this.data,
    required this.statusCode,
    this.error,
  });

  factory RetrieveClassExamsResponse.fromJson(Map<String, dynamic> json) {
    return RetrieveClassExamsResponse(
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
  final String examDate;
  final String startTime;
  final String endTime;
  final int classId;

  ExamData({
    required this.examId,
    required this.examName,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    required this.classId,
  });

  factory ExamData.fromJson(Map<String, dynamic> json) {
    return ExamData(
      examId: json['exam_id'],
      examName: json['exam_name'] ?? '',
      examDate: json['exam_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      classId: json['class_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exam_id': examId,
      'exam_name': examName,
      'exam_date': examDate,
      'start_time': startTime,
      'end_time': endTime,
      'class_id': classId,
    };
  }
}