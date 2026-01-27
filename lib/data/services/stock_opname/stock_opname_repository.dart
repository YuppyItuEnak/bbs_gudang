import 'dart:convert';
import 'dart:ffi';
import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/stock_opname/stock_opname_detail.dart';
import 'package:bbs_gudang/data/models/stock_opname/stock_opname_model.dart';
import 'package:http/http.dart' as http;

class StockOpnameRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<StockOpnameModel>> getStockOpnameReport({
    required String token,
    required String startDate,
    required String endDate,
    int page = 1,
    int limit = 100,
    List<String>? unitBusinessIds,
    List<String>? warehouseIds,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/dynamic/t_inventory_s_opname').replace(
        queryParameters: {
          'include': {
            't_inventory_s_opname_d,t_inventory_s_opname_d>m_item,m_warehouse,m_unit_bussiness,m_gen',
          },
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
        throw Exception('HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      print("📥 RAW RESPONSE: ${response.body}");

      /// ⬅️ INI KUNCI UTAMANYA
      final List listData = decoded['data'];

      return listData.map((e) => StockOpnameModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load stock opname report: $e');
    }
  }

  Future<StockOpnameModel> getStockOpnameDetailReport({
    required String token,
    required String opnameId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/dynamic/t_inventory_s_opname/$opnameId')
          .replace(
            queryParameters: {
              'id': opnameId,
              'limit': '100', // 🔥 ambil banyak sekalian
              'include': {
                't_inventory_s_opname_d>t_inventory_s_opname,t_inventory_s_opname_d>m_item,m_warehouse,m_unit_bussiness,m_gen',
              },
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
        throw Exception('Failed load opname detail');
      }

      final decoded = jsonDecode(response.body);

      return StockOpnameModel.fromJson(decoded['data']);
    } catch (e) {
      print('❌ ERROR FETCH DETAIL PENERIMAAN BARANG: $e');
      rethrow;
    }
  }
}
