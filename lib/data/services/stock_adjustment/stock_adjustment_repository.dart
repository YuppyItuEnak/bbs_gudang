import 'dart:convert';

import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/stock_adjustment/stock_adjustment_model.dart';
import 'package:http/http.dart' as http;

class StockAdjustmentRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<StockAdjustmentModel>> getStockAdjustments({
    required String token,
    int page = 1,
    int paginate = 10,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/dynamic/t_inventory_s_adjustment").replace(
        queryParameters: {
          "page": page.toString(),
          "paginate": paginate.toString(),
          "include":
              "t_inventory_s_adjustment_d,m_unit_bussiness:id|name,m_warehouse:id|name,t_inventory_s_opname:id|code,t_inventory_s_adjustment_approval:user_id|status,user_default:id|name",
          "selectfield":
              "id,code,date,unit_bussiness_id,warehouse_id,opname_id,notes,status,approved_count,approval_count,createdAt",
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
        throw Exception("Failed load stock adjustment");
      }

      final decoded = json.decode(response.body);
      print("fetch Data stock adjust: ${response.body}");
      final List data = decoded["data"];

      return data.map((e) => StockAdjustmentModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("StockAdjustment Error: $e");
    }
  }

  Future<StockAdjustmentModel> fetchDetailAdjustment({
    required String token,
    required String id,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/dynamic/t_inventory_s_adjustment/$id")
          .replace(
            queryParameters: {
              'include': {
                't_inventory_s_adjustment_d>t_inventory_s_adjustment,t_inventory_s_adjustment_d>m_item,t_inventory_s_adjustment_d>m_item_group,m_unit_bussiness,t_inventory_s_opname,m_warehouse,user_default,m_coa',
              },
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
        throw Exception("Failed load stock adjustment");
      }

      final decoded = json.decode(response.body);
      print("fetch detail Data stock adjust: ${response.body}");
      return StockAdjustmentModel.fromJson(decoded["data"]);
    } catch (e) {
      throw Exception("StockAdjustment Error: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchOpnameReferance({
    required String token,
    required String unitBusinessId,
    required String warehouseId,
  }) async {
    final uri = Uri.parse('$baseUrl/dynamic/t_inventory_s_opname').replace(
      queryParameters: {
        'include': 't_inventory_s_opname_d',
        'selectfield': 'id,code',
        'filter_column_status': 'POSTED',
        'filter_column_unit_bussiness_id': unitBusinessId,
        'filter_column_warehouse_id': warehouseId,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed load opname');
    }

    final body = json.decode(response.body);

    final List list = body['data'] ?? [];

    return list.map<Map<String, dynamic>>((e) {
      return {'id': e['id'], 'code': e['code']};
    }).toList();
  }

  Future<String> generateAdjustmentCode({required String token}) async {
    final uri = Uri.parse(
      '$baseUrl/fn/t_inventory_s_adjustment/generateCode?menu_id=4ad48011-9a08-4073-bde0-10f88bfebc81',
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    print("GEN CODE STATUS: ${response.statusCode}");
    print("GEN CODE BODY: ${response.body}");

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Gagal generate code');
    }

    return data['data']; // "ADJ-2602-0002"
  }

  Future<Map<String, dynamic>> checkCanSubmit({
    required String token,
    required String authUserId,
    required String menuId,
    String? unitBusinessId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/fn/t_inventory_s_adjustment_approval/checkCanSubmit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'auth_user_id': authUserId,
        'menu_id': menuId,
        'unit_bussiness_id': unitBusinessId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal cek approval');
    }

    return data;
  }

  Future<Map<String, dynamic>> createStockAdjustment({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/dynamic/t_inventory_s_adjustment/with-details'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");
    print("PAYLOAD SENT: ${jsonEncode(payload)}");

    final data = jsonDecode(response.body);

    // ❌ HANDLE HTTP ERROR BUT STILL READ MESSAGE
    if (response.statusCode != 200) {
      String message = data['message'] ?? "Server error ${response.statusCode}";

      // ✅ IF VALIDATION ERRORS EXIST
      if (data['errors'] != null && data['errors'] is Map) {
        final errors = data['errors'] as Map<String, dynamic>;

        final errorText = errors.entries
            .map((e) {
              final field = e.key;
              final msgs = (e.value as List).join(', ');
              return "$field: $msgs";
            })
            .join("\n");

        message = "$message\n$errorText";
      }

      throw Exception(message);
    }

    // ❌ HANDLE BUSINESS LOGIC ERROR
    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Gagal simpan stock adjustment');
    }

    return data['data'];
  }

  Future<Map<String, dynamic>> updateStockAdjustment({
    required String token,
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final uri = Uri.parse(
        "$baseUrl/dynamic/t_inventory_s_adjustment/with-details/$id",
      );

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['status'] == 'success') {
        return decoded['data'];
      }

      throw Exception(decoded['message'] ?? "Gagal update stock adjustment");
    } catch (e) {
      throw Exception("Update adjustment error: $e");
    }
  }
}
