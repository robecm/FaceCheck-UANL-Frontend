import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_response.dart';
import 'config.dart';

class ApiService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<LoginResponse> studentLogin(String matnum, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/student-login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'matnum': matnum,
        'password': password,
      })
    );

    final jsonData = json.decode(response.body);
    return LoginResponse.fromJson(jsonData);
  }

  Future<LoginResponse> teacherLogin(String worknum, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/teacher-login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'worknum': worknum,
        'password': password,
      })
    );

    final jsonData = json.decode(response.body);
    return LoginResponse.fromJson(jsonData);
  }
}