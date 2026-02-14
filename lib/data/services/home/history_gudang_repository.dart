import 'dart:convert';
import 'dart:io';

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

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List rows = jsonResponse['data'];

      List<PengeluaranBarangModel> historyList = rows
          .where((e) {
            final dynamic status = e['status'];
            return status.toString() == "2";
          })
          .map<PengeluaranBarangModel>((e) {
            return PengeluaranBarangModel.fromJson(e);
          })
          .toList();

      historyList.sort((a, b) {
        return b.date.compareTo(a.date);
      });
      return historyList;
    } on SocketException {
      throw "Tidak ada koneksi internet. Silakan cek sinyal Anda.";
    } on HttpException {
      throw "Layanan tidak ditemukan.";
    } on FormatException {
      throw "Format data tidak sesuai.";
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
        debugPrint("Response Body: $body");

        if (body['status'] == 'success' && body['data'] is List) {
          final List rawList = body['data'];
          final pagination = body['pagination'];

          final List<PenerimaanBarangModel> items = rawList
              .where((e) => e['status']?.toString().toUpperCase() == 'POSTED')
              .map((e) => PenerimaanBarangModel.fromJson(e))
              .toList();

          items.sort((a, b) {
            final dateB = b.date ?? DateTime.now();
            final dateA = a.date ?? DateTime.now();

            return dateB.compareTo(dateA);
          });

          return {'data': items, 'pagination': pagination};
        }

        throw Exception('Format response tidak sesuai');
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
              'order_type': 'DESC',
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

      for (var element in rawData) {
        try {
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

      results.sort((StockAdjustmentModel a, StockAdjustmentModel b) {
        final DateTime dateB = DateTime.tryParse(b.date ?? "") ?? DateTime(0);
        final DateTime dateA = DateTime.tryParse(a.date ?? "") ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

      return results;
    } on SocketException {
      throw "Tidak ada koneksi internet. Silakan cek sinyal Anda.";
    } on HttpException {
      throw "Layanan tidak ditemukan.";
    } on FormatException {
      throw "Format data tidak sesuai.";
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
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List rows = jsonResponse['data'];

      List<StockOpnameModel> historyList = rows
          .where((e) => e['status']?.toString().toUpperCase() == 'POSTED')
          .map<StockOpnameModel>((e) => StockOpnameModel.fromJson(e))
          .toList();

      historyList.sort((a, b) {
        return b.date.compareTo(a.date);
      });
      return historyList;
    } on SocketException {
      throw "Tidak ada koneksi internet. Silakan cek sinyal Anda.";
    } on HttpException {
      throw "Layanan tidak ditemukan.";
    } on FormatException {
      throw "Format data tidak sesuai.";
    } catch (e) {
      rethrow;
    }
  }
}
