import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/signup_response.dart';
import '../models/login_response.dart';
import '../models/duplicate_response.dart';
import '../models/check_face_response.dart';
import '../models/check_face_request.dart';
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
    // Calculate the age
    final DateTime now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/student-signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': 'robe',
        'username': 'username',
        'age': 20, // Include the age instead of birthDate
        'faculty': 'faculty',
        'matnum': 2172148,
        'password': 'FIME123',
        'face_img': faceImg,
        'email': 'email@mail.com',
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

  Future<CheckFaceResponse> checkFace(String base64Image) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/check-face'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(CheckFaceRequest(img: base64Image).toJson()),
    );

    final jsonData = json.decode(response.body);
    return CheckFaceResponse.fromJson(jsonData);
  }
}