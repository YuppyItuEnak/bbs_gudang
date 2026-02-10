import 'package:bbs_gudang/data/models/stock_adjustment/stock_adjustment_model.dart';
import 'package:bbs_gudang/data/services/stock_adjustment/stock_adjustment_repository.dart';
import 'package:flutter/material.dart';

class StockAdjustmentProvider extends ChangeNotifier {
  final StockAdjustmentRepository _repo = StockAdjustmentRepository();

  List<StockAdjustmentModel> _data = [];
  List<StockAdjustmentModel> _filterData = [];
  StockAdjustmentModel? _detailData;
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;

  List<StockAdjustmentModel> get data => _data;
  List<StockAdjustmentModel> get filterData => _filterData;
  StockAdjustmentModel? get detailData => _detailData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  List<Map<String, dynamic>> _opnames = [];
  Map<String, dynamic>? _selectedOpname;

  List<Map<String, dynamic>> get opnames => _opnames;
  Map<String, dynamic>? get selectedOpname => _selectedOpname;

  bool _isCheckingApproval = false;
  bool get isCheckingApproval => _isCheckingApproval;
  String? approvalId;

  void reset() {
    _data.clear();
    _page = 1;
    _hasMore = true;
    notifyListeners();
  }

  int get underStockCount => data.length;

  void search(String query) {
    if (query.isEmpty) {
      _filterData = _data;
    } else {
      _filterData = _data.where((element) {
        final code = element.code ?? "";
        final date = element.date ?? "";
        final warehouse = element.warehouse?.name ?? "";
        final searchText = query;

        return code.contains(searchText) ||
            date.contains(searchText) ||
            warehouse.contains(searchText);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> fetchStockAdjustments({
    required String token,
    bool loadMore = false,
  }) async {
    if (_isLoading) return;
    if (!_hasMore && loadMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!loadMore) {
      _page = 1;
      _hasMore = true;
      _data.clear();
      _filterData.clear(); 
    }
      final result = await _repo.getStockAdjustments(
        token: token,
        page: _page,
        paginate: _limit,
      );

      if (result.length < _limit) _hasMore = false;

      _data.addAll(result);
     _filterData = List.from(_data);
      _page++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDetailAdjustment({
    required String token,
    required String id,
  }) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      _detailData = await _repo.fetchDetailAdjustment(token: token, id: id);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _detailData = null; // Opsional: hapus data lama jika error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOpnameReference({
    required String token,
    required String unitBusinessId,
    required String warehouseId,
  }) async {
    _isLoading = true;
    _error = null;
    _opnames = [];
    _selectedOpname = null;
    notifyListeners();

    try {
      final result = await _repo.fetchOpnameReferance(
        unitBusinessId: unitBusinessId,
        warehouseId: warehouseId,
        token: token,
      );

      _opnames = result;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Di dalam StockAdjustmentProvider

  // Tambahkan variabel untuk menampung item yang sedang dikerjakan
  List<Map<String, dynamic>> _selectedItems = [];
  List<Map<String, dynamic>> get selectedItems => _selectedItems;

  Future<void> selectOpname({
    required String token,
    required String opnameId,
  }) async {
    _isLoading = true;
    _error = null;
    _selectedItems = []; // Reset item sebelumnya
    notifyListeners();

    try {
      // 1. Ambil data Opname (Header & List ID Item)
      final data = await _repo.fetchItemByOpname(
        token: token,
        opnameId: opnameId,
      );

      final List opnameDetails = data["t_inventory_s_opname_ds"] ?? [];

      // 2. Gunakan Future.wait untuk mengambil detail nama barang secara PARALEL
      // Ini akan menjalankan semua request fetchMasterItem sekaligus
      final List<Map<String, dynamic>> enrichedItems = await Future.wait(
        opnameDetails.map((item) async {
          final itemId = item["item_id"];

          try {
            // Panggil repo yang baru Anda buat
            final masterData = await _repo.fetchMasterItem(
              token: token,
              opnameId: itemId, // Sesuai parameter repo Anda (itemId)
            );

            double opnameQty = (item["opname_qty"] ?? 0).toDouble();
            double onHandQty = (item["current_on_hand_quantity"] ?? 0)
                .toDouble();
            double diff = opnameQty - onHandQty;

            return {
              "item_id": itemId,
              "item_code": masterData["code"] ?? item["item_code"] ?? "",
              "item_name":
                  masterData["name"] ?? "Tanpa Nama", // NAMA SEKARANG MUNCUL
              "item_group_coa_id":
                  masterData["item_group_coa_id"], // PENTING untuk submit
              "uom_id": item["item_uom_id"],
              "qty_on_hand": onHandQty,
              "qty_physical": opnameQty,
              "qty_adjustment": diff,
              "notes": "Bawaan dari Opname ${data['code'] ?? ''}",
            };
          } catch (e) {
            // Fallback jika salah satu item gagal fetch
            debugPrint("Gagal fetch detail item $itemId: $e");
            return {
              "item_id": itemId,
              "item_code": item["item_code"] ?? "",
              "item_name": "Gagal muat nama",
              "uom_id": item["item_uom_id"],
              "qty_on_hand": 0.0,
              "qty_physical": 0.0,
              "qty_adjustment": 0.0,
              "notes": "Error detail fetch",
            };
          }
        }).toList(),
      );

      // 3. Masukkan hasil penggabungan ke state
      _selectedItems = enrichedItems;

      debugPrint(
        "✅ Berhasil memuat ${_selectedItems.length} item lengkap dengan nama",
      );
    } catch (e) {
      _error = e.toString();
      debugPrint("❌ Error selectOpname: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadItemByOpname({
    required String token,
    required String opnameId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repo.fetchItemByOpname(
        token: token,
        opnameId: opnameId,
      );
      _selectedOpname = result;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkCanSubmit({
    required String token,
    required String authUserId,
    required String menuId,
    String? unitBusinessId,
  }) async {
    _isCheckingApproval = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repo.checkCanSubmit(
        token: token,
        authUserId: authUserId,
        menuId: menuId,
        unitBusinessId: unitBusinessId,
      );

      final canSubmit = result['can_submit'] == true;

      if (!canSubmit) {
        _error = result['message'] ?? 'Tidak bisa submit';
        return false;
      }

      approvalId = result['approval_id'];
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isCheckingApproval = false;
      notifyListeners();
    }
  }

  String? adjustmentId;
  String? adjustmentCode;

  Future<void> createAdjustment({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repo.createStockAdjustment(token: token, payload: payload);
      await fetchStockAdjustments(token: token, loadMore: false);

      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// set dropdown selected value
  void setSelectedOpname(Map<String, dynamic>? value) {
    _selectedOpname = value;
    notifyListeners();
  }

  void clear() {
    _opnames = [];
    _selectedOpname = null;
    _error = null;
    notifyListeners();
  }

  bool isUpdating = false;
  String? updateError;

  Future<bool> updateStockAdjustment({
    required String token,
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    try {
      isUpdating = true;
      updateError = null;
      notifyListeners();

      final data = await _repo.updateStockAdjustment(
        token: token,
        id: id,
        payload: payload,
      );

      // Optional: refresh detail setelah update
      await fetchDetailAdjustment(token: token, id: id);

      isUpdating = false;
      notifyListeners();

      return true;
    } catch (e) {
      isUpdating = false;
      updateError = e.toString();
      notifyListeners();
      return false;
    }
  }

  String? generatedCode;
  bool isGeneratingCode = false;

  Future<void> generateCode({required String token}) async {
    try {
      isGeneratingCode = true;
      notifyListeners();

      generatedCode = await _repo.generateAdjustmentCode(token: token);
    } catch (e) {
      _error = e.toString();
      generatedCode = null;
    } finally {
      isGeneratingCode = false;
      notifyListeners();
    }
  }
}
