import 'package:bbs_gudang/data/models/kartu_stock/kartu_stock_model.dart';
import 'package:bbs_gudang/data/services/kartu_stock/kartu_stock_repository.dart';
import 'package:flutter/material.dart';

class KartuStockProvider extends ChangeNotifier {
  KartuStockRepository _repo = KartuStockRepository();

  List<KartuStockModel> _listKartuStock = [];
  List<KartuStockModel> get listKartuStock => _listKartuStock;

  List<KartuStockModel> _filteredKartuStock = [];
  List<KartuStockModel> get filteredKartuStock => _filteredKartuStock;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double _totalWeight = 0.0;
  double get totalWeight => _totalWeight;

  Future<void> updateTotalWeight() async {
    double total = 0.0;

    for (var item in _listKartuStock) {
      double weightPerItem =
          double.tryParse(item.weightPerUnit?.toString() ?? '0') ?? 0.0;

      // 2. Ambil Qty In dan Qty Out
      num qIn = item.qtyIn ?? 0;
      num qOut = item.qtyOut ?? 0;

      // 3. Hitung berat masuk dan berat keluar
      double totalWeightIn = qIn * weightPerItem;
      double totalWeightOut = qOut * weightPerItem;

      // 4. Akumulasi ke total (Masuk menambah, Keluar mengurangi)
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

      _listKartuStock = data;
      _filteredKartuStock = data;
      await updateTotalWeight();
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
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
}
