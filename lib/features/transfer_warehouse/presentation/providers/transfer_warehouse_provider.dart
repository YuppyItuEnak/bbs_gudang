import 'package:bbs_gudang/data/models/transfer_warehouse/transfer_warehouse_model.dart';
import 'package:bbs_gudang/data/services/transfer_warehouse/transfer_warehouse_repository.dart';
import 'package:flutter/material.dart';

class TransferWarehouseProvider extends ChangeNotifier {
  final TransferWarehouseRepository _transferWarehouseRepository =
      TransferWarehouseRepository();

  bool _isLoading = false;
  String? _errorMessage;
  List<TransferWarehouseModel> _listTransferWarehouse = [];
  TransferWarehouseModel? _detailTransferWarehouse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TransferWarehouseModel> get listTransferWarehouse =>
      _listTransferWarehouse;
  TransferWarehouseModel? get detailTransferWarehouse =>
      _detailTransferWarehouse;

  Future<void> fetchListTransferWarehouse({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _transferWarehouseRepository
          .fetchListTransferWarehouse(token: token);

      _listTransferWarehouse = result;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("❌ ERROR FETCH Transfer Warehouse: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDetailTransferWarehouse({
    required String token,
    required String id,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _detailTransferWarehouse = await _transferWarehouseRepository
          .fetchDetailTransferWarehouse(token: token, id: id);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("❌ ERROR FETCH Transfer Warehouse: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
