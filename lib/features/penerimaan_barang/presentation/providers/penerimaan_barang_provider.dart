import 'package:bbs_gudang/data/models/penerimaan_barang/penerimaan_barang_detail.dart';
import 'package:bbs_gudang/data/models/penerimaan_barang/penerimaan_barang_model.dart';
import 'package:bbs_gudang/data/services/penerimaan_barang/penerimaan_barang_repository.dart';
import 'package:flutter/material.dart';

class PenerimaanBarangProvider extends ChangeNotifier {
  final PenerimaanBarangRepository _repository = PenerimaanBarangRepository();

  bool _isLoading = false;
  String? _errorMessage;
  List<PenerimaanBarangModel> _listPenerimaanBarang = [];
  PenerimaanBarangModel? _data;

  int _page = 1;
  int _paginate = 10;

  bool _hasMore = true;

  // ============================
  // GETTER
  // ============================

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PenerimaanBarangModel> get listPenerimaanBarang => _listPenerimaanBarang;
  PenerimaanBarangModel? get data => _data;
  bool get hasMore => _hasMore;

  int get page => _page;
  int get paginate => _paginate;

  Future<void> fetchPenerimaanBarang({
    required String token,
    bool isRefresh = false,
     bool loadMore = false,
  }) async {
    // 🔴 STOP kalau sedang load more atau sudah tidak ada page lagi
    if (_isLoading) return;
    if (!_hasMore && !isRefresh) return;

    if (isRefresh) {
      _page = 1;
      _hasMore = true;
      _listPenerimaanBarang.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.fetchPenerimaanBarang(
        token: token,
        page: _page,
        paginate: _paginate,
      );

      final List<PenerimaanBarangModel> newData =
          List<PenerimaanBarangModel>.from(result['data']);

      final pagination = result['pagination'];

      final int currentPage =
          int.tryParse(pagination['page']?.toString() ?? '') ?? _page;

      final int totalPages =
          int.tryParse(pagination['totalPages']?.toString() ?? '') ?? _page;

      // =========================
      // TAMBAH DATA
      // =========================
      if (_page == 1) {
        _listPenerimaanBarang = newData;
      } else {
        _listPenerimaanBarang.addAll(newData);
      }

      // =========================
      // LOGIKA STOP PAGINATION
      // =========================
      if (currentPage >= totalPages || newData.isEmpty) {
        _hasMore = false; // 🔴 STOP LOAD
      } else {
        _page++; // LANJUT PAGE BERIKUTNYA
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("❌ ERROR FETCH PENERIMAAN BARANG: $e");

      // 🔴 JIKA ERROR, STOP PAGINATION
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDetail({required String token, required String id}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _data = await _repository.fetchDetailPenerimaanBarang(
        token: token,
        id: id,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
