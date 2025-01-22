class VerifyFaceResponse {
  final bool success;
  final dynamic match; // match can be true, false, or 'VALUE ERROR'
  final String? error;
  final int? statusCode;

  VerifyFaceResponse({
    required this.success,
    this.match,
    this.error,
    this.statusCode,
  });

  factory VerifyFaceResponse.fromJson(Map<String, dynamic> json) {
    return VerifyFaceResponse(
      success: json['success'] as bool,
      match: json['data'] != null ? json['data']['match'] : null,
      error: json['error'],
      statusCode: json['status_code'],
    );
  }
}