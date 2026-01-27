import 'package:bbs_gudang/data/models/list_item/list_item_model.dart';
import 'package:bbs_gudang/data/services/item/item_barang_repository.dart';
import 'package:flutter/material.dart';

class ItemBarangProvider extends ChangeNotifier {
  final ItemBarangRepository repository = ItemBarangRepository();

  final List<ItemBarangModel> _items = [];
  List<ItemBarangModel> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  // FILTER STATE
  String? filterCode;
  String? filterName;
  String? filterStatus;
  String? itemType;
  String? itemGroup;
  String? itemDivision;

  Future<void> fetchItems({
    required String token,
    bool refresh = false,
    bool nextPage = false,

    String? code,
    String? name,
    String? status,
    String? type,
    String? group,
    String? division,
  }) async {
    if (_isLoading) return;

    // REFRESH / FILTER BARU
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _items.clear();

      filterCode = code;
      filterName = name;
      filterStatus = status;
      itemType = type;
      itemGroup = group;
      itemDivision = division;
    }

    // NEXT PAGE
    if (nextPage) {
      if (!_hasMore) return;
      _page++;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await repository.fetchListBarang(
        token: token,
        page: _page,
        filterCode: filterCode,
        filterName: filterName,
        filterStatus: filterStatus,
        itemType: itemType,
        itemGroup: itemGroup,
        itemDivision: itemDivision,
      );

      final List<ItemBarangModel> newItems = result['items'];
      final pagination = result['pagination'];

      // TAMBAH DATA
      _items.addAll(newItems);

      // CONTROL HAS MORE
      final int currentPage = pagination['page'];
      final int totalPages = pagination['totalPages'];

      _hasMore = currentPage < totalPages;

      debugPrint(
        "PAGE LOADED: $currentPage | TOTAL ITEM SEKARANG: ${_items.length} | HAS MORE: $_hasMore",
      );
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("❌ FETCH ITEM ERROR: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
