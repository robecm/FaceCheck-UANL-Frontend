class RetrieveUserInfoResponse {
  final bool success;
  final UserInfoData? data;
  final int statusCode;
  final String? error;

  RetrieveUserInfoResponse({
    required this.success,
    this.data,
    required this.statusCode,
    this.error,
  });

  factory RetrieveUserInfoResponse.fromJson(Map<String, dynamic> json) {
    return RetrieveUserInfoResponse(
      success: json['success'],
      data: json['data'] != null ? UserInfoData.fromJson(json['data']) : null,
      statusCode: json['status_code'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'status_code': statusCode,
      'error': error,
    };
  }
}

class UserInfoData {
  final int userId;
  final String userType;
  final String name;
  final String username;
  final String email;
  final String? birthdate;
  // Student-specific fields
  final String? faculty;
  final String? matnum;
  // Teacher-specific field
  final String? worknum;

  UserInfoData({
    required this.userId,
    required this.userType,
    required this.name,
    required this.username,
    required this.email,
    this.birthdate,
    this.faculty,
    this.matnum,
    this.worknum,
  });

  factory UserInfoData.fromJson(Map<String, dynamic> json) {
    return UserInfoData(
      // The API response doesn't include user_id, so we provide a fallback
      userId: json['user_id'] ?? 0,
      // The API response doesn't include user_type, so we check for matnum to determine
      userType: json['user_type'] ?? (json['matnum'] != null ? 'student' : 'teacher'),
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      birthdate: json['birthdate'],
      faculty: json['faculty'],
      matnum: json['matnum'],
      worknum: json['worknum'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_type': userType,
      'name': name,
      'username': username,
      'email': email,
      'birthdate': birthdate,
      'faculty': faculty,
      // Only include type-specific fields
      if (userType == 'student') ...{
        'matnum': matnum,
      },
      if (userType == 'teacher') 'worknum': worknum,
    };
  }
}