class RetrieveClassAttendanceRequest {
  final String classId;

  RetrieveClassAttendanceRequest({
    required this.classId,
  });

  Map<String, String> toQueryParameters() {
    return {
      'class_id': classId,
    };
  }
}