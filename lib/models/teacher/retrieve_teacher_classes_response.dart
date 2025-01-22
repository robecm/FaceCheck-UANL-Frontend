class RetrieveTeacherClassesResponse {
  final bool success;
  final List<ClassData>? data;
  final int statusCode;
  final String? error;

  RetrieveTeacherClassesResponse({
    required this.success,
    this.data,
    required this.statusCode,
    this.error,
  });

  factory RetrieveTeacherClassesResponse.fromJson(Map<String, dynamic> json) {
    return RetrieveTeacherClassesResponse(
      success: json['success'],
      data: json['data'] != null
          ? List<ClassData>.from(json['data'].map((item) => ClassData.fromJson(item)))
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

class ClassData {
  final int classId;
  final String className;
  final String classRoom;
  final String endTime;
  final String groupNum;
  final String semester;
  final String startTime;
  final int teacherId;
  final String teacherName;
  final String weekDays;

  ClassData({
    required this.classId,
    required this.className,
    required this.classRoom,
    required this.endTime,
    required this.groupNum,
    required this.semester,
    required this.startTime,
    required this.teacherId,
    required this.teacherName,
    required this.weekDays,
  });

  factory ClassData.fromJson(Map<String, dynamic> json) {
    int groupNum = json['group_num'];
    String formattedGroupNum = groupNum < 10
        ? '00$groupNum'
        : groupNum < 100
            ? '0$groupNum'
            : '$groupNum';

    // Map week_days values
    String weekDays = json['week_days'] ?? '';
    switch (weekDays) {
      case 'LUN':
        weekDays = 'Lunes';
        break;
      case 'MAR':
        weekDays = 'Martes';
        break;
      case 'MIE':
        weekDays = 'Miércoles';
        break;
      case 'JUE':
        weekDays = 'Jueves';
        break;
      case 'VIE':
        weekDays = 'Viernes';
        break;
      case 'SAB':
        weekDays = 'Sábado';
        break;
    }

    // Map semester values
    String semester = json['semester'] ?? '';
    switch (semester) {
      case 'agosto':
        semester = 'Agosto - Diciembre';
        break;
      case 'enero':
        semester = 'Enero - Junio';
        break;
      case 'verano':
        semester = 'Veranos';
        break;
    }

    return ClassData(
      classId: json['class_id'],
      className: json['class_name'] ?? '',
      classRoom: json['class_room'] ?? '',
      endTime: json['end_time'] ?? '',
      groupNum: formattedGroupNum,
      semester: semester,
      startTime: json['start_time'] ?? '',
      teacherId: json['teacher_id'],
      teacherName: json['teacher_name'] ?? '',
      weekDays: weekDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'class_name': className,
      'class_room': classRoom,
      'end_time': endTime,
      'group_num': groupNum,
      'semester': semester,
      'start_time': startTime,
      'teacher_name': teacherName,
      'week_days': weekDays,
    };
  }
}
