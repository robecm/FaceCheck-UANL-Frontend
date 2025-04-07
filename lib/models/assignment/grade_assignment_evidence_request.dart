class GradeAssignmentEvidenceRequest {
  final String evidenceId;
  final double grade;
  final String? feedback;

  GradeAssignmentEvidenceRequest({
    required this.evidenceId,
    required this.grade,
    this.feedback,
  });

  Map<String, dynamic> toJson() {
    return {
      'evidence_id': evidenceId,
      'grade': grade,
      if (feedback != null) 'feedback': feedback,
    };
  }
}