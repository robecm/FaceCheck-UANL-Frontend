class DuplicateResponse {
  final bool success;
  final String? error;
  final int statusCode;
  final String? duplicateField;

  DuplicateResponse({
    required this.success,
    this.error,
    required this.statusCode,
    this.duplicateField,
  });

  factory DuplicateResponse.fromJson(Map<String, dynamic> json) {
    return DuplicateResponse(
      success: json['success'],
      error: json['error'],
      statusCode: json['status_code'],
      duplicateField: json['duplicate_field'],
    );
  }
}