class RetrieveExamResultsResponse {
  final bool success;
  final int statusCode;
  final String? error;
  final List<ExamResult>? data;

  RetrieveExamResultsResponse({
    required this.success,
    required this.statusCode,
    this.error,
    this.data,
  });

  factory RetrieveExamResultsResponse.fromJson(Map<String, dynamic> json) {
    return RetrieveExamResultsResponse(
      success: json['success'] as bool,
      statusCode: json['status_code'] as int,
      error: json['error'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => ExamResult.fromJson(item as Map<String, dynamic>))
          .toList(),
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

class ExamResult {
  final String? score;
  final int studentId;
  final String studentMatnum;
  final String studentName;

  ExamResult({
    this.score,
    required this.studentId,
    required this.studentMatnum,
    required this.studentName,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      score: json['score'] as String?,
      studentId: json['student_id'] as int,
      studentMatnum: json['student_matnum'] as String,
      studentName: json['student_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'student_id': studentId,
      'student_matnum': studentMatnum,
      'student_name': studentName,
    };
  }
}