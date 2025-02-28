class ModifyUserInfoRequest {
  final int userId;
  final String userType;
  final String? name;
  final String? username;
  final String? password;
  final String? email;
  final String? matnum;
  final String? worknum;
  final String? faculty;
  final String? birthdate;

  ModifyUserInfoRequest({
    required this.userId,
    required this.userType,
    this.name,
    this.username,
    this.email,
    this.password,
    this.birthdate,
    this.faculty,
    this.matnum,
    this.worknum,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'user_type': userType,
    };

    // Add optional fields only if they are not null
    if (name != null) data['name'] = name;
    if (username != null) data['username'] = username;
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;
    if (birthdate != null) data['birthdate'] = birthdate;
    if (faculty != null) data['faculty'] = faculty;

    // Add user type-specific fields
    if (userType == 'student' && matnum != null) {
      data['matnum'] = matnum;
    }
    if (userType == 'teacher' && worknum != null) {
      data['worknum'] = worknum;
    }

    return data;
  }
}