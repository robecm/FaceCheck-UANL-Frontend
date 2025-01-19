import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class StudentApiService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<List<Map<String, dynamic>>> retrieveStudentClasses(int studentId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/retrieve-student-classes?student_id=$studentId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonData['data']);
    } else {
      throw Exception("Failed to load the student's classes");
    }
  }

  Future<List<Map<String, dynamic>>> retrieveStudentTeachers(int studentId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/retrieve-student-teachers?student_id=$studentId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonData['data']);
    } else {
      throw Exception("Failed to load the student's teachers");
    }
  }
}