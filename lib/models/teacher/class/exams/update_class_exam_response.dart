class UpdateClassExamResponse {
  final bool success;
  final int statusCode;
  final String? error;
  final String? message;

  UpdateClassExamResponse({
    required this.success,
    required this.statusCode,
    this.error,
    this.message,
  });

  factory UpdateClassExamResponse.fromJson(Map<String, dynamic> json) {
    return UpdateClassExamResponse(
      success: json['success'] as bool,
      statusCode: json['status_code'] as int,
      error: json['error'] as String?,
      message: json['data'] != null ? json['data']['message'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status_code': statusCode,
      'error': error,
      'data': message != null ? {'message': message} : null,
    };
  }
}