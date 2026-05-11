
import 'package:bbs_gudang/data/models/stock_opname/stock_opname_model.dart';
import 'package:bbs_gudang/data/services/stock_opname/stock_opname_repository.dart';
import 'package:flutter/material.dart';

class StockOpnameProvider extends ChangeNotifier {
  final StockOpnameRepository _opnameRepository = StockOpnameRepository();

  List<StockOpnameModel> _reports = [];
  List<StockOpnameModel> _filteredReports = [];
  StockOpnameModel? _listDetail;
  bool _isLoading = false;
  String? _errorMessage;

  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;

  List<StockOpnameModel> get reports => _reports;
  List<StockOpnameModel> get filteredReports => _filteredReports;
  StockOpnameModel? get listDetail => _listDetail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  StockOpnameModel? result;

  void reset() {
    _reports = [];
    _page = 1;
    _hasMore = true;
    _errorMessage = null;
    notifyListeners();
  }

  int get overStockCount => _reports.length;

  String _searchQuery = '';
  String? _selectedStatusFilter;
  String? get selectedStatusFilter => _selectedStatusFilter;

  void searchStockOpname(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setStatusFilter(String? status) {
    _selectedStatusFilter = status;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredReports = _reports.where((element) {
      final matchesSearch = _searchQuery.isEmpty ||
          (element.code).contains(_searchQuery) ||
          (element.date.toString()).contains(_searchQuery) ||
          (element.warehouse?.name ?? '').contains(_searchQuery);

      final matchesStatus = _selectedStatusFilter == null ||
          element.status == _selectedStatusFilter;

      return matchesSearch && matchesStatus;
    }).toList();

    notifyListeners();
  }

  Future<void> fetchStockOpnameReport({
    required String token,
    required String startDate,
    required String endDate,
    List<String>? unitBusinessIds,
    List<String>? warehouseIds,
    bool loadMore = false,
  }) async {
    if (_isLoading) return;
    if (!_hasMore && loadMore) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!loadMore) {
        reset(); // clear data, reset page & hasMore
      }

      final result = await _opnameRepository.getStockOpnameReport(
        token: token,
        startDate: startDate,
        endDate: endDate,
        page: _page,
        limit: _limit,
        unitBusinessIds: unitBusinessIds,
        warehouseIds: warehouseIds,
      );

      if (result.isEmpty) {
        _hasMore = false;
      }else{
        final existingIds = _reports.map((e) => e.id).toSet();
      final uniqueNewData = result.where((item) => !existingIds.contains(item.id)).toList();

      _reports.addAll(uniqueNewData);
      _reports.sort((a, b) {
        final aDate = a.date ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.date ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateCompare = bDate.compareTo(aDate);
        if (dateCompare != 0) return dateCompare;
        final aNum = int.tryParse(a.code.split('-').last) ?? 0;
        final bNum = int.tryParse(b.code.split('-').last) ?? 0;
        return bNum.compareTo(aNum);
      });

      _applyFilters();
      _page++;
      }

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDetailOpnameReport({
    required String token,
    required String opnameId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      _listDetail = await _opnameRepository.getStockOpnameDetailReport(
        token: token,
        opnameId: opnameId,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> submitStockOpname({
  //   required String token,
  //   required Map<String, dynamic> payload,
  // }) async {
  //   try {
  //     await _opnameRepository.createStockOpname(token: token, payload: payload);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<void> submitStockOpname({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    try {
      // 🔹 1. Generate code dulu
      final code = await _opnameRepository.generateStockOpnameCode(
        token: token,
      );

      // 🔹 2. Inject code ke payload
      payload['code'] = code;

      // 🔹 3. Submit stock opname
      result = await _opnameRepository.createStockOpname(
        token: token,
        payload: payload,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateStockOpname({
    required String token,
    required String opnameId,
    required Map<String, dynamic> payload,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _opnameRepository.updateStckOpname(
        token: token,
        opnameId: opnameId,
        payload: payload,
      );

      _isLoading = false;
      notifyListeners();
      return true; // Berhasil
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      return false; // Gagal
    }
  }
}
