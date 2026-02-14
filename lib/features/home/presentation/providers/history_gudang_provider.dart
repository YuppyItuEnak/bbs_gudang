import 'package:bbs_gudang/data/models/home/history_gudang_model.dart';
import 'package:bbs_gudang/data/models/penerimaan_barang/penerimaan_barang_model.dart';
import 'package:bbs_gudang/data/models/pengeluaran_barang/pengeluaran_barang_model.dart';
import 'package:bbs_gudang/data/models/stock_adjustment/stock_adjustment_model.dart';
import 'package:bbs_gudang/data/models/stock_opname/stock_opname_model.dart';
import 'package:bbs_gudang/data/services/home/history_gudang_repository.dart';
import 'package:flutter/material.dart';

class HistoryGudangProvider extends ChangeNotifier {
  final HistoryGudangRepository _historyGudangRepository =
      HistoryGudangRepository();

  bool _isLoading = false;
  String? _errorMessage;
  final List<HistoryGudangModel> _listHistory = [];
  final List<HistoryGudangModel> _filterHistoryGudang = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<HistoryGudangModel> get listHistory => _listHistory;
  List<HistoryGudangModel> get filterHistoryGudang => _filterHistoryGudang;

  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  void searchHistoryGudang(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  List<dynamic> get filteredTransactions {
    final all = allTransactions;

    if (_searchQuery.isEmpty) {
      return all;
    }
    return all.where((item) {
      final dynamic data = item;
      final String code = (data.code ?? "").toString().toLowerCase();
      return code.contains(_searchQuery);
    }).toList();
  }

  List<dynamic> get allTransactions {
    final combined = [
      ..._listPengeluaranBarangHistory,
      ..._listPenerimaanBarangHistory,
      ..._listStkAdjustHistory,
      ..._listStkOpnameHistory,
    ];

    combined.sort((a, b) {
      final dynamic itemA = a;
      final dynamic itemB = b;
      DateTime dateA =
          DateTime.tryParse(itemA.date.toString()) ?? DateTime(2000);
      DateTime dateB =
          DateTime.tryParse(itemB.date.toString()) ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });

    return combined;
  }

  List<PengeluaranBarangModel> _listPengeluaranBarangHistory = [];
  List<PengeluaranBarangModel> get listPengeluaranBarangHistory =>
      _listPengeluaranBarangHistory;

  Future<void> fetchPengeluaranBarangHistory({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _historyGudangRepository
          .fetchPengeluaranBarangHistory(token: token);

      _listPengeluaranBarangHistory = result;
    } catch (e) {
      final cleanMessage = e.toString().replaceAll("Exception: ", "");
      _errorMessage = cleanMessage;

      debugPrint("❌ ERROR FETCH PENGELUARAN BARANG HISTORY");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<PenerimaanBarangModel> _listPenerimaanBarangHistory = [];
  List<PenerimaanBarangModel> get listPenerimaanBarangHistory =>
      _listPenerimaanBarangHistory;

  Future<void> fetchPenerimaanBarangHistory({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _historyGudangRepository
          .fetchPenerimaanBarangHistory(token: token);

      final List<PenerimaanBarangModel> newData = result['data'];

      _listPenerimaanBarangHistory = newData;

      _errorMessage = null;
    } catch (e) {
      final cleanMessage = e.toString().replaceAll("Exception: ", "");
      _errorMessage = cleanMessage;

      debugPrint("❌ ERROR FETCH PENGELUARAN BARANG HISTORY");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<StockAdjustmentModel> _listStkAdjustHistory = [];
  List<StockAdjustmentModel> get listStkAdjustHistory => _listStkAdjustHistory;

  Future<void> fetchStkAdjustHistory({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<StockAdjustmentModel> result = await _historyGudangRepository
          .fetchStkAdjustHistory(token: token);

      _listStkAdjustHistory = result;
      _errorMessage = null;
    } catch (e) {
      final cleanMessage = e.toString().replaceAll("Exception: ", "");
      _errorMessage = cleanMessage;

      debugPrint("❌ ERROR FETCH PENGELUARAN BARANG HISTORY");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<StockOpnameModel> _listStkOpnameHistory = [];
  List<StockOpnameModel> get listStkOpnameHistory => _listStkOpnameHistory;

  Future<void> fetchStkOpnameHistory({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _historyGudangRepository.fetchStkOpnameHistory(
        token: token,
      );

      _listStkOpnameHistory = result;
    } catch (e) {
      final cleanMessage = e.toString().replaceAll("Exception: ", "");
      _errorMessage = cleanMessage;

      debugPrint("❌ ERROR FETCH PENGELUARAN BARANG HISTORY");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
