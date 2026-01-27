import 'dart:convert';

import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/home/history_gudang_model.dart';
import 'package:http/http.dart' as http;

class HistoryGudangRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<HistoryGudangModel>> fetchListHistoryGudang({
    required String token,

    // pagination
    int page = 1,
    int limit = 100,

    // filters
    List<int>? unitBusinessIds,
    List<int>? warehouseIds,
    List<int>? itemIds,
    String? startDate, // format: yyyy-mm-dd
    String? endDate, // format: yyyy-mm-dd
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // --- ARRAY FILTERS ---
      if (unitBusinessIds != null && unitBusinessIds.isNotEmpty) {
        for (var id in unitBusinessIds) {
          queryParams.putIfAbsent('unit_business_ids[]', () => []);
          (queryParams['unit_business_ids[]'] as List).add(id.toString());
        }
      }

      if (warehouseIds != null && warehouseIds.isNotEmpty) {
        for (var id in warehouseIds) {
          queryParams.putIfAbsent('warehouse_ids[]', () => []);
          (queryParams['warehouse_ids[]'] as List).add(id.toString());
        }
      }

      if (itemIds != null && itemIds.isNotEmpty) {
        for (var id in itemIds) {
          queryParams.putIfAbsent('item_ids[]', () => []);
          (queryParams['item_ids[]'] as List).add(id.toString());
        }
      }

      // --- DATE FILTER ---
      if (startDate != null && endDate != null) {
        queryParams['start_date'] = startDate;
        queryParams['end_date'] = endDate;
      }

      final uri =
          Uri.parse(
            "$baseUrl/fn/t_inventory_ledger/getInventoryLedgerDetailReport",
          ).replace(
            queryParameters: queryParams.map((key, value) {
              if (value is List) {
                return MapEntry(key, value);
              } else {
                return MapEntry(key, value.toString());
              }
            }),
          );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 LEDGER URI: $uri');
      print('📥 LEDGER STATUS: ${response.statusCode}');
      // print('📥 LEDGER BODY: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed get history gudang (${response.statusCode})');
      }

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      final List rows = jsonResponse['data']?['rows'] ?? [];

      return rows
          .map<HistoryGudangModel>((e) => HistoryGudangModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Error getHistoryGudang: $e');
    }
  }
}
