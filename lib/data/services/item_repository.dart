import 'dart:convert';
import 'package:bbs_gudang/data/models/item/item_model.dart';
import 'package:http/http.dart' as http;
import 'package:bbs_gudang/core/constants/api_constants.dart';

class ItemRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<ItemModel>> fetchItems({
    required String token,
    required String itemDivisionId,
    String? search,
    int page = 1,
    int paginate = 10,
  }) async {
    final queryParams = {
      'include': 'm_pricelist,m_gen',
      'where': 'item_division_id=$itemDivisionId',
      'filter_column_status': 'APPROVED',
      'filter_column_is_active': 'true',
      'order_by': 'createdAt',
      'order_type': 'DESC',
      'page': page.toString(),
      'paginate': paginate.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
      queryParams['searchfield'] = 'code,name';
    }

    final uri = Uri.parse(
      '$baseUrl/dynamic/m_item',
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
      final List data = body['data'];
      return data.map((e) => ItemModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data item');
    }
  }
}
