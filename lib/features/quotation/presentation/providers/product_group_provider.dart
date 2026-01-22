import 'package:bbs_gudang/data/models/m_gen_model.dart';
import 'package:bbs_gudang/data/services/m_gen_repository.dart';
import 'package:flutter/material.dart';

class ProductGroupProvider with ChangeNotifier {
  final MGenRepository _mGenRepository = MGenRepository();
  List<MGenModel> _productGroups = [];
  bool _isLoading = false;
  String? _error;

  List<MGenModel> get productGroups => _productGroups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProductGroups(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _productGroups =
          await _mGenRepository.fetchMGen('group=m_item_division', token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to fetch product groups: $e';
      notifyListeners();
    }
  }
}
