class UploadAssignmentEvidenceRequest {
  final int assignmentId;
  final int studentId;
  final int classId;
  final String fileData;
  final String fileName;
  final String fileExtension;  // New field

  UploadAssignmentEvidenceRequest({
    required this.assignmentId,
    required this.studentId,
    required this.classId,
    required this.fileData,
    required this.fileName,
    required this.fileExtension,
  });

  Map<String, dynamic> toJson() {
    return {
      'assignment_id': assignmentId.toString(),
      'student_id': studentId.toString(),
      'class_id': classId.toString(),
      'file_data': fileData,
      'file_name': fileName,
      'file_extension': fileExtension,
    };
  }
}