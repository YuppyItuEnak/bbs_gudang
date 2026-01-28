import 'package:bbs_gudang/data/models/stock_adjustment/stock_adjustment_model.dart';
import 'package:bbs_gudang/data/services/stock_adjustment/stock_adjustment_repository.dart';
import 'package:flutter/material.dart';

class StockAdjustmentProvider extends ChangeNotifier {
  final StockAdjustmentRepository _repo = StockAdjustmentRepository();

  List<StockAdjustmentModel> _data = [];
  StockAdjustmentModel? _detailData;
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;

  List<StockAdjustmentModel> get data => _data;
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
      if (!loadMore) reset();

      final result = await _repo.getStockAdjustments(
        token: token,
        page: _page,
        paginate: _limit,
      );

      if (result.length < _limit) _hasMore = false;

      _data.addAll(result);
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
      final result = await _repo.createStockAdjustment(
        token: token,
        payload: payload,
      );

      adjustmentId = result['id'];
      adjustmentCode = result['code'];
    } catch (e) {
      rethrow;
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
}
