class ClassAddStudentRequest {
  final int matnum;
  final int classId;

  ClassAddStudentRequest({required this.matnum, required this.classId});

  Map<String, dynamic> toJson() {
    return {
      'matnum': matnum,
      'class_id': classId,
    };
  }
}