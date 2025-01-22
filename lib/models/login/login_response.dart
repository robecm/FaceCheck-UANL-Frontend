class LoginResponse {
  final bool success;
  final String? message;
  final String? error;
  final int statusCode;
  final String? faceImg;

  LoginResponse({
    required this.success,
    this.message,
    this.error,
    required this.statusCode,
    this.faceImg,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['data']?['message'],
      error: json['error'] ?? '',
      statusCode: json['status_code'] ?? 500,  // Default to 500 if null
      faceImg: json['data']?['face_img'],
    );
  }
}
