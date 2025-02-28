class CreateClassResponse {
  final bool success;
  final int statusCode;
  final String? error;
  final String? message;

  CreateClassResponse({
    required this.success,
    required this.statusCode,
    this.error,
    this.message,
  });

  factory CreateClassResponse.fromJson(Map<String, dynamic> json) {
    return CreateClassResponse(
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