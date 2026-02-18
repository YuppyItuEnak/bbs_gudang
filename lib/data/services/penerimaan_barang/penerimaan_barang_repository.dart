import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/penerimaan_barang/available_po_model.dart';
import 'package:bbs_gudang/data/models/penerimaan_barang/penerimaan_barang_model.dart';
import 'package:flutter/material.dart';
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
            'm_gen:id|value1,m_supplier:id|name|is_pajak,m_unit_bussiness:id|name,t_purchase_order>t_purchase_request',
        'page': page.toString(),
        'paginate': paginate.toString(),
        'order_by_raw': 'createdAt DESC',
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

  Future<PenerimaanBarangModel> fetchDetailPenerimaanBarang({
    required String token,
    required String id,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/dynamic/t_penerimaan_barang/$id').replace(
        queryParameters: {
          'include':
              't_penerimaan_barang_d,m_gen,t_penerimaan_barang_d>m_item,t_penerimaan_barang_d>t_purchase_request_d,t_penerimaan_barang_d>t_purchase_order_d,m_warehouse:id|name',
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

        if (body['status'] == 'success' && body['data'] is Map) {
          return PenerimaanBarangModel.fromJson(body['data']);
        }

        throw Exception('Format response detail tidak sesuai');
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
      debugPrint('❌ ERROR FETCH DETAIL PENERIMAAN BARANG: $e');
      rethrow;
    }
  }

  Future<List<AvailablePoModel>> fetchListPO({required String token}) async {
    try {
      final uri = Uri.parse(
        "$baseUrl/fn/t_penerimaan_barang/getAvailablePos",
      ).replace(queryParameters: {'no_pagination': 'true'});

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print("response body PO: $body");
        final List data = body['data'];
        print("total PO: ${data.length}");
        return data.map((e) => AvailablePoModel.fromJson(e)).toList();
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

  Future<Map<String, dynamic>> fetchPoDetail({
    required String token,
    required String poId,
  }) async {
    final uri = Uri.parse('$baseUrl/dynamic/t_purchase_order/$poId').replace(
      queryParameters: {
        'include':
            'm_gen:id|value1,'
            'm_supplier:id|name|is_pajak,'
            'm_unit_bussiness:id|name,'
            't_purchase_order_d>t_purchase_request,'
            't_purchase_order_d>t_purchase_request_d,'
            'm_item_group:id|name',
      },
    );

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    final body = jsonDecode(res.body);
    debugPrint('Penerimaan Barang DETAIL RESPONSE: $body');
    return body['data'];
  }

  Future<Map<String, dynamic>> fetchAvailablePBDetails({
    required String token,
    required String purchaseOrderId,
    int page = 1,
    int limit = 10,
  }) async {
    final uri =
        Uri.parse(
          '$baseUrl/fn/t_penerimaan_barang_d/getAvailablePBDetails',
        ).replace(
          queryParameters: {
            'purchase_order_id': purchaseOrderId,
            'page': page.toString(),
            'paginate': limit.toString(),
            'include':
                't_purchase_order,'
                't_purchase_order_d,'
                't_purchase_request,'
                't_purchase_request_d,'
                'm_item,'
                'm_item_group,'
                'm_unit',
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
      throw Exception('Failed fetch PB details (${response.statusCode})');
    }

    final body = jsonDecode(response.body);

    return body;
  }

  Future<PenerimaanBarangModel> createPenerimaanBarang({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse('$baseUrl/dynamic/t_penerimaan_barang/with-details');

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

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = "Gagal menyimpan penerimaan barang";

      if (json is Map<String, dynamic>) {
        // A. Cek Error Validasi (Laravel/Express style)
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

        // B. Cek Pesan General dari Backend
        if (json['message'] != null) {
          throw _parseGeneralError(json['message']);
        }
      }

      // Fallback error standard
      if (response.statusCode == 401) {
        throw "Sesi berakhir, silakan login ulang.";
      }
      throw "$errorMessage (${response.statusCode})";
    }

    return PenerimaanBarangModel.fromJson(json['data']); // ✅ FIX
  }

  Future<Map<String, dynamic>> checkStatusPurchaseOrder({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse(
      "$baseUrl/fn/t_penerimaan_barang/checkStatusPurchaseOrder",
    );

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    return jsonDecode(res.body);
  }

  Future<String> generateNoPB({
    required String token,
    required String unitBusinessId,
  }) async {
    final uri = Uri.parse("$baseUrl/fn/t_penerimaan_barang/generateCode")
        .replace(
          queryParameters: {
            'menu_id': '272d81cc-b41a-4631-ad92-75dd320dc0aa',
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

    return json['data']; // ✅ OPC-2601-0006
  }

  Future<Map<String, dynamic>> updatePBWithDetails({
    required String token,
    required String pbId,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse(
      "$baseUrl/dynamic/t_penerimaan_barang/with-details/$pbId",
    );

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    print("📡 UPDATE PB STATUS: ${response.statusCode}");
    print("📡 UPDATE PB RAW RESPONSE: ${response.body}");

    Map<String, dynamic>? json;

    try {
      json = jsonDecode(response.body);
    } catch (e) {
      throw Exception("Response bukan JSON valid");
    }

    /// ❌ HTTP ERROR
    if (response.statusCode != 200 && response.statusCode != 201) {
      if (json is Map<String, dynamic>) {
        // A. Cek Error Validasi Field (contoh: qty di details.0)
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

        // B. Cek Pesan Umum dari Backend
        if (json['message'] != null) {
          throw _parseGeneralError(json['message']);
        }
      }

      throw "Gagal memperbarui penerimaan barang (${response.statusCode})";
    }

    // 2. Handle Business Logic Error (jika status != success)
    if (json?['status'] != 'success') {
      final msg = json?['message'] ?? 'Terjadi kesalahan sistem';
      throw _parseGeneralError(msg);
    }

    // 3. Sukses
    return json?['data'];

    
  }

  Future<void> insertInventory({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/fn/t_penerimaan_barang/insertInventory");

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      debugPrint('📦 INSERT INVENTORY STATUS: ${response.statusCode}');
      debugPrint('📦 INSERT INVENTORY BODY: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final json = jsonDecode(response.body);

      if (json['success'] != true) {
        throw Exception(json['message'] ?? 'Insert inventory gagal');
      }
    } catch (e) {
      throw Exception('Insert inventory gagal: $e');
    }
  }

  String _parseGeneralError(String msg) {
    final lowMsg = msg.toLowerCase();

    if (lowMsg.contains('insufficient')) {
      return "Stok tidak mencukupi untuk transaksi ini.";
    }
    if (lowMsg.contains('period closed')) {
      return "Periode transaksi sudah ditutup.";
    }
    if (lowMsg.contains('unauthorized') || lowMsg.contains('expired')) {
      return "Sesi Anda telah berakhir, silakan login kembali.";
    }
    if (lowMsg.contains('already exists') || lowMsg.contains('duplicate')) {
      return "Data dengan nomor ini sudah terdaftar di sistem.";
    }
    if (lowMsg.contains('exceed')) {
      return "Jumlah yang dimasukkan melebihi sisa pesanan (PO).";
    }

    // Jika tidak ada yang cocok, kembalikan pesan asli
    return msg;
  }

  String _formatValidationError(String field, String originalMessage) {
    final Map<String, String> fieldNames = {
      'warehouse_id': 'Gudang',
      'transaction_date': 'Tanggal Terima',
      'vendor_id': 'Supplier/Vendor',
      'purchase_order_id': 'Nomor PO',
      'reference_number': 'Nomor Referensi/SJ',
      'notes': 'Catatan',
      'item_id': 'Barang',
      'qty': 'Jumlah',
      'uom_id': 'Satuan',
      'batch_number': 'Nomor Batch',
      'expiry_date': 'Tanggal Kedaluwarsa',
    };

    // Logika untuk detail barang (details.0.qty dst)
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
