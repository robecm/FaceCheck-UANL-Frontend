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
  final String? examName;
  final String? examDate;
  final String? startTime;
  final String? endTime;

  ExamData({
    this.examName,
    this.examDate,
    this.startTime,
    this.endTime,
  });

  factory ExamData.fromJson(Map<String, dynamic> json) {
    return ExamData(
      examName: json['exam_name'],
      examDate: json['exam_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exam_name': examName,
      'exam_date': examDate,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}