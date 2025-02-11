class ClassDeleteStudentResponse {
  final bool success;
  final String? error;
  final int statusCode;

  ClassDeleteStudentResponse({
    required this.success,
    this.error,
    required this.statusCode,
  });

  factory ClassDeleteStudentResponse.fromJson(Map<String, dynamic> json) {
    return ClassDeleteStudentResponse(
      success: json['success'],
      error: json['error'],
      statusCode: json['status_code'],
    );
  }
}