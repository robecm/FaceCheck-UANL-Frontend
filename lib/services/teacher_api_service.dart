import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import '../models/teacher/class/modify_class_request.dart';
import '../models/teacher/class/modify_class_response.dart';
import '../models/teacher/class/create_class_request.dart';
import '../models/teacher/class/create_class_response.dart';
import '../models/teacher/class/delete_class_response.dart';
import '../models/teacher/class/exams/retrieve_class_exams_response.dart';
import '../models/teacher/class/exams/create_class_exam_request.dart';
import '../models/teacher/class/exams/create_class_exam_response.dart';
import '../models/teacher/class/exams/update_class_exam_request.dart';
import '../models/teacher/class/exams/update_class_exam_response.dart';
import '../models/teacher/class/retrieve_class_students_response.dart';
import '../models/teacher/class/class_add_student_request.dart';
import '../models/teacher/class/class_add_student_response.dart';
import '../models/teacher/class/class_delete_student_request.dart';
import '../models/teacher/class/class_delete_student_response.dart';
import '../models/teacher/class/exams/delete_class_exam_response.dart';
import '../models/teacher/class/exams/retrieve_exam_results_response.dart';
import '../models/teacher/class/exams/modify_exam_results_request.dart';
import '../models/teacher/class/exams/modify_exam_results_response.dart';
import '../models/teacher/retrieve_teacher_assignments_response.dart';
import '../models/assignment/retrieve_assignment_evidences_response.dart';
import '../models/assignment/grade_assignment_evidence_request.dart';
import '../models/assignment/grade_assignment_evidence_response.dart';
import '../models/attendance/modify_attendance_request.dart';
import '../models/attendance/modify_attendance_response.dart';
import '../models/attendance/retrieve_class_attendance_request.dart';
import '../models/attendance/retrieve_class_attendance_response.dart';

