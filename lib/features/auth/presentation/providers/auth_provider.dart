import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:flutter/foundation.dart';
import '../../../../data/models/auth/user_model.dart';
import '../../../../data/services/auth/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  List<User> _userPIC = [];
  List<User> get userPIC => _userPIC;

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(username, password);

      _user = response.user;
      _token = response.token;
      _isLoading = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('auth_user', json.encode(_user!.toJson()));

      if (_user?.userDetails.isNotEmpty == true) {
        final salesId = _user!.userDetails.first.fUserDefault;
        if (salesId != null) {
          await _fetchAndSaveUnitBusinessId(salesId, _token!, prefs);
        }
      }

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (e.toString().contains(
        'user anda tidak diijinkan menggunakan aplikasi ini',
      )) {
        logout();
        _error = 'User tidak bisa mengakses aplikasi ini';
        notifyListeners();
      } else {
        _error = "Login gagal, periksa akun anda";
        notifyListeners();
      }
    }
  }

  void logout() async {
    _user = null;
    _token = null;
    _error = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('auth_token');
    final storedUser = prefs.getString('auth_user');

    if (storedToken != null && storedUser != null) {
      try {
        if (_isTokenExpired(storedToken)) {
          logout();
          return false;
        }

        _token = storedToken;
        _user = User.fromJson(json.decode(storedUser));
        notifyListeners();
        return true;
      } catch (e) {
        logout();
        return false;
      }
    }
    return false;
  }

  bool _isTokenExpired(String token) {
    try {
      bool isExpired = JwtDecoder.isExpired(token);
      return isExpired;
    } catch (e) {
      return true;
    }
  }

  Future<void> fetchUserDetails() async {
    if (_user?.id == null || _token == null) {
      logout();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userDetails = await _authRepository.fetchUserDetails(
        _user!.id,
        _token!,
      );
      _user = userDetails;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user', json.encode(_user!.toJson()));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (e.toString().contains(
        'user anda tidak diijinkan menggunakan aplikasi ini',
      )) {
        _error = 'user anda tidak diijinkan menggunakan aplikasi ini';
        logout();
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        logout();
      } else {
        _error = 'Gagal memuat detail pengguna';
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchAndSaveUnitBusinessId(
    String salesId,
    String token,
    SharedPreferences prefs,
  ) async {
    try {
      final uri =
          Uri.parse(
            '${ApiConstants.baseUrl}/dynamic/m_sales_area_d_sales',
          ).replace(
            queryParameters: {
              'where': 'sales_id=$salesId',
              'include': 'm_sales_area,m_sales_area>m_unit_bussiness',
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
        final body = json.decode(response.body);
        final List data = body['data'] ?? [];
        if (data.isNotEmpty) {
          final unitBusinessId =
              data[0]['m_sales_area']?['m_unit_bussiness']?['id'];
          if (unitBusinessId != null) {
            await prefs.setString('unit_bussiness_id', unitBusinessId);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch unit business id: $e');
      }
    }
  }

  Future<void> fetchUserPIC({required String token}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userPIC = await _authRepository.fetchUserPIC(token: token);
    } catch (e) {
      throw Exception('Gagal mengambil data User PIC');
    }finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
