import 'dart:convert';

import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/delivery_plan/delivery_plan_code_model.dart';
import 'package:bbs_gudang/data/models/delivery_plan/request_delivery_plan.dart';
import 'package:bbs_gudang/data/models/pengeluaran_barang/pengeluaran_barang_model.dart';
import 'package:flutter/material.dart';
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
          'order_by': 'date',
          'order_type': 'DESC',
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

      // 🔴 HTTP ERROR
      if (response.statusCode != 200) {
        throw Exception(
          "HTTP ERROR ${response.statusCode} | BODY: ${response.body}",
        );
      }

      final body = jsonDecode(response.body);

      // 🔴 FORMAT RESPONSE SALAH
      if (body == null || body['data'] == null) {
        throw Exception("RESPONSE INVALID: ${response.body}");
      }

      final data = body['data'];
      debugPrint("Detail Pengeluaran Barang: $data");

      // 🧩 DEBUG FIELD
      // debugPrint("🧩 SEMUA FIELD DATA:");
      // data.forEach((key, value) {
      //   debugPrint("FIELD: $key => ${value.runtimeType}");
      // });

      // 🔴 ERROR PARSING MODEL
      try {
        return PengeluaranBarangModel.fromJson(data);
      } catch (e, stack) {
        debugPrint("❌ ERROR PARSE MODEL");
        debugPrint(stack.toString());
        throw Exception("PARSE MODEL ERROR: $e");
      }
    } catch (e, stack) {
      debugPrint("🔥 FETCH DETAIL PENGELUARAN ERROR");
      debugPrint("MESSAGE: $e");
      debugPrint(stack.toString());

      // lempar ulang supaya UI/provider tau ada error
      rethrow;
    }
  }

  Future<List<DeliveryPlanCodeModel>> fetchDeliveryPlanCode({
    required String token,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/dynamic/t_delivery_plan").replace(
        queryParameters: {
          'selectfield': 'id,code',
          'no_pagination': 'true',
          'include': 'm_vehicle,m_unit_bussiness,m_delivery_area,m_gen',
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
        throw Exception("HTTP ${response.statusCode} | ${response.body}");
      }

      final body = jsonDecode(response.body);
      print('📥 RESPONSE fetch DP Code: $body');

      if (body == null || body['data'] == null) {
        throw Exception("FORMAT RESPONSE TIDAK VALID");
      }

      final List list = body['data'];

      return list.map((e) => DeliveryPlanCodeModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data Delivery Plan Code: $e');
    }
  }

  Future<DeliveryPlanCodeModel> fetchDetailDeliveryPlanCode({
    required String token,
    required String id,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/dynamic/t_delivery_plan/$id").replace(
        queryParameters: {
          'include':
              't_delivery_plan_d>t_delivery_plan_d_item>m_item,'
              't_delivery_plan_d>t_sales_order>m_gen,'
              't_delivery_plan_d>t_sales_order>t_sales_order_d,'
              't_delivery_plan_d>m_customer>m_customer_group,'
              't_delivery_plan_d>t_delivery_plan_d_item>m_gen,'
              'm_vehicle,m_unit_bussiness',
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
        throw Exception("HTTP ${response.statusCode} | ${response.body}");
      }

      final body = jsonDecode(response.body);
      print('📥 RESPONSE fetch DP Code Detail: $body');

      if (body == null || body['data'] == null) {
        throw Exception("FORMAT RESPONSE TIDAK VALID");
      }

      final data = body['data'];

      // ✅ HANDLE LIST RESPONSE
      if (data is List) {
        if (data.isEmpty) {
          throw Exception("Data Delivery Plan kosong");
        }
        return DeliveryPlanCodeModel.fromJson(data.first);
      }

      // ✅ HANDLE OBJECT RESPONSE
      if (data is Map<String, dynamic>) {
        return DeliveryPlanCodeModel.fromJson(data);
      }

      throw Exception("Format data Delivery Plan tidak dikenali");
    } catch (e) {
      throw Exception('Gagal mengambil data Delivery Plan Code: $e');
    }
  }

  Future<String> generateNoDO({
    required String token,
    required String unitBusinessId,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/fn/t_surat_jalan/generateCode").replace(
        queryParameters: {
          'menu_id': 'b5d79799-51d1-4089-bc2e-71916b00200f',
          'unit_bussiness_id': unitBusinessId,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('GENERATE CODE STATUS: ${response.statusCode}');
      debugPrint('GENERATE CODE BODY: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('HTTP Error ${response.statusCode}');
      }

      final json = jsonDecode(response.body);

      // ✅ FIX SESUAI RESPONSE BACKEND
      if (json['success'] != true) {
        throw Exception(json['message'] ?? 'Generate code error');
      }

      return json['data'];
    } catch (e) {
      throw Exception('Generate code error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> createPengeluaranBarang({
    required String token,
    required SuratJalanRequestModel payload,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/fn/t_surat_jalan/createSuratJalanv3");

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload.toJson()),
      );

      // === LOG DEBUG (boleh dihapus nanti)
      debugPrint("🧪 CREATE SJ STATUS: ${response.statusCode}");
      debugPrint("🧪 CREATE SJ BODY: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Gagal menyimpan Pengeluaran Barang',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded['data'] == null || decoded['data'] is! List) {
        throw Exception('Format response tidak valid');
      }

      return List<Map<String, dynamic>>.from(decoded['data']);
    } catch (e) {
      throw Exception('Gagal menyimpan Pengeluaran Barang: $e');
    }
  }
}
