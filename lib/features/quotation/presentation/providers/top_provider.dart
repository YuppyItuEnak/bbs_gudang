import 'package:bbs_gudang/data/models/m_gen_model.dart';
import 'package:bbs_gudang/data/services/m_gen_repository.dart';
import 'package:flutter/material.dart';

class TopProvider with ChangeNotifier {
  final MGenRepository _mGenRepository = MGenRepository();
  List<MGenModel> _topOptions = [];
  bool _isLoading = false;
  String? _error;

  List<MGenModel> get topOptions => _topOptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTopOptions(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _topOptions = await _mGenRepository.fetchMGen('group=m_top_sales_quotation', token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to fetch ToP options: $e';
      notifyListeners();
    }
  }
}
