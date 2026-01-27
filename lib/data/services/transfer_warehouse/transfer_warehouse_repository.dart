import 'dart:convert';

import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/transfer_warehouse/company_warehouse_model.dart';
import 'package:bbs_gudang/data/models/transfer_warehouse/transfer_company_model.dart';
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

      print('📥 URI: $uri');
      print('📥 STATUS: ${response.statusCode}');
      print('📥 RAW RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            json.decode(response.body) as Map<String, dynamic>;

        final data = jsonResponse['data'];

        // Debug tambahan: cek null atau tipe data
        if (data == null) {
          print('⚠️ Data is null');
          return [];
        }
        if (data is! List) {
          print('⚠️ Data is not a List, type: ${data.runtimeType}');
          return [];
        }

        final List<dynamic> listData = data;

        // Debug setiap element
        for (int i = 0; i < listData.length; i++) {
          final element = listData[i];
          if (element == null) {
            print('⚠️ Element at index $i is null');
          } else if (element is! Map<String, dynamic>) {
            print(
              '⚠️ Element at index $i is not a Map<String,dynamic>, type: ${element.runtimeType}',
            );
          }
        }

        // Safe mapping
        return listData
            .where((e) => e != null && e is Map<String, dynamic>)
            .map(
              (e) => TransferWarehouseModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to load transfer warehouse, code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ ERROR FETCH Transfer Warehouse: $e');
      throw Exception('Failed to load transfer warehouse: $e');
    }
  }

  Future<TransferWarehouseModel> fetchDetailTransferWarehouse({
    required String token,
    required String id,
  }) async {
    try {
      final uri =
          Uri.parse(
            "$baseUrl/dynamic/t_inventory_transfer_warehouse/$id",
          ).replace(
            queryParameters: {
              'include':
                  't_inventory_transfer_warehouse_d,m_unit_bussiness,m_warehouse:id|name',
            },
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

  Future<List<TransferCompanyModel>> fetchUserCompanies({
    required String token,
    required String userId,
    required String responsibilityId,
  }) async {
    final uri = Uri.parse("$baseUrl/fn/user_detail/getUserCompanies").replace(
      queryParameters: {
        "user_id": userId,
        "responsibility_id": responsibilityId,
      },
    );

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
    print("User Company: $body");
    final List list = body['data'];

    return list.map((e) => TransferCompanyModel.fromJson(e)).toList();
  }

  Future<List<CompanyWarehouseModel>> fetchListWarehouse({
    required String token,
    required String unitBusinessId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/dynamic/m_warehouse'
      '?selectfield=id,unit_bussiness_id,name'
      '&filter_column_unit_bussiness_id=$unitBusinessId',
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('WAREHOUSE STATUS: ${response.statusCode}');
    print('WAREHOUSE BODY: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to load warehouse');
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    final List list = json['data'];

    return list.map((e) => CompanyWarehouseModel.fromJson(e)).toList();
  }

  Future<void> saveTransferWarehouse({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
     final url = Uri.parse(
      '$baseUrl/fn/t_inventory_transfer_warehouse/saveTransaction',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal menyimpan transfer warehouse: ${response.body}',
      );
    }
  }
}
