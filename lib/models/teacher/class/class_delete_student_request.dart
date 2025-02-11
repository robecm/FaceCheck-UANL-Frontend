class ClassDeleteStudentRequest {
  final String classId;
  final String studentId;

  ClassDeleteStudentRequest({required this.classId, required this.studentId});

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'student_id': studentId,
    };
  }
}