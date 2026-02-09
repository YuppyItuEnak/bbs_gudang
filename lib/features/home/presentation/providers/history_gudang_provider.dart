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
  List<HistoryGudangModel> _listHistory = [];
  List<HistoryGudangModel> _filterHistoryGudang = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<HistoryGudangModel> get listHistory => _listHistory;
  List<HistoryGudangModel> get filterHistoryGudang => _filterHistoryGudang;

  // Di dalam HistoryGudangProvider
  // Tambahkan variabel ini di dalam HistoryGudangProvider
  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  void searchHistoryGudang(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners(); // Memicu UI untuk update list
  }

  // Getter ini yang akan kita pakai di UI
  List<dynamic> get filteredTransactions {
    // 1. Ambil semua data gabungan
    final all = allTransactions;

    // 2. Jika kolom search kosong, tampilkan semua
    if (_searchQuery.isEmpty) {
      return all;
    }

    // 3. Jika ada isi, filter berdasarkan kode transaksi
    return all.where((item) {
      final dynamic data = item;
      final String code = (data.code ?? "").toString().toLowerCase();
      return code.contains(_searchQuery);
    }).toList();
  }

  // Update allTransactions agar mendukung filter pencarian
  // List<dynamic> get filteredAllTransactions {
  //   final combined = [
  //     ..._listPengeluaranBarangHistory,
  //     ..._listPenerimaanBarangHistory,
  //     ..._listStkAdjustHistory,
  //     ..._listStkOpnameHistory,
  //   ];

  //   // Filter berdasarkan search query (jika ada)
  //   final filtered = combined.where((item) {
  //     final dynamic data = item;
  //     final String code = (data.code ?? "").toString().toLowerCase();
  //     return code.contains(_searchQuery.toLowerCase());
  //   }).toList();

  //   // Sorting terbaru ke terlama
  //   filtered.sort((a, b) {
  //     final dynamic itemA = a;
  //     final dynamic itemB = b;
  //     DateTime dateA =
  //         DateTime.tryParse(itemA.date.toString()) ?? DateTime(2000);
  //     DateTime dateB =
  //         DateTime.tryParse(itemB.date.toString()) ?? DateTime(2000);
  //     return dateB.compareTo(dateA);
  //   });

  //   return filtered;
  // }

  // Di dalam HistoryGudangProvider
  List<dynamic> get allTransactions {
    final combined = [
      ..._listPengeluaranBarangHistory,
      ..._listPenerimaanBarangHistory,
      ..._listStkAdjustHistory,
      ..._listStkOpnameHistory,
    ];

    // Urutkan agar data terbaru dari kategori mana pun muncul paling atas
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

  // void searchHistoryGudang(String query) {
  //   if (query.isEmpty) {
  //     _filterHistoryGudang = _listHistory;
  //   } else {
  //     _filterHistoryGudang = _listHistory.where((element) {
  //       final code = element.itemCode ?? "";
  //       final date = element.date ?? "";
  //       final searchText = query;

  //       return code.contains(searchText) || date.contains(searchText);
  //     }).toList();
  //   }
  //   notifyListeners();
  // }

  Future<void> fetchHistoryGudang({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _historyGudangRepository.fetchListHistoryGudang(
        token: token,
        page: 1,
        limit: 10,
        warehouseIds: [],
        unitBusinessIds: [],
        startDate: "2026-01-31",
        endDate: "2026-02-27",
      );

      _listHistory = result;
      _filterHistoryGudang = result;
    } catch (e) {
      _errorMessage = e.toString();

      debugPrint("❌ ERROR FETCH HISTORY GUDANG");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      _errorMessage = e.toString();

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
      _errorMessage = e.toString();
      debugPrint("❌ ERROR FETCH PENERIMAAN BARANG HISTORY: $e");
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
    // notifyListeners(); // Opsional: Aktifkan jika ingin UI langsung menunjukkan loading

    try {
      // Repository sekarang mengembalikan List<StockAdjustmentModel>
      final List<StockAdjustmentModel> result = await _historyGudangRepository
          .fetchStkAdjustHistory(token: token);

      // Karena di Repo sudah dijamin mengembalikan [] jika null,
      // kita bisa langsung menimpa variabelnya.
      _listStkAdjustHistory = result;

      _errorMessage = null; // Reset error jika pemanggilan sukses
    } catch (e) {
      _errorMessage = e.toString();

      // Opsional: Jika error, apakah list ingin dikosongkan atau tetap menampilkan data lama?
      // _listStkAdjustHistory = [];

      debugPrint("❌ ERROR FETCH STOCK ADJUSTMENT HISTORY: $_errorMessage");
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
      _errorMessage = e.toString();

      debugPrint("❌ ERROR FETCH STOCK OPNAME HISTORY");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
