import 'package:bbs_gudang/data/models/customer/customer_address_model.dart';
import 'dart:convert';
import 'package:bbs_gudang/data/models/customer/customer_name_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/customer/customer_model.dart';
import '../../../core/constants/api_constants.dart';

class CustomerRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<CustomerAddressModel>> fetchCustomerAddresses(
    String customerId,
    String token,
  ) async {
    final queryParams = {
      'where': 'customer_id=$customerId',
      'filter_column_is_active': 'true',
      'no_pagination': 'true',
    };

    final uri = Uri.parse(
      '$baseUrl/dynamic/m_customer_d_address',
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

      return data.map((e) => CustomerAddressModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil alamat customer');
    }
  }

  Future<List<CustomerModel>> fetchCustomers(
    String salesId,
    String token, {
    String? search,
    int? page,
    int? paginate,
    required String unitBusinessId,
  }) async {
    final endpointUrl = '$baseUrl/dynamic/m_customer';

    final queryParams = <String, String>{'filter_column_sales_id': salesId};

    if (page != null) {
      queryParams['page'] = page.toString();
    }
    if (paginate != null) {
      queryParams['paginate'] = paginate.toString();
    }
    if (search != null) {
      queryParams['search'] = search;
      queryParams['searchfield'] = 'name,code';
    }
    queryParams['filter_column_unit_bussiness_id'] = unitBusinessId;

    final url = Uri.parse(endpointUrl).replace(queryParameters: queryParams);

    try {
      if (kDebugMode) {
        print('🔗 URL: $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('📥 Response status: ${response.statusCode}');
        print('📥 Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> customersJson = responseData['data'] ?? [];

        return customersJson
            .map((json) => CustomerModel.fromJson(json))
            .toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch customers');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Fetch customers error: $e');
      }
      rethrow;
    }
  }

  Future<List<CustomerSimpleModel>> fetchListCustomersName(
    String token, {
    required String search,
    String? salesId,
    required String unitBusinessId,
  }) async {
    final queryParams = <String, String>{
      'selectfield': 'id,name,m_customer_group.segment_id',
      'include': 'm_customer_group,m_customer_group>m_gen',
    };

    if (search.isNotEmpty) {
      queryParams['search'] = search;
      queryParams['searchfield'] = 'name';
    }

    if (salesId != null) {
      queryParams['where=sales_id'] = salesId;
    }
    queryParams['filter_column_unit_bussiness_id'] = unitBusinessId;

    final uri = Uri.parse(
      '$baseUrl/dynamic/m_customer',
    ).replace(queryParameters: queryParams);
    print('🔗 URL: $uri');
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
      print('📥 Response body: ${response.body}');

      return data.map((e) => CustomerSimpleModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil customer');
    }
  }
}
