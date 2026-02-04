import 'package:bbs_gudang/data/models/delivery_plan/delivery_plan_code_model.dart';
import 'package:bbs_gudang/data/models/delivery_plan/request_delivery_plan.dart';
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

  List<DeliveryPlanCodeModel> _listDeliveryPlanCode = [];

  List<DeliveryPlanCodeModel> get listDeliveryPlanCode => _listDeliveryPlanCode;

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

  DeliveryPlanCodeModel? _detailDPCode;
  DeliveryPlanCodeModel? get detailDPCode => _detailDPCode;

  String? _selectedDeliveryPlanId;
  String? get selectedDeliveryPlanId => _selectedDeliveryPlanId;

  String? _selectedDeliveryPlanCode;
  String? get selectedDeliveryPlanCode => _selectedDeliveryPlanCode;

  String? DOCode;

  bool isLoadingDOCode = false;
  String? DOCodeError;

  List<Map<String, dynamic>> _createdSuratJalan = [];
  List<Map<String, dynamic>> get createdSuratJalan => _createdSuratJalan;

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

  void setSelectedDeliveryPlanCode(String? value) {
    _selectedDeliveryPlanCode = value;
    notifyListeners();
  }

  Future<void> fetchDeliveryPlanCode({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _listDeliveryPlanCode = await _pengeluaranBarangRepository
          .fetchDeliveryPlanCode(token: token);

      // 🔑 RESET jika selected tidak ada di list
      if (!_listDeliveryPlanCode.any(
        (e) => e.id == _selectedDeliveryPlanCode,
      )) {
        _selectedDeliveryPlanCode = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDetailDPCode({
    required String token,
    required String id,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _detailDPCode = null;
    notifyListeners();

    try {
      final result = await _pengeluaranBarangRepository
          .fetchDetailDeliveryPlanCode(token: token, id: id);

      _detailDPCode = result;
      print("DEBUG PROVIDER: Item Berhasil Dimuat, Jumlah: ${_detailDPCode?.details.length}");
    } catch (e) {
      _errorMessage = e.toString();
      
      debugPrint('❌ fetchDetailDPCode error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedDeliveryPlanId(String id) {
    debugPrint('✅ SET selectedDeliveryPlanId = $id');
    _selectedDeliveryPlanId = id;
    notifyListeners();
  }

  void setListDeliveryPlanCode(List<DeliveryPlanCodeModel> list) {
    _listDeliveryPlanCode = list;

    // Pastikan selectedId tetap valid
    if (!list.any((e) => e.id == selectedDeliveryPlanId)) {
      _selectedDeliveryPlanId = null;
    }

    notifyListeners();
  }

  Future<void> generateNoDO({
    required String token,
    required String unitBusinessId,
  }) async {
    try {
      isLoadingDOCode = true;
      DOCodeError = null;
      notifyListeners();

      final code = await _pengeluaranBarangRepository.generateNoDO(
        token: token,
        unitBusinessId: unitBusinessId,
      );

      DOCode = code;
    } catch (e) {
      debugPrint('ERROR GENERATE NO DO: $e');
      DOCode = null;
      DOCodeError = e.toString();
    } finally {
      isLoadingDOCode = false;
      notifyListeners();
    }
  }

  Future<bool> createPengeluaranBarang({
    required String token,
    required SuratJalanRequestModel payload,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _pengeluaranBarangRepository.createPengeluaranBarang(
        token: token,
        payload: payload,
      );

      _createdSuratJalan = result;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void updateItemQtyLocal(int dIdx, int iIdx, double newQty) {
  if (detailDPCode != null) {
    detailDPCode!.details[dIdx].items[iIdx].qtyDp = newQty.toInt();
    notifyListeners();
  }
}

void removeItemLocal(int dIdx, int iIdx) {
  if (detailDPCode != null) {
    detailDPCode!.details[dIdx].items.removeAt(iIdx);
    // Jika list item di detail tersebut kosong, hapus detailnya sekalian
    if (detailDPCode!.details[dIdx].items.isEmpty) {
      detailDPCode!.details.removeAt(dIdx);
    }
    notifyListeners();
  }
}
}
