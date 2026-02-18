import 'dart:convert';

import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/notification/notification_model.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

class NotificationRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<NotificationModel>> fetchNotifications({
    required String token, required String userId,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/fn/notifications/getFiveUnreadNotification',
      ).replace(queryParameters: {'auth_user_id': userId});
      debugPrint("Full URL: ${uri.toString()}");

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // 2. Cek status code
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);

        debugPrint("Notification Response: $decodedData");

        // 3. Validasi field "success" dari response body
        if (decodedData['success'] == true) {
          final List<dynamic> notificationsJson = decodedData['data'];

          // 4. Map JSON ke List of NotificationModel
          return notificationsJson
              .map((item) => NotificationModel.fromJson(item))
              .toList();
        } else {
          throw Exception(
            decodedData['message'] ?? 'Gagal mengambil notifikasi',
          );
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
