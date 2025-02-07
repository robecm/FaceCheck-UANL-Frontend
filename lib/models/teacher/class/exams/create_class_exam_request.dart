class CreateClassExamRequest {
  final String examName;
  final int classId;
  final String date;
  final String classRoom;
  final String hour;

  CreateClassExamRequest({
    required this.examName,
    required this.classId,
    required this.date,
    required this.classRoom,
    required this.hour,
  });

  Map<String, dynamic> toJson() {
    return {
      'exam_name': examName,
      'class_id': classId,
      'date': date,
      'class_room': classRoom,
      'hour': hour,
    };
  }
}