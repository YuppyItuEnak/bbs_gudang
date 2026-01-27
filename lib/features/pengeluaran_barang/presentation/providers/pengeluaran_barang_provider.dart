import 'package:bbs_gudang/data/models/pengeluaran_barang/pengeluaran_barang_model.dart';
import 'package:bbs_gudang/data/services/pengeluaran_barang/pengeluaran_barang_repository.dart';
import 'package:flutter/material.dart';

class PengeluaranBarangProvider extends ChangeNotifier {
  final PengeluaranBarangRepository _pengeluaranBarangRepository =
      PengeluaranBarangRepository();

  bool _isLoading = false;
  bool _isLoadMore = false;
  String? _errorMessage;
  List<PengeluaranBarangModel> _listPengeluaranBarang = [];
  PengeluaranBarangModel? _detaiilPengeluaranBarang;
  int _page = 1;
  final int _limit = 100;
  bool _hasMore = true;

  bool get isLoading => _isLoading;
  bool get isLoadMore => _isLoadMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  List<PengeluaranBarangModel> get listPengeluaranBarang =>
      _listPengeluaranBarang;
  PengeluaranBarangModel? get detailPengeluaranBarang =>
      _detaiilPengeluaranBarang;

  Future<void> fetchListPengeluaranBrg({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _pengeluaranBarangRepository.fetchAllPengeluaranBrg(
        token: token,
      );

      _listPengeluaranBarang = result;

      debugPrint("✅ SUCCESS FETCH ALL: ${result.length} data");
    } catch (e, stack) {
      _listPengeluaranBarang = [];
      _errorMessage = e.toString();

      debugPrint("❌ ERROR FETCH PENGELUARAN BARANG");
      debugPrint("MESSAGE: $e");
      debugPrint("STACKTRACE: $stack");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDetailPengeluaranBrg({
    required String token,
    required String id,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _detaiilPengeluaranBarang = await _pengeluaranBarangRepository
          .fetchDetailPengeluaranBrg(token: token, id: id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
