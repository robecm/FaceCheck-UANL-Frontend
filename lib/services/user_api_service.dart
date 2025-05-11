import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/signup/signup_response.dart';
import '../models/login/login_response.dart';
import '../models/signup/duplicate_response.dart';
import '../models/face/check_face_response.dart';
import '../models/face/check_face_request.dart';
import '../models/face/verify_face_response.dart';
import 'config.dart';

class ApiService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<LoginResponse> studentLogin(String matnum, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/login/student'),
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
        Uri.parse('$_baseUrl/api/login/teacher'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'worknum': worknum,
          'password': password,
        })
    );

    final jsonData = json.decode(response.body);
    return LoginResponse.fromJson(jsonData);
  }

  Future<SignupResponse> studentSignup(
      String name, String username, DateTime birthDate, String faculty,
      String matnum, String password, String faceImg, String email
      ) async {
     final response = await http.post(
      Uri.parse('$_baseUrl/api/signup/student'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'username': username,
        'birthdate': birthDate.toIso8601String(),
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
      Uri.parse('$_baseUrl/api/signup/student-duplicate'),
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
      Uri.parse('$_baseUrl/api/face/check-existing'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(CheckFaceRequest(img: base64Image).toJson()),
    );

    final jsonData = json.decode(response.body);
    return CheckFaceResponse.fromJson(jsonData);
  }

  Future<VerifyFaceResponse> verifyFace(String capFrame, String refFrame) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/face/verify'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'cap_frame': capFrame,
        'ref_frame': refFrame,
      }),
    );

    final jsonData = json.decode(response.body);
    return VerifyFaceResponse.fromJson(jsonData);
  }
}