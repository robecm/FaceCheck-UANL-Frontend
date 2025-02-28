class ClassAddStudentResponse {
  final bool success;
  final String? message;
  final String? error;
  final int statusCode;

  ClassAddStudentResponse({
    required this.success,
    this.message,
    this.error,
    required this.statusCode,
  });

  factory ClassAddStudentResponse.fromJson(Map<String, dynamic> json) {
    return ClassAddStudentResponse(
      success: json['success'],
      message: json['data']?['message'],
      error: json['error'],
      statusCode: json['status_code'],
    );
  }
}