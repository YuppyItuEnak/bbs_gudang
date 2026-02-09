import 'dart:convert';

import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/home/history_gudang_model.dart';
import 'package:bbs_gudang/data/models/penerimaan_barang/penerimaan_barang_model.dart';
import 'package:bbs_gudang/data/models/pengeluaran_barang/pengeluaran_barang_model.dart';
import 'package:bbs_gudang/data/models/stock_adjustment/stock_adjustment_model.dart';
import 'package:bbs_gudang/data/models/stock_opname/stock_opname_model.dart';
import 'package:flutter/material.dart';
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
      print('📥 LEDGER BODY: ${response.body}');

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (response.statusCode != 200) {
        throw Exception(jsonResponse['message'] ?? 'Unknown error');
      }

      final List rows = jsonResponse['data']?['rows'] ?? [];

      return rows
          .map<HistoryGudangModel>((e) => HistoryGudangModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PengeluaranBarangModel>> fetchPengeluaranBarangHistory({
    required String token,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/dynamic/t_surat_jalan").replace(
        queryParameters: {'order_by': 'created_by', 'no_pagination': 'true'},
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Unknown error');
      }

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List rows = jsonResponse['data'];

      return rows
          .where((e) {
            final dynamic status = e['status'];
            // Cek apakah status adalah int 2 atau string "2"
            return status.toString() == "2";
          })
          .map<PengeluaranBarangModel>((e) {
            return PengeluaranBarangModel.fromJson(e);
          })
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchPenerimaanBarangHistory({
    required String token,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/dynamic/t_penerimaan_barang").replace(
        queryParameters: {'order_by': 'createdBy', 'no_pagination': 'true'},
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['status'] == 'success' && body['data'] is List) {
          final List rawList = body['data'];
          final pagination = body['pagination'];

          // 🔥 FILTER: Hanya ambil data yang statusnya 'POSTED'
          // Gunakan .where sebelum .map untuk efisiensi
          final items = rawList
              .where((e) => e['status']?.toString().toUpperCase() == 'POSTED')
              .map((e) => PenerimaanBarangModel.fromJson(e))
              .toList();

          return {'data': items, 'pagination': pagination};
        }

        throw Exception('Format response tidak sesuai');
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StockAdjustmentModel>> fetchStkAdjustHistory({
    required String token,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/dynamic/t_inventory_s_adjustment")
          .replace(
            queryParameters: {
              'order_by': 'submitted_by',
              'no_pagination': 'true',
            },
          );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final decoded = json.decode(response.body);
        throw Exception(decoded['message'] ?? 'Unknown error');
      }

      final decoded = json.decode(response.body);

      final dynamic rawData = decoded["data"];
      if (rawData == null || rawData is! List) {
        return [];
      }

      final List<StockAdjustmentModel> results = [];

      // Gunakan loop biasa untuk mempermudah debugging
      for (var element in rawData) {
        try {
          // 🔥 TAMBAHKAN FILTER STATUS DI SINI
          final String status = element['status']?.toString() ?? "";

          if (status == "APPROVED" || status == "IN_APPROVAL") {
            results.add(StockAdjustmentModel.fromJson(element));
          }
        } catch (e) {
          debugPrint("❌ Gagal memproses satu item Adjustment: $e");
          debugPrint("Data item bermasalah: $element");
          continue;
        }
      }

      return results;
    } catch (e) {
      debugPrint("❌ Error in fetchStkAdjustHistory: $e");
      rethrow;
    }
  }

  Future<List<StockOpnameModel>> fetchStkOpnameHistory({
    required String token,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/dynamic/t_inventory_s_opname").replace(
        queryParameters: {'order_by': 'submitted_by', 'no_pagination': 'true'},
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Unknown error');
      }

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List rows = jsonResponse['data'];

      return rows
          .where((e) => e['status']?.toString().toUpperCase() == 'POSTED')
          .map<StockOpnameModel>((e) => StockOpnameModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
