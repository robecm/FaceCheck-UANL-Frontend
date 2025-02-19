class RetrieveExamResultsResponse {
  final bool success;
  final List<ExamResult>? data;
  final String? error;
  final int statusCode;

  RetrieveExamResultsResponse({
    required this.success,
    this.data,
    this.error,
    required this.statusCode,
  });

  factory RetrieveExamResultsResponse.fromJson(Map<String, dynamic> json) {
    var rawData = json['data'];
    List<ExamResult>? examResults;

    if (rawData != null && rawData is List) {
      examResults = rawData
          .map((item) => ExamResult.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return RetrieveExamResultsResponse(
      success: json['success'] as bool? ?? false,
      data: examResults,
      error: json['error'] as String?,
      statusCode: json['status_code'] as int? ?? 500,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((result) => result.toJson()).toList(),
      'error': error,
      'status_code': statusCode,
    };
  }
}

class ExamResult {
  final int? resultId;
  final String studentName;
  final String studentMatnum;
  final int studentId;
  final String? score;
  final int examId;
  final int classId;

  ExamResult({
    this.resultId,
    required this.studentName,
    required this.studentMatnum,
    required this.studentId,
    this.score,
    required this.examId,
    required this.classId,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      resultId: json['result_id'] as int?,
      studentName: json['student_name'] as String? ?? '',
      studentMatnum: json['student_matnum'] as String? ?? '',
      studentId: json['student_id'] as int? ?? 0,
      score: json['score']?.toString(),
      examId: json['exam_id'] as int? ?? 0,
      classId: json['class_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result_id': resultId,
      'student_name': studentName,
      'student_matnum': studentMatnum,
      'student_id': studentId,
      'score': score,
      'exam_id': examId,
      'class_id': classId,
    };
  }
}