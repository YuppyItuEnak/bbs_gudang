import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/stock_opname/stock_opname_detail.dart';
import 'package:bbs_gudang/data/models/stock_opname/stock_opname_model.dart';
import 'package:flutter/material.dart';
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
          'include': 'm_unit_bussiness,m_warehouse',
          'no_pagination': 'true',
          'order_by': 'date',
          'order_type': 'DESC',
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

      final decoded = jsonDecode(response.body);
      print("📥 RAW RESPONSE: ${response.body}");

      /// ⬅️ INI KUNCI UTAMANYA
      final List listData = decoded['data'];

      return listData.map((e) => StockOpnameModel.fromJson(e)).toList();
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

      final decoded = jsonDecode(response.body);

      return StockOpnameModel.fromJson(decoded['data']);
    } on SocketException {
      throw "Tidak ada koneksi internet. Silakan cek sinyal Anda.";
    } on HttpException {
      throw "Layanan tidak ditemukan.";
    } on FormatException {
      throw "Format data tidak sesuai.";
    } catch (e) {
      print('❌ ERROR FETCH DETAIL PENERIMAAN BARANG: $e');
      rethrow;
    }
  }

  Future<StockOpnameModel> createStockOpname({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse('$baseUrl/dynamic/t_inventory_s_opname/with-details');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    debugPrint('STATUS CODE: ${response.statusCode}');
    debugPrint('RESPONSE BODY: ${response.body}');

    final json = jsonDecode(response.body);

    // 1. Handle Error (Bukan 200/201)
    if (response.statusCode != 200 && response.statusCode != 201) {
      if (json is Map<String, dynamic>) {
        // A. Parsing Error Validasi per Field (Laravel/Express style)
        if (json['errors'] != null && json['errors'] is Map) {
          final errors = json['errors'] as Map<String, dynamic>;
          final List<String> errorMessages = [];

          errors.forEach((field, msgs) {
            if (msgs is List && msgs.isNotEmpty) {
              errorMessages.add(
                _formatValidationError(field, msgs.first.toString()),
              );
            }
          });

          if (errorMessages.isNotEmpty) throw errorMessages.join("\n");
        }

        // B. Parsing Pesan Umum dari Backend
        if (json['message'] != null) {
          throw _parseGeneralError(json['message']);
        }
      }

      throw "Gagal menyimpan stock opname (${response.statusCode})";
    }

    return StockOpnameModel.fromJson(json['data']); // ✅ FIX
  }

  Future<String> generateStockOpnameCode({required String token}) async {
    final uri = Uri.parse(
      '$baseUrl/fn/t_inventory_s_opname/generateCode'
      '?menu_id=a26cd3a8-c455-478d-a1ed-5f2625826686',
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

    return json['data']; // ✅ OPC-2601-0006
  }

  Future<Map<String, dynamic>> updateStckOpname({
    required String token,
    required String opnameId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final uri = Uri.parse(
        "$baseUrl/dynamic/t_inventory_s_opname/with-details/$opnameId",
      );
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      final responseData = jsonDecode(response.body);

      // Cek apakah response sukses (status 200 atau 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      }

      // 2. Jika Gagal, Parsing Error
      if (responseData is Map<String, dynamic>) {
        // A. Cek Error Validasi per Baris (contoh: qty_physic kosong)
        if (responseData['errors'] != null && responseData['errors'] is Map) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          final List<String> errorMessages = [];

          errors.forEach((field, msgs) {
            if (msgs is List && msgs.isNotEmpty) {
              errorMessages.add(
                _formatValidationError(field, msgs.first.toString()),
              );
            }
          });

          if (errorMessages.isNotEmpty) throw errorMessages.join("\n");
        }

        // B. Cek Pesan Umum (contoh: Periode sudah ditutup)
        if (responseData['message'] != null) {
          throw _parseGeneralError(responseData['message']);
        }
      }

      // Fallback berdasarkan status code
      if (response.statusCode == 401) {
        throw "Sesi telah berakhir, silakan login ulang.";
      }
      if (response.statusCode >= 500) throw "Terjadi gangguan pada server.";

      throw "Gagal memperbarui data opname (${response.statusCode})";
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

  String _parseGeneralError(String msg) {
    final lowMsg = msg.toLowerCase();

    if (lowMsg.contains('period closed')) {
      return "Periode opname sudah ditutup.";
    }
    if (lowMsg.contains('unauthorized')) {
      return "Sesi habis, silakan login kembali.";
    }
    if (lowMsg.contains('already exists')) {
      return "Data opname untuk gudang ini sudah ada.";
    }
    if (lowMsg.contains('locked')) {
      return "Data sedang dikunci oleh proses lain.";
    }

    return msg;
  }

  String _formatValidationError(String field, String originalMessage) {
    final Map<String, String> fieldNames = {
      'warehouse_id': 'Gudang',
      'transaction_date': 'Tanggal Opname',
      'notes': 'Keterangan',
      'item_id': 'Barang',
      'qty_physic': 'Jumlah Fisik', // Field khusus Opname
      'qty_book': 'Jumlah Buku/Sistem', // Field khusus Opname
      'uom_id': 'Satuan',
    };

    // Menangani error detail barang (details.0.qty_physic)
    if (field.contains('details.')) {
      final parts = field.split('.');
      final index = int.tryParse(parts[1]) ?? 0;
      final detailField = parts.last;
      final humanField = fieldNames[detailField] ?? detailField;
      return "Baris ke-${index + 1} ($humanField): ${originalMessage.toLowerCase()}";
    }

    return "${fieldNames[field] ?? field}: ${originalMessage.toLowerCase()}";
  }
}
