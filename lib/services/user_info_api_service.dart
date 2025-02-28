import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import '../models/user_info/retrieve_user_info_response.dart';
import '../models/user_info/modify_user_info_request.dart';
import '../models/user_info/modify_user_info_response.dart';

class UserInfoApiService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<RetrieveUserInfoResponse> getUserInfo({
    required int userId,
    required String userType,
  }) async {
    final url = Uri.parse('$_baseUrl/api/user/info?user_id=$userId&user_type=$userType');
    debugPrint('Making API request to: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('API response status code: ${response.statusCode}');
      debugPrint('API response body: ${response.body}');

      final jsonData = json.decode(response.body);
      debugPrint('Decoded JSON: $jsonData');

      return RetrieveUserInfoResponse.fromJson(jsonData);
    } catch (e, stackTrace) {
      debugPrint('Error in getUserInfo: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<ModifyUserInfoResponse> modifyUserInfo(ModifyUserInfoRequest request) async {
    final url = Uri.parse('$_baseUrl/api/user/modify');
    debugPrint('Making API request to: $url');
    debugPrint('Request body: ${jsonEncode(request.toJson())}');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      debugPrint('API response status code: ${response.statusCode}');
      debugPrint('API response body: ${response.body}');

      final jsonData = json.decode(response.body);
      debugPrint('Decoded JSON: $jsonData');

      return ModifyUserInfoResponse.fromJson(jsonData);
    } catch (e, stackTrace) {
      debugPrint('Error in modifyUserInfo: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}