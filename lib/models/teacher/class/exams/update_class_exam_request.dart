class UpdateClassExamRequest {
  final int examId;
  final String examName;
  final int classId;
  final String date;
  final String classRoom;
  final String hour;

  UpdateClassExamRequest({
    required this.examId,
    required this.examName,
    required this.classId,
    required this.date,
    required this.classRoom,
    required String hour,
  }) : hour = _convertHour(hour);

  static String _convertHour(String hourCode) {
    const Map<String, String> hourMap = {
      'M1': '07:00:00',
      'M2': '07:50:00',
      'M3': '08:40:00',
      'M4': '09:30:00',
      'M5': '10:20:00',
      'M6': '11:10:00',
      'V1': '12:00:00',
      'V2': '12:50:00',
      'V3': '13:40:00',
      'V4': '14:30:00',
      'V5': '15:20:00',
      'V6': '16:10:00',
      'N1': '17:00:00',
      'N2': '17:45:00',
      'N3': '18:30:00',
      'N4': '19:15:00',
      'N5': '20:00:00',
      'N6': '20:45:00',
    };

    return hourMap[hourCode] ?? hourCode;
  }

  Map<String, dynamic> toJson() {
    return {
      'exam_id': examId,
      'exam_name': examName,
      'class_id': classId,
      'date': date,
      'class_room': classRoom,
      'hour': hour,
    };
  }
}