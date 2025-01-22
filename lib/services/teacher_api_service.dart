import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import '../models/teacher/class/modify_class_request.dart';
import '../models/teacher/class/modify_class_response.dart';
import '../models/teacher/class/create_class_request.dart';
import '../models/teacher/class/create_class_response.dart';
import '../models/teacher/class/delete_class_response.dart';

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
}