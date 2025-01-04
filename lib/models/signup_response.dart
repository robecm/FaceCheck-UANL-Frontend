class SignupResponse {
  final String? message;
  final String? token;
  final String? duplicateField;
  final String? error;
  final int? statusCode;
  final bool success;

  SignupResponse({
    this.message,
    this.token,
    this.duplicateField,
    this.error,
    this.statusCode,
    required this.success,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      message: json['data'] != null ? json['data']['message'] : null,
      token: json['token'],
      duplicateField: json['duplicate_field'],
      error: json['error'],
      statusCode: json['status_code'],
      success: json['success'],
    );
  }
}