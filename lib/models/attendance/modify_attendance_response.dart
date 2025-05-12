class ModifyAttendanceResponse {
  final bool success;
  final int statusCode;
  final String? error;
  final ModifyAttendanceData? data;

  ModifyAttendanceResponse({
    required this.success,
    required this.statusCode,
    this.error,
    this.data,
  });

  factory ModifyAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return ModifyAttendanceResponse(
      success: json['success'] ?? false,
      statusCode: json['status_code'] ?? 500,
      error: json['error'],
      data: json['data'] != null ? ModifyAttendanceData.fromJson(json['data']) : null,
    );
  }
}

class ModifyAttendanceData {
  final List<int> createdAttendanceIds;
  final List<int> updatedAttendanceIds;

  ModifyAttendanceData({
    required this.createdAttendanceIds,
    required this.updatedAttendanceIds,
  });

  factory ModifyAttendanceData.fromJson(Map<String, dynamic> json) {
    return ModifyAttendanceData(
      createdAttendanceIds: json['created_attendance_ids'] != null
          ? List<int>.from(json['created_attendance_ids'])
          : [],
      updatedAttendanceIds: json['updated_attendance_ids'] != null
          ? List<int>.from(json['updated_attendance_ids'])
          : [],
    );
  }
}