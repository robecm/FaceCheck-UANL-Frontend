class UploadAssignmentEvidenceResponse {
  final bool success;
  final int statusCode;
  final String? error;
  final UploadAssignmentEvidenceData? data;

  UploadAssignmentEvidenceResponse({
    required this.success,
    required this.statusCode,
    this.error,
    this.data,
  });

  factory UploadAssignmentEvidenceResponse.fromJson(Map<String, dynamic> json) {
    return UploadAssignmentEvidenceResponse(
      success: json['success'] ?? false,
      statusCode: json['status_code'] ?? 500,
      error: json['error'],
      data: json['data'] != null ? UploadAssignmentEvidenceData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status_code': statusCode,
      'error': error,
      'data': data?.toJson(),
    };
  }
}

class UploadAssignmentEvidenceData {
  final String evidenceId;

  UploadAssignmentEvidenceData({
    required this.evidenceId,
  });

  factory UploadAssignmentEvidenceData.fromJson(Map<String, dynamic> json) {
    // Handle both string and integer values for evidenceId
    var rawId = json['evidence_id'];
    return UploadAssignmentEvidenceData(
      evidenceId: rawId != null ? rawId.toString() : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evidence_id': evidenceId,
    };
  }
}