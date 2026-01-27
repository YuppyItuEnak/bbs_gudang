import 'dart:ffi';

import 'package:bbs_gudang/data/models/stock_opname/stock_opname_detail.dart';
import 'package:bbs_gudang/data/models/stock_opname/stock_opname_model.dart';
import 'package:bbs_gudang/data/services/stock_opname/stock_opname_repository.dart';
import 'package:flutter/material.dart';

class StockOpnameProvider extends ChangeNotifier {
  final StockOpnameRepository _opnameRepository = StockOpnameRepository();

  List<StockOpnameModel> _reports = [];
  StockOpnameModel? _listDetail;
  bool _isLoading = false;
  String? _errorMessage;

  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;

  List<StockOpnameModel> get reports => _reports;
  StockOpnameModel? get listDetail => _listDetail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  void reset() {
    _reports = [];
    _page = 1;
    _hasMore = true;
    _errorMessage = null;
    notifyListeners();
  }

  int get overStockCount => _reports.length;

  Future<void> fetchStockOpnameReport({
    required String token,
    required String startDate,
    required String endDate,
    List<String>? unitBusinessIds,
    List<String>? warehouseIds,
    bool loadMore = false,
  }) async {
    if (_isLoading) return;

    /// kalau backend tidak support pagination real,
    /// loadMore bisa kamu matikan dulu
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

      /// 🔑 BACKEND BALIK FULL LIST
      /// Kalau result kosong → berarti tidak ada data lagi
      if (result.isEmpty) {
        _hasMore = false;
      }

      _reports.addAll(result);

      /// page tetap naik (biar siap kalau nanti backend pagination aktif)
      _page++;
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
}
