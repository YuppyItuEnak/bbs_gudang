import 'dart:convert';

import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/penerimaan_barang/penerimaan_barang_model.dart';
import 'package:http/http.dart' as http;

class PenerimaanBarangRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<Map<String, dynamic>> fetchPenerimaanBarang({
    required String token,
    int page = 1,
    int paginate = 10,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'include':
            'm_gen,m_supplier,m_unit_bussiness,t_purchase_order>t_purchase_request',
        'page': page.toString(),
        'paginate': paginate.toString(),
      };

      final uri = Uri.parse(
        '$baseUrl/dynamic/t_penerimaan_barang',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 STATUS: ${response.statusCode}');
      print('📥 RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['status'] == 'success' && body['data'] is List) {
          final List list = body['data'];
          final pagination = body['pagination'];

          final items = list
              .map((e) => PenerimaanBarangModel.fromJson(e))
              .toList();

          return {'data': items, 'pagination': pagination};
        }

        throw Exception('Format response tidak sesuai');
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR FETCH PENERIMAAN BARANG: $e');
      rethrow;
    }
  }

  Future<PenerimaanBarangModel> fetchDetailPenerimaanBarang({
    required String token,
    required String id,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/dynamic/t_penerimaan_barang/$id').replace(
        queryParameters: {
          'include':
              't_penerimaan_barang_d,m_gen,t_penerimaan_barang_d>m_item,t_penerimaan_barang_d>t_purchase_request_d,t_penerimaan_barang_d>t_purchase_order_d',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 DETAIL STATUS: ${response.statusCode}');
      print('📥 DETAIL RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['status'] == 'success' && body['data'] is Map) {
          return PenerimaanBarangModel.fromJson(body['data']);
        }

        throw Exception('Format response detail tidak sesuai');
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR FETCH DETAIL PENERIMAAN BARANG: $e');
      rethrow;
    }
  }
}
