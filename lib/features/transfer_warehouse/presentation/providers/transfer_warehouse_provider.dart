import 'package:bbs_gudang/data/models/list_item/list_item_model.dart';
import 'package:bbs_gudang/data/models/transfer_warehouse/company_warehouse_model.dart';
import 'package:bbs_gudang/data/models/transfer_warehouse/transfer_company_model.dart';
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

  List<TransferCompanyModel> _companies = [];
  List<TransferCompanyModel> get companies => _companies;

  List<CompanyWarehouseModel> _warehouses = [];
  List<CompanyWarehouseModel> get warehouses => _warehouses;

  bool _isLoadingCompany = false;
  bool _isLoadingWarehouse = false;

  bool get isLoadingCompany => _isLoadingCompany;
  bool get isLoadingWarehouse => _isLoadingWarehouse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TransferWarehouseModel> get listTransferWarehouse =>
      _listTransferWarehouse;
  TransferWarehouseModel? get detailTransferWarehouse =>
      _detailTransferWarehouse;

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => _items;

  bool isSubmitting = false;
  List<Map<String, dynamic>> transactions = [];

  void setTransactions(List<Map<String, dynamic>> data) {
    transactions = data;
    notifyListeners();
  }

  void setItems(List<Map<String, dynamic>> newItems) {
    _items = newItems;
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((e) => e['id'] == id);
    notifyListeners();
  }

  void updateQty(String id, int qty) {
    final index = _items.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      _items[index]['qty'] = qty;
      notifyListeners();
    }
  }

  Future<void> submitTransfer({
    required String token,
    required String unitBusinessId,
    required String sourceWarehouseId,
    required String destinationWarehouseId,
    required String date,
    required String status, // DRAFT / POSTED
    String? notes,
  }) async {
    isSubmitting = true;
    notifyListeners();

    try {
      final payload = {
        "status": status,
        "unit_bussiness_id": unitBusinessId,
        "date": date,
        "source_warehouse_id": sourceWarehouseId,
        "destination_warehouse_id": destinationWarehouseId,
        "notes": notes,
        "tonnage": items.length,
        "t_inventory_transfer_warehouse_d": items
            .map(
              (e) => {
                "item_id": e['id'],
                "item_code": e['code'],
                "item_name": e['name'],
                "qty": e['qty'],
                "uom": "PCS",
                "weight": 0,
                "notes": "",
              },
            )
            .toList(),
      };

      await _transferWarehouseRepository.saveTransferWarehouse(
        token: token,
        payload: payload,
      );
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> updateTransfer({
    required String token,
    required String id,
    required String unitBusinessId,
    required String code,
    required String sourceWarehouseId,
    required String destinationWarehouseId,
    required String status,
    required String date,
    String? notes,
    required String unitBusinessName, 
    required String sourceWarehouseName, 
    required String
    destinationWarehouseName, 
  }) async {
    isSubmitting = true;
    notifyListeners();

    try {
      final now = DateTime.now().toIso8601String();

      final payload = {
        "id": id,
        "unit_bussiness_id": unitBusinessId,
        "code": code,
        "source_warehouse_id": sourceWarehouseId,
        "destination_warehouse_id": destinationWarehouseId,
        "status": status,
        "tonnage": items.length,
        "notes": notes ?? "",
        "date": date,
        "createdAt": date, // Sesuai payload edit
        "updatedAt": date, // Sesuai payload edit
        "m_unit_bussiness": {"id": unitBusinessId, "name": unitBusinessName},
        "source_warehouse": {
          "id": sourceWarehouseId,
          "name": sourceWarehouseName,
        },
        "destination_warehouse": {
          "id": destinationWarehouseId,
          "name": destinationWarehouseName,
        },

        // Bagian Detail
        "t_inventory_transfer_warehouse_d": items.map((e) {
          return {
            "id": e['detail_id'],
            "item_code": e['item_code'] ?? e['code'],
            "item_name": e['item_name'] ?? e['name'],
            "qty": e['qty'],
            "uom": e['uom_name'] ?? "PCS",
            "weight": e['weight'] ?? 0,
            "notes": e['notes'] ?? "",
            "t_inventory_transfer_warehouse_id": id,
            "item_id": e['id'],
            "createdAt": now,
            "updatedAt": now,
          };
        }).toList(),
      };

      await _transferWarehouseRepository.saveTransferWarehouse(
        token: token,
        payload: payload,
      );
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> fetchListTransferWarehouse({
    required String token,
    bool refresh = false,
  }) async {
    if (refresh) {
      _listTransferWarehouse = [];
    }

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
      debugPrint("❌ ERROR FETCH Detail Transfer Warehouse: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserCompanies({
    required String token,
    required String userId,
    required String responsibilityId,
  }) async {
    _isLoadingCompany = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _companies = await _transferWarehouseRepository.fetchUserCompanies(
        token: token,
        userId: userId,
        responsibilityId: responsibilityId,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingCompany = false;
      notifyListeners();
    }
  }

  Future<void> loadWarehouseCompany({
    required String token,
    required String unitBusinessId,
  }) async {
    // debugPrint('MASUK loadWarehouseCompany');
    // debugPrint('Unit Business ID: $unitBusinessId');

    _isLoadingWarehouse = true;
    _warehouses = [];
    notifyListeners();

    try {
      // debugPrint('CALL API fetchListWarehouse...');
      final result = await _transferWarehouseRepository.fetchListWarehouse(
        unitBusinessId: unitBusinessId,
        token: token,
      );

      debugPrint(
        'Total Warehouse Company dari Unit Business $unitBusinessId: ${result.length}',
      );
      _warehouses = result;
    } catch (e, s) {
      debugPrint('ERROR fetch warehouse: $e');
      debugPrint('$s');
    } finally {
      _isLoadingWarehouse = false;
      notifyListeners();
    }
  }
}
