import 'dart:convert';

import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/list_item/list_item_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ItemBarangRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<Map<String, dynamic>> fetchListBarang({
    required String token,
    int page = 1,
    String? warehouseId,
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
          'filter_column_is_active': 'true',

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

      print("Fetch body: $body");

      final List list = body['data'];
      final pagination = body['pagination'];

      final items = list.map((e) => ItemBarangModel.fromJson(e)).toList();
      Map<String, double> stocks = {};
      if (items.isNotEmpty && warehouseId != null) {
        debugPrint("Fetching stocks for warehouseId: $warehouseId");
        final List<String> itemIds = items.map((item) => item.id!).toList();

        stocks = await getStockItem(
          token: token,
          itemIds: itemIds,
          warehouseId: warehouseId, // Hapus tanda '!' di sini
        );
      } else if(warehouseId == null) {
        debugPrint("warehouseId is null");
      } else{
        debugPrint("Skipping stock fetch: items list is empty");
      }

      return {
        "items": list.map((e) => ItemBarangModel.fromJson(e)).toList(),
        "pagination": pagination,
        "stocks": stocks,
      };
    } catch (e) {
      throw Exception("Fetch Item Error: $e");
    }
  }

  Future<Map<String, double>> getStockItem({
    required String token,
    required List<String> itemIds,
    required String warehouseId,
  }) async {
    try {
      debugPrint(
        "Fetching stock for items: $itemIds in warehouse: $warehouseId",
      );
      final String itemsParam = itemIds.join(',');

      final uri = Uri.parse("$baseUrl/fn/t_inventory_ledger/getItemStock")
          .replace(
            queryParameters: {"items": itemsParam, "warehouse_id": warehouseId},
          );

      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        debugPrint("Stock API Response: $decodedData");

        if (decodedData['message'] == "ok") {
          // Ambil object "data"
          final Map<String, dynamic> stockData = decodedData['data'] ?? {};

          // Ubah menjadi Map<String, double> agar mudah dipakai
          return stockData.map((key, value) {
            // key adalah "40da3344-...", value adalah -10
            return MapEntry(key, (value as num).toDouble());
          });
        } else {
          throw Exception(
            decodedData['message'] ?? "Gagal mengambil data stok",
          );
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error getStockItem: $e");
      // Kembalikan Map kosong agar aplikasi tidak crash
      return {};
    }
  }
}