class TeacherApiService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<List<Map<String, dynamic>>> retrieveTeacherClasses(int teacherId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/teacher/classes?teacher_id=$teacherId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonData['data']);
    } else {
      throw Exception("Failed to load the teacher's classes");
    }
  }

  Future<ModifyClassResponse> updateClass(ModifyClassRequest request) async {
    final url = Uri.parse('$_baseUrl/api/class/update');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    final jsonData = json.decode(response.body);
    return ModifyClassResponse.fromJson(jsonData);
  }

  Future<CreateClassResponse> createClass(CreateClassRequest request) async {
    final url = Uri.parse('$_baseUrl/api/class/register');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    final jsonData = json.decode(response.body);
    return CreateClassResponse.fromJson(jsonData);
  }

  Future<DeleteClassResponse> deleteClass(String classId) async {
    final url = Uri.parse('$_baseUrl/api/class/delete?class_id=$classId');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final jsonData = json.decode(response.body);
    return DeleteClassResponse.fromJson(jsonData);
  }

  Future<RetrieveClassExamsResponse> retrieveClassExams(int classId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/class/exams?class_id=$classId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return RetrieveClassExamsResponse.fromJson(jsonData);
    } else {
      final jsonData = json.decode(response.body);
      return RetrieveClassExamsResponse.fromJson(jsonData);
    }
  }

  Future<CreateClassExamResponse> createClassExam(CreateClassExamRequest request) async {
    final url = Uri.parse('$_baseUrl/api/exam/create');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return CreateClassExamResponse.fromJson(jsonData);
    } else {
      final jsonData = json.decode(response.body);
      return CreateClassExamResponse.fromJson(jsonData);
    }
  }

  Future<UpdateClassExamResponse> updateClassExam(UpdateClassExamRequest request) async {
    final url = Uri.parse('$_baseUrl/api/exam/update');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    final jsonData = json.decode(response.body);
    return UpdateClassExamResponse.fromJson(jsonData);
  }

  Future<RetrieveClassStudentsResponse> retrieveClassStudents(String classId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/class/students?class_id=$classId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return RetrieveClassStudentsResponse.fromJson(jsonData);
    } else {
      final jsonData = json.decode(response.body);
      return RetrieveClassStudentsResponse.fromJson(jsonData);
    }
  }

  Future<ClassAddStudentResponse> addStudentToClass(ClassAddStudentRequest request) async {
    final url = Uri.parse('$_baseUrl/api/class/add-student');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    final jsonData = json.decode(response.body);
    return ClassAddStudentResponse.fromJson(jsonData);
  }

  Future<ClassDeleteStudentResponse> deleteStudentFromClass(ClassDeleteStudentRequest request) async {
    final url = Uri.parse('$_baseUrl/api/class/delete-student?class_id=${request.classId}&student_id=${request.studentId}');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final jsonData = json.decode(response.body);
    return ClassDeleteStudentResponse.fromJson(jsonData);
  }

  Future<DeleteClassExamResponse> deleteClassExam(String examId) async {
    final url = Uri.parse('$_baseUrl/api/exam/delete?exam_id=$examId');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final jsonData = json.decode(response.body);
    return DeleteClassExamResponse.fromJson(jsonData);
  }

  Future<RetrieveExamResultsResponse> retrieveExamResults(String examId) async {
    final url = Uri.parse('$_baseUrl/api/exam/results?exam_id=$examId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final jsonData = json.decode(response.body);
    return RetrieveExamResultsResponse.fromJson(jsonData);
  }

  Future<ModifyExamResultsResponse> modifyExamResults(ModifyExamResultsRequest request) async {
    final url = Uri.parse('$_baseUrl/api/exam/modify-result');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    final jsonData = json.decode(response.body);
    return ModifyExamResultsResponse.fromJson(jsonData);
  }

  Future<RetrieveTeacherAssignmentsResponse> retrieveTeacherAssignments(int teacherId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/teacher/assignments?teacher_id=$teacherId'),
      headers: {'Content-Type': 'application/json'},
    );

    final jsonData = json.decode(response.body);
    return RetrieveTeacherAssignmentsResponse.fromJson(jsonData);
  }

  Future<RetrieveAssignmentEvidencesResponse> retrieveAssignmentEvidences(String assignmentId) async {
    final url = Uri.parse('$_baseUrl/api/assignment/evidence/list?assignment_id=$assignmentId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return RetrieveAssignmentEvidencesResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return RetrieveAssignmentEvidencesResponse(
        success: false,
        statusCode: 500,
        error: 'Failed to retrieve assignment evidences: $e',
      );
    }
  }

  Future<GradeAssignmentEvidenceResponse> gradeAssignmentEvidence({
    required String evidenceId,
    required double grade,
    String? feedback,
  }) async {
    const String endpoint = '/api/assignment/evidence/grade';
    final url = Uri.parse('$_baseUrl$endpoint');

    try {
      final request = GradeAssignmentEvidenceRequest(
        evidenceId: evidenceId,
        grade: grade,
        feedback: feedback,
      );

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      return GradeAssignmentEvidenceResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return GradeAssignmentEvidenceResponse(
        success: false,
        statusCode: 500,
        error: 'Failed to grade evidence: $e',
      );
    }
  }

  Future<ModifyAttendanceResponse> modifyAttendance(
    int classId,
    List<int> studentIds,
    bool present,
    {String? attendanceDate, String? attendanceTime}
  ) async {
    final url = Uri.parse('$_baseUrl/api/attendance/modify');

    // If no date is provided, use today's date in YYYY-MM-DD format
    final date = attendanceDate ??
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

    final request = ModifyAttendanceRequest(
      classId: classId,
      studentIds: studentIds,
      attendanceDate: date,
      attendanceTime: attendanceTime,
      present: present,
    );

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      return ModifyAttendanceResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return ModifyAttendanceResponse(
        success: false,
        statusCode: 500,
        error: 'Failed to modify attendance: $e',
      );
    }
  }

  Future<RetrieveClassAttendanceResponse> retrieveClassAttendance(String classId) async {
    final request = RetrieveClassAttendanceRequest(classId: classId);
    final queryParams = request.toQueryParameters();
    final url = Uri.parse('$_baseUrl/api/attendance/class').replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      return RetrieveClassAttendanceResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return RetrieveClassAttendanceResponse(
        success: false,
        statusCode: 500,
        error: 'Failed to retrieve class attendance: $e',
      );
    }
  }
}