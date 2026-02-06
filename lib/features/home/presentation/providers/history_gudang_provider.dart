import 'package:bbs_gudang/data/models/home/history_gudang_model.dart';
import 'package:bbs_gudang/data/services/home/history_gudang_repository.dart';
import 'package:flutter/material.dart';

class HistoryGudangProvider extends ChangeNotifier {
  final HistoryGudangRepository _historyGudangRepository =
      HistoryGudangRepository();

  bool _isLoading = false;
  String? _errorMessage;
  List<HistoryGudangModel> _listHistory = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<HistoryGudangModel> get listHistory => _listHistory;

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
        startDate: "2026-02-06",
        endDate: "",
      );

      _listHistory = result;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("❌ ERROR FETCH HISTORY GUDANG: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
