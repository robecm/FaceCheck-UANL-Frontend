class LoginResponse {
  final bool success;
  final String? message;
  final String? error;
  final int statusCode;
  final String? faceImg;
  final int? studentId;
  final int? teacherId;

  LoginResponse({
    required this.success,
    this.message,
    this.error,
    required this.statusCode,
    this.faceImg,
    this.studentId,
    this.teacherId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['data']?['message'],
      error: json['error'] ?? '',
      statusCode: json['status_code'] ?? 500,  // Default to 500 if null
      faceImg: json['data']?['face_img'],
      studentId: json['data']?['student_id'],
      teacherId: json['data']?['teacher_id'],
    );
  }
}
