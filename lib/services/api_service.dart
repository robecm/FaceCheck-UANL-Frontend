import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/signup_response.dart';
import '../models/login_response.dart';
import '../models/duplicate_response.dart';
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

  Future<SignupResponse> studentSignup(String name, String username, DateTime birthDate, String faculty, String matnum, String password, String faceImg, String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/student-signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'username': username,
        'birthDate': birthDate.toIso8601String(),
        'faculty': faculty,
        'matnum': matnum,
        'password': password,
        'face_img': faceImg,
        'email': email,
      })
    );

    final jsonData = json.decode(response.body);
    return SignupResponse.fromJson(jsonData);
  }

  Future<DuplicateResponse> checkDuplicate(String email, String matnum, String username) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/check-duplicate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'matnum': matnum,
        'username': username,
      })
    );

    final jsonData = json.decode(response.body);
    return DuplicateResponse.fromJson(jsonData);
  }
}