class SignupResponse {
  final String? message;
  final int? studentId;
  final String? token;
  final String? duplicateField;
  final String? error;
  final int? statusCode;
  final bool success;

  SignupResponse({
    this.message,
    this.studentId,
    this.token,
    this.duplicateField,
    this.error,
    this.statusCode,
    required this.success,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      message: json['data'] != null ? json['data']['message'] : null,
      studentId: json['data'] != null ? json['data']['student_id'] : null,
      token: json['token'],
      duplicateField: json['duplicate_field'],
      error: json['error'],
      statusCode: json['status_code'],
      success: json['success'],
    );
  }
}