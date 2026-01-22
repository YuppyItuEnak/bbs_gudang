import 'dart:convert';
import 'package:bbs_gudang/data/models/m_gen_model.dart';
import 'package:http/http.dart' as http;
import 'package:bbs_gudang/core/constants/api_constants.dart';

class MGenRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<MGenModel>> fetchMGen(String where, String token) async {
    final queryParams = {
      'where': where,
      'no_pagination': 'true',
    };

    final uri =
        Uri.parse('$baseUrl/dynamic/m_gen').replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((e) => MGenModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data MGen');
    }
  }
}
