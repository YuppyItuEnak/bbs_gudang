import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/auth/login_response_model.dart';
import '../../models/auth/user_model.dart';
import '../../../core/constants/api_constants.dart';

class AuthRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<LoginResponse> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final body = json.encode({'username': username, 'password': password});

    try {
      if (kDebugMode) {
        print('🔗 URL: $url');
        print('📦 Request body: $body');
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (kDebugMode) {
        print('📥 Response status: ${response.statusCode}');
        print('📥 Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final loginResponse = LoginResponse.fromJson(responseData);

        final user = await fetchUserDetails(
          loginResponse.user.id,
          loginResponse.token,
        );

        return LoginResponse(
          status: loginResponse.status,
          message: loginResponse.message,
          user: user,
          token: loginResponse.token,
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Login error: $e');
      }
      rethrow;
    }
  }

  Future<User> fetchUserDetails(String userId, String token) async {
    final url = Uri.parse(
      '$baseUrl/dynamic/user_default/$userId?include=user_detail',
    );

    try {
      if (kDebugMode) {
        print('🔗 Fetching user details from: $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('📥 User details response status: ${response.statusCode}');
        print('📥 User details response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final userData = responseData['data'];
          User user;
          if (userData is List) {
            if (userData.isNotEmpty) {
              user = User.fromJson(userData.first);
            } else {
              throw Exception('User data is an empty list.');
            }
          } else if (userData is Map<String, dynamic>) {
            user = User.fromJson(userData);
          } else {
            throw Exception('User data is not in the expected format.');
          }

          if (user.userMobile != true) {
            throw Exception(
              'user anda tidak diijinkan menggunakan aplikasi ini',
            );
          }

          return user;
        } else {
          throw Exception(
            'Failed to fetch user details: ${responseData['message']}',
          );
        }
      } else {
        throw Exception('Failed to fetch user details: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user details: $e');
      }
      rethrow;
    }
  }

  Future<bool> changePassword({
    required String userId,
    required String token,
    required String newPassword,
    required String currentPassword,
  }) async {
    final url = Uri.parse('$baseUrl/dynamic/user_default/$userId');
    final body = json.encode({
      'password': newPassword,
      // 'current_password': currentPassword,
    });

    try {
      if (kDebugMode) {
        print('🔗 Change password URL: $url');
        print('📦 Request body: $body');
      }

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (kDebugMode) {
        print('📥 Change password response status: ${response.statusCode}');
        print('📥 Change password response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        throw Exception('Failed to change password: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error changing password: $e');
      }
      throw Exception('Failed to change password: $e');
    }
  }

  Future<List<User>> fetchUserPIC({
    required String token,
    String? unitBusinessId,
  }) async {
    try {
      final params = <String, String>{
        'selectfield': 'id,name',
        'no_pagination': 'true',
      };
      if (unitBusinessId != null) params['unit_bussiness_id'] = unitBusinessId;

      final uri = Uri.parse("$baseUrl/dynamic/user_default").replace(
        queryParameters: params,
      );

      debugPrint('👤 FETCH USER PIC URI: $uri');

      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint('👤 FETCH USER PIC STATUS: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'];
        debugPrint('👤 FETCH USER PIC TOTAL: ${data.length}');
        debugPrint('👤 FETCH USER PIC DATA: $data');
        return data.map((e) => User.fromJson(e)).toList();
      } else {
        debugPrint('👤 FETCH USER PIC ERROR BODY: ${response.body}');
        throw Exception('Gagal mengambil data User PIC');
      }
    } catch (e) {
      debugPrint('👤 FETCH USER PIC EXCEPTION: $e');
      throw Exception('Gagal mengambil data User PIC');
    }
  }
}
