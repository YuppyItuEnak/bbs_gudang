import 'dart:convert';

import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/delivery_plan/delivery_plan_code_model.dart';
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

      // 🧩 DEBUG FIELD
      debugPrint("🧩 SEMUA FIELD DATA:");
      data.forEach((key, value) {
        debugPrint("FIELD: $key => ${value.runtimeType}");
      });

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
}
