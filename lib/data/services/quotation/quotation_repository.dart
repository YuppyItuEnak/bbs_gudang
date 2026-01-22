import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/quotation/quotation_model.dart';
import '../../models/quotation/quotation_detail_model.dart';
import '../../../core/constants/api_constants.dart';

class QuotationRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<Quotation>> fetchQuotations(
    String salesId,
    String token, {
    String? search,
    int? page,
    int? paginate,
    String? filter_column_customer,
    String? filter_column_status,
    String? startDate,
    String? endDate,
  }) async {
    final endpointUrl = '$baseUrl/dynamic/t_sales_quotation';

    List<String> whereClauses = [];

    final queryParams = <String, String>{
      'filter_column_sales_id': salesId,
      'include': 'm_gen',
    };

    if (page != null) {
      queryParams['page'] = page.toString();
    }
    if (paginate != null) {
      queryParams['paginate'] = paginate.toString();
    }
    if (filter_column_customer != null) {
      queryParams['filter_column_customer_id'] = filter_column_customer;
    }
    if (filter_column_status != null) {
      queryParams['filter_column_status'] = filter_column_status;
    }
    if (startDate != null) {
      whereClauses.add('createdAt >= $startDate');
    }
    if (endDate != null) {
      whereClauses.add('createdAt <= $endDate');
    }

    if (whereClauses.isNotEmpty) {
      queryParams['where'] = whereClauses.join('|');
    }

    if (search != null) {
      queryParams['search'] = search;
      queryParams['searchfield'] = 'code,customer_name';
    }

    final url = Uri.parse(endpointUrl).replace(queryParameters: queryParams);

    try {
      if (kDebugMode) {
        print('🔗 URL: $url');
        print(startDate);
        print(endDate);
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
        final dynamic decodedResponse = json.decode(response.body);
        List<dynamic> responseData;

        if (decodedResponse is List) {
          responseData = decodedResponse;
        } else if (decodedResponse is Map<String, dynamic> &&
            decodedResponse['data'] is List) {
          responseData = decodedResponse['data'];
        } else {
          throw Exception(
            'Unexpected response format: ${decodedResponse.runtimeType}',
          );
        }

        return responseData
            .map((quotationJson) => Quotation.fromJson(quotationJson))
            .toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch quotations');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching quotations: $e');
      }
      rethrow;
    }
  }

  Future<QuotationDetail> fetchQuotationDetail(String id, String token) async {
    final endpointUrl = '$baseUrl/dynamic/t_sales_quotation/$id';
    final queryParams = {
      'include':
          't_sales_quotation_d,t_sales_quotation_d>m_item,m_customer_d_address,m_gen',
    };

    final url = Uri.parse(endpointUrl).replace(queryParameters: queryParams);

    try {
      if (kDebugMode) {
        print('🔗 Detail URL: $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('📥 Detail Response body: ${response.body}');
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'] ?? jsonResponse;
        return QuotationDetail.fromJson(data);
      } else {
        throw Exception('Failed to load quotation detail');
      }
    } catch (e) {
      rethrow;
    }
  }
}
