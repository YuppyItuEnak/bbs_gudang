import 'dart:convert';

import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/purchase_request/purchase_request_model.dart';
import 'package:http/http.dart' as http;

class PurchaseRequestRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<PurchaseRequestModel>> fetchListPR({
    required String token,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/dynamic/t_purchase_request").replace(
        queryParameters: {
          'include': 't_purchase_request_d>m_item,m_gen:id|value1',
          'no_pagination': 'true',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print("📥 STATUS: ${response.statusCode}");
        print("Response PR: ${response.body}");
        final List data = body['data'];
        return data.map((e) => PurchaseRequestModel.fromJson(e)).toList();
      } else {
        throw Exception('Gagal mengambil data Purchase Request');
      }
    } catch (e) {
      throw Exception('Gagal mengambil data Purchase Request: $e');
    }
  }
}
