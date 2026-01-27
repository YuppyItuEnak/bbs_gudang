import 'dart:convert';

import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/list_item/list_item_model.dart';
import 'package:http/http.dart' as http;

class ItemBarangRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<Map<String, dynamic>> fetchListBarang({
    required String token,
    int page = 1,

    // FILTER
    String? filterCode,
    String? filterName,
    String? filterStatus,
    String? itemType,
    String? itemGroup,
    String? itemDivision,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/dynamic/m_item").replace(
        queryParameters: {
          'page': page.toString(),
          'limit': '10', // backend FIX 10

          if (filterCode != null && filterCode.isNotEmpty)
            'filter_code': filterCode,

          if (filterName != null && filterName.isNotEmpty)
            'filter_name': filterName,

          if (filterStatus != null && filterStatus.isNotEmpty)
            'filter_status': filterStatus,

          if (itemType != null && itemType.isNotEmpty) 'item_type': itemType,

          if (itemGroup != null && itemGroup.isNotEmpty)
            'item_group': itemGroup,

          if (itemDivision != null && itemDivision.isNotEmpty)
            'item_division': itemDivision,
        },
      );

      print("FETCH URL: $uri");

      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode != 200) {
        throw Exception("HTTP ${response.statusCode}");
      }

      final body = jsonDecode(response.body);

      final List list = body['data'];
      final pagination = body['pagination'];

      return {
        "items": list.map((e) => ItemBarangModel.fromJson(e)).toList(),
        "pagination": pagination,
      };
    } catch (e) {
      throw Exception("Fetch Item Error: $e");
    }
  }
}
