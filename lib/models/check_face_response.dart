class CheckFaceResponse {
  final bool success;
  final int statusCode;
  final String? error;
  final Map<String, dynamic>? data;

  CheckFaceResponse({
    required this.success,
    required this.statusCode,
    this.error,
    this.data,
  });

  factory CheckFaceResponse.fromJson(Map<String, dynamic> json) {
    return CheckFaceResponse(
      success: json['success'] as bool,
      statusCode: json['status_code'],
      error: json['error'],
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
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