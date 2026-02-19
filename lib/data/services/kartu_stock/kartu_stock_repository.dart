import 'dart:convert';
import 'dart:io';

import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/kartu_stock/kartu_stock_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class KartuStockRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<KartuStockModel>> fetchRecapStock({
    required String token,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final uri =
          Uri.parse(
            "$baseUrl/fn/t_inventory_ledger/getInventoryLedgerDetailReport",
          ).replace(
            queryParameters: {
              'start_date': startDate,
              'end_date': endDate,
              'limit': '100',
            },
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
        debugPrint('✅ Response Body: $body');

        if (body['success'] == true &&
            body['data'] != null &&
            body['data']['rows'] is List) {
          final List listData = body['data']['rows'];
          return listData.map((e) => KartuStockModel.fromJson(e)).toList();
        }

        throw 'Format data rows tidak ditemukan';
      } else {
        String errorMessage = "Gagal memuat data (${response.statusCode})";
        try {
          final Map<String, dynamic> errorBody = json.decode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          if (response.statusCode == 401) {
            errorMessage = "Sesi telah berakhir, silakan login ulang.";
          }
          if (response.statusCode >= 500) {
            errorMessage = "Terjadi gangguan pada server.";
          }
        }
        throw errorMessage;
      }
    } on SocketException {
      throw "Tidak ada koneksi internet. Silakan cek sinyal Anda.";
    } on HttpException {
      throw "Layanan tidak ditemukan.";
    } on FormatException {
      throw "Format data tidak sesuai.";
    } catch (e) {
      debugPrint('❌ ERROR FETCH PENERIMAAN BARANG: $e');
      rethrow;
    }
  }
}
