class RetrieveClassStudentsResponse {
  final bool success;
  final List<StudentData>? data;
  final int statusCode;
  final String? error;

  RetrieveClassStudentsResponse({
    required this.success,
    required this.data,
    required this.statusCode,
    this.error,
  });

  factory RetrieveClassStudentsResponse.fromJson(Map<String, dynamic> json) {
    return RetrieveClassStudentsResponse(
      success: json['success'],
      data: json['data'] != null
          ? List<StudentData>.from(json['data'].map((x) => StudentData.fromJson(x)))
          : null,
      statusCode: json['status_code'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : null,
      'status_code': statusCode,
      'error': error,
    };
  }
}

class StudentData {
  final String email;
  final String faculty;
  final int id;
  final String matnum;
  final String name;
  final String username;

  StudentData({
    required this.email,
    required this.faculty,
    required this.id,
    required this.matnum,
    required this.name,
    required this.username,
  });

  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      email: json['email'],
      faculty: json['faculty'],
      id: json['id'],
      matnum: json['matnum'],
      name: json['name'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'faculty': faculty,
      'id': id,
      'matnum': matnum,
      'name': name,
      'username': username,
    };
  }
}