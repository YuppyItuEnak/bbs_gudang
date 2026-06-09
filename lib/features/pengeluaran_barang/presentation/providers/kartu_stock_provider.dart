import 'package:bbs_gudang/data/models/kartu_stock/kartu_stock_model.dart';
import 'package:bbs_gudang/data/models/kartu_stock/stock_warehouse_model.dart';
import 'package:bbs_gudang/data/models/transfer_warehouse/company_warehouse_model.dart';
import 'package:bbs_gudang/data/services/kartu_stock/kartu_stock_repository.dart';
import 'package:flutter/material.dart';

class KartuStockProvider extends ChangeNotifier {
  final KartuStockRepository _repo = KartuStockRepository();

  // --- Kartu Stock (ledger detail) ---
  List<KartuStockModel> _listKartuStock = [];
  List<KartuStockModel> get listKartuStock => _listKartuStock;

  List<KartuStockModel> _filteredKartuStock = [];
  List<KartuStockModel> get filteredKartuStock => _filteredKartuStock;

  // --- Stock Warehouse Report ---
  List<StockWarehouseModel> _listStockWarehouse = [];
  List<StockWarehouseModel> get listStockWarehouse => _listStockWarehouse;

  List<StockWarehouseModel> _filteredStockWarehouse = [];
  List<StockWarehouseModel> get filteredStockWarehouse =>
      _filteredStockWarehouse;

  // --- Warehouse list (untuk filter) ---
  List<CompanyWarehouseModel> _warehouses = [];
  List<CompanyWarehouseModel> get warehouses => _warehouses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingWarehouses = false;
  bool get isLoadingWarehouses => _isLoadingWarehouses;

  double _totalWeight = 0.0;
  double get totalWeight => _totalWeight;

  Future<void> updateTotalWeight() async {
    double total = 0.0;

    for (var item in _listKartuStock) {
      double weightPerItem =
          double.tryParse(item.weightPerUnit?.toString() ?? '0') ?? 0.0;

      num qIn = item.qtyIn ?? 0;
      num qOut = item.qtyOut ?? 0;

      double totalWeightIn = qIn * weightPerItem;
      double totalWeightOut = qOut * weightPerItem;

      total += (totalWeightIn - totalWeightOut);
    }

    _totalWeight = total;
    notifyListeners();
  }

  Future<void> fetchRecapStock({
    required String token,
    required String startDate,
    required String endDate,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _repo.fetchRecapStock(
        token: token,
        startDate: startDate,
        endDate: endDate,
      );

      final Map<String, KartuStockModel> grouped = {};
      for (var item in data) {
        grouped[item.itemCode ?? ''] = item;
      }
      _listKartuStock = grouped.values.toList();
      _filteredKartuStock = grouped.values.toList();
      await updateTotalWeight();
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStockWarehouseReport({
    required String token,
    required String startDate,
    required String endDate,
    List<String> warehouseIds = const [],
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _repo.fetchStockWarehouseReport(
        token: token,
        startDate: startDate,
        endDate: endDate,
        warehouseIds: warehouseIds,
      );
      _listStockWarehouse = data;
      _filteredStockWarehouse = List.from(data);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWarehouses({required String token}) async {
    if (_warehouses.isNotEmpty) return;
    _isLoadingWarehouses = true;
    notifyListeners();
    try {
      _warehouses = await _repo.fetchAllWarehouses(token: token);
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal fetch warehouses: $e');
    } finally {
      _isLoadingWarehouses = false;
      notifyListeners();
    }
  }

  void searchKartuStock(String query) {
    if (query.isEmpty) {
      _filteredKartuStock = List.from(_listKartuStock);
    } else {
      _filteredKartuStock = _listKartuStock.where((element) {
        final code = element.itemCode?.toLowerCase() ?? "";
        final name = element.itemName?.toLowerCase() ?? "";
        final searchText = query.toLowerCase();
        return code.contains(searchText) || name.contains(searchText);
      }).toList();
    }
    notifyListeners();
  }

  void searchStockWarehouse(String query) {
    if (query.isEmpty) {
      _filteredStockWarehouse = List.from(_listStockWarehouse);
    } else {
      _filteredStockWarehouse = _listStockWarehouse.where((element) {
        final code = element.itemCode?.toLowerCase() ?? "";
        final name = element.itemName?.toLowerCase() ?? "";
        final warehouse = element.warehouseName?.toLowerCase() ?? "";
        final searchText = query.toLowerCase();
        return code.contains(searchText) ||
            name.contains(searchText) ||
            warehouse.contains(searchText);
      }).toList();
    }
    notifyListeners();
  }
}
