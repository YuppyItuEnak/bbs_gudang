import 'dart:convert';

import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/pengeluaran_barang/pengeluaran_barang_model.dart';
import 'package:http/http.dart' as http;

class PengeluaranBarangRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<PengeluaranBarangModel>> fetchAllPengeluaranBrg({
    required String token,
  }) async {
    int page = 1;
    const int limit = 10; // backend paksa 10

    List<PengeluaranBarangModel> allData = [];

    while (true) {
      final uri = Uri.parse("$baseUrl/dynamic/t_surat_jalan").replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          'include':
              't_sales_order,m_unit_bussiness,m_customer,t_delivery_plan',
        },
      );

      print("🌐 FETCH PAGE $page → $uri");

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
      final List data = body['data'];

      allData.addAll(
        data.map((e) => PengeluaranBarangModel.fromJson(e)).toList(),
      );

      // 🔚 Jika data kurang dari limit → sudah page terakhir
      if (data.length < limit) break;

      page++;
    }

    print("🔥 TOTAL DATA TERAMBIL: ${allData.length}");

    return allData;
  }

  Future<PengeluaranBarangModel> fetchDetailPengeluaranBrg({
    required String token,
    required String id,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/dynamic/t_surat_jalan/$id").replace(
        queryParameters: {
          'include':
              't_surat_jalan_d,t_sales_order,m_customer,m_gen,m_unit_bussiness,t_surat_jalan_d>m_item',
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

      final data = body['data'];

      print("🧩 SEMUA FIELD DATA:");
      data.forEach((key, value) {
        print("FIELD: $key => ${value.runtimeType}");
      });

      return PengeluaranBarangModel.fromJson(body['data']);
    } catch (e) {
      throw Exception("PengeluaranBarang Error: $e");
    }
  }
}
