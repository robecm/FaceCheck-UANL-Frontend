class RetrieveStudentTeachersResponse {
  final bool success;
  final List<TeacherData>? data;
  final int statusCode;
  final String? error;

  RetrieveStudentTeachersResponse({
    required this.success,
    this.data,
    required this.statusCode,
    this.error,
  });

  factory RetrieveStudentTeachersResponse.fromJson(Map<String, dynamic> json) {
    return RetrieveStudentTeachersResponse(
      success: json['success'],
      data: json['data'] != null
          ? List<TeacherData>.from(json['data'].map((item) => TeacherData.fromJson(item)))
          : null,
      statusCode: json['status_code'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((item) => item.toJson()).toList(),
      'status_code': statusCode,
      'error': error,
    };
  }
}

class TeacherData {
  final String name;
  final String email;
  final List<String> classNames;

  TeacherData({
    required this.name,
    required this.email,
    required this.classNames,
  });

  factory TeacherData.fromJson(Map<String, dynamic> json) {
    return TeacherData(
      name: json['name'],
      email: json['email'],
      classNames: List<String>.from(json['class_name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'class_name': classNames,
    };
  }
}