class StockAdjustmentDetail {
  final String id;
  final String itemCode;
  final String reason;
  final double qtyBefore;
  final double qtyAfter;
  final double adjustment;
  final Item? item;

  StockAdjustmentDetail({
    required this.id,
    required this.itemCode,
    required this.reason,
    required this.qtyBefore,
    required this.qtyAfter,
    required this.adjustment,
    this.item,
  });

  factory StockAdjustmentDetail.fromJson(Map<String, dynamic> json) {
    return StockAdjustmentDetail(
      id: json['id'],
      itemCode: json['item_code'],
      reason: json['reason'] ?? '',
      qtyBefore: (json['qty_before'] as num).toDouble(),
      qtyAfter: (json['qty_after'] as num).toDouble(),
      adjustment: (json['adjustment'] as num).toDouble(),
      item: json['m_item'] != null ? Item.fromJson(json['m_item']) : null,
    );
  }
}

class Item {
  final String id;
  final String code;
  final String name;

  Item({required this.id, required this.code, required this.name});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(id: json['id'], code: json['code'], name: json['name']);
  }
}
