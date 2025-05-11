class GradeAssignmentEvidenceResponse {
  final bool success;
  final int statusCode;
  final String? error;
  final GradeAssignmentEvidenceData? data;

  GradeAssignmentEvidenceResponse({
    required this.success,
    required this.statusCode,
    this.error,
    this.data,
  });

  factory GradeAssignmentEvidenceResponse.fromJson(Map<String, dynamic> json) {
    return GradeAssignmentEvidenceResponse(
      success: json['success'] ?? false,
      statusCode: json['status_code'] ?? 500,
      error: json['error'],
      data: json['data'] != null
          ? GradeAssignmentEvidenceData.fromJson(json['data'])
          : null,
    );
  }
}

class GradeAssignmentEvidenceData {
  final String evidenceId;

  GradeAssignmentEvidenceData({
    required this.evidenceId,
  });

  factory GradeAssignmentEvidenceData.fromJson(Map<String, dynamic> json) {
    var rawId = json['evidence_id'];
    return GradeAssignmentEvidenceData(
      evidenceId: rawId != null ? rawId.toString() : '',
    );
  }
}