class RetrieveAssignmentEvidencesResponse {
  final bool success;
  final int statusCode;
  final String? error;
  final List<AssignmentEvidence>? data;

  RetrieveAssignmentEvidencesResponse({
    required this.success,
    required this.statusCode,
    this.error,
    this.data,
  });

  factory RetrieveAssignmentEvidencesResponse.fromJson(Map<String, dynamic> json) {
    return RetrieveAssignmentEvidencesResponse(
      success: json['success'] ?? false,
      statusCode: json['status_code'] ?? 500,
      error: json['error'],
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => AssignmentEvidence.fromJson(item))
              .toList()
          : null,
    );
  }
}

class AssignmentEvidence {
  final String evidenceId;
  final int studentId;
  final int assignmentId;
  final int classId;
  final String submissionDate;
  final String? fileData; // base64 encoded file
  final String? fileName;
  final double? grade;
  final String? feedback;
  final String studentName; // We'll keep this for UI display

  AssignmentEvidence({
    required this.evidenceId,
    required this.studentId,
    required this.assignmentId,
    required this.classId,
    required this.submissionDate,
    this.fileData,
    this.fileName,
    this.grade,
    this.feedback,
    required this.studentName,
  });

  factory AssignmentEvidence.fromJson(Map<String, dynamic> json) {
    // Handle different data types
    var rawId = json['evidence_id'];
    var rawStudentId = json['student_id'];
    var rawAssignmentId = json['assignment_id'];
    var rawClassId = json['class_id'];
    var rawGrade = json['grade'];

    return AssignmentEvidence(
      evidenceId: rawId != null ? rawId.toString() : '',
      studentId: rawStudentId is int ? rawStudentId : int.tryParse(rawStudentId.toString()) ?? 0,
      assignmentId: rawAssignmentId is int ? rawAssignmentId : int.tryParse(rawAssignmentId.toString()) ?? 0,
      classId: rawClassId is int ? rawClassId : int.tryParse(rawClassId.toString()) ?? 0,
      submissionDate: json['submitted_at'] ?? '',
      fileData: json['file_data'],
      fileName: json['file_name'] ?? 'evidence_${rawId ?? ''}.pdf', // Default filename
      grade: rawGrade != null ? double.tryParse(rawGrade.toString()) : null,
      feedback: json['feedback'],
      studentName: json['student_name'] ?? 'Student #${rawStudentId ?? ''}', // Default if name not provided
    );
  }
}