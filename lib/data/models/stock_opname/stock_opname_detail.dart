class StockOpnameDetailModel {
  final String id;
  final String itemCode;
  final int opnameQty;
  final int currentQty;
  final ItemModel? item;

  StockOpnameDetailModel({
    required this.id,
    required this.itemCode,
    required this.opnameQty,
    required this.currentQty,
    this.item,
  });

  factory StockOpnameDetailModel.fromJson(Map<String, dynamic> json) {
    return StockOpnameDetailModel(
      id: json['id'] ?? '',
      itemCode: json['item_code'] ?? '',
      opnameQty: json['opname_qty'] ?? 0,
      currentQty: json['current_on_hand_quantity'] ?? 0,
      item: json['stockOpnameDetailItem'] != null
          ? ItemModel.fromJson(json['stockOpnameDetailItem'])
          : null,
    );
  }

  int get selisih => opnameQty - currentQty;
  bool get isOverstock => opnameQty > currentQty;
  bool get isUnderstock => opnameQty < currentQty;
}


class ItemModel {
  final String id;
  final String code;
  final String name;
  final String itemTypeName;
  final String itemGroupName;
  final int minStock;
  final int maxStock;
  final double actualWeight;
  final double marketingWeight;
  final bool isActive;

  ItemModel({
    required this.id,
    required this.code,
    required this.name,
    required this.itemTypeName,
    required this.itemGroupName,
    required this.minStock,
    required this.maxStock,
    required this.actualWeight,
    required this.marketingWeight,
    required this.isActive,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '-',
      itemTypeName: json['item_type_name'] ?? '-',
      itemGroupName: json['item_group_name'] ?? '-',
      minStock: json['min_stock'] ?? 0,
      maxStock: json['max_stock'] ?? 0,
      actualWeight: (json['actual_weight'] ?? 0).toDouble(),
      marketingWeight: (json['marketing_weight'] ?? 0).toDouble(),
      isActive: json['is_active'] ?? false,
    );
  }
}
