import 'package:bbs_gudang/data/models/item/item_model.dart';
import 'package:bbs_gudang/data/services/item_repository.dart';
import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  final ItemRepository _itemRepository = ItemRepository();
  List<ItemModel> _products = [];
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  bool _hasMore = true;

  List<ItemModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> fetchProducts({
    required String token,
    required String itemDivisionId,
    String? search,
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      _products = [];
      _page = 1;
      _hasMore = true;
    }

    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;

    try {
      final newProducts = await _itemRepository.fetchItems(
        search: search,
        token: token,
        itemDivisionId: itemDivisionId,
        page: _page,
      );
      if (newProducts.isEmpty) {
        _hasMore = false;
      } else {
        _products.addAll(newProducts);
        _page++;
      }
    } catch (e) {
      _error = 'Failed to fetch products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
