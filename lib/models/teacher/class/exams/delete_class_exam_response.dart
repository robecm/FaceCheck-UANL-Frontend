class DeleteClassExamResponse {
  final bool success;
  final int statusCode;
  final String? error;
  final Map<String, dynamic>? data;

  DeleteClassExamResponse({
    required this.success,
    required this.statusCode,
    this.error,
    this.data,
  });

  factory DeleteClassExamResponse.fromJson(Map<String, dynamic> json) {
    return DeleteClassExamResponse(
      success: json['success'] as bool,
      statusCode: json['status_code'] as int,
      error: json['error'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status_code': statusCode,
      'error': error,
      'data': data,
    };
  }
}