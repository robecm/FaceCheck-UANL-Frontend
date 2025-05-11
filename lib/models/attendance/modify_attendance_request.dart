class ModifyAttendanceRequest {
  final int classId;
  final List<int> studentIds;
  final String attendanceDate;
  final String? attendanceTime;
  final bool present;

  ModifyAttendanceRequest({
    required this.classId,
    required this.studentIds,
    required this.attendanceDate,
    this.attendanceTime,
    required this.present,
  });

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'student_id': studentIds,
      'attendance_date': attendanceDate,
      if (attendanceTime != null) 'attendance_time': attendanceTime,
      'present': present,
    };
  }
}