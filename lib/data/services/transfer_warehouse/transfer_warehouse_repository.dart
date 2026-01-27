import 'dart:convert';

import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/transfer_warehouse/transfer_warehouse_model.dart';
import 'package:http/http.dart' as http;

class TransferWarehouseRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<TransferWarehouseModel>> fetchListTransferWarehouse({
    required String token,
  }) async {
    try {
      final uri = Uri.parse(
        "$baseUrl/fn/t_inventory_transfer_warehouse/getAll",
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
      print('📥 RAW RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            json.decode(response.body) as Map<String, dynamic>;

        // Ambil field "data" yang pasti List
        final List<dynamic> listData = jsonResponse['data'] as List<dynamic>;

        return listData.map((e) => TransferWarehouseModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load transfer warehouse');
      }
    } catch (e) {
      throw Exception('Failed to load transfer warehouse: $e');
    }
  }

  Future<TransferWarehouseModel> fetchDetailTransferWarehouse({
    required String token,
    required String id,
  }) async {
    try {
      final uri = Uri.parse(
        "$baseUrl/dynamic/t_inventory_transfer_warehouse/$id",
      ).replace(
        queryParameters: {
          'include': 't_inventory_transfer_warehouse_d,m_unit_bussiness,m_warehouse:id|name'
        }
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
      print('📥 RAW RESPONSE: ${response.body}');


      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            json.decode(response.body) as Map<String, dynamic>;

        return TransferWarehouseModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to load transfer warehouse');
      }
    } catch (e) {
      throw Exception('Failed to load transfer warehouse: $e');
    }
  }
}
