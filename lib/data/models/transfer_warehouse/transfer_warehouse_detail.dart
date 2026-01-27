class TransferWarehouseDetail {
  final String id;
  final String itemId;
  final String itemCode;
  final String itemName;
  final int qty;
  final String uom;
  final int weight;
  final String? notes;

  TransferWarehouseDetail({
    required this.id,
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.uom,
    required this.weight,
    this.notes,
  });

  factory TransferWarehouseDetail.fromJson(Map<String, dynamic> json) {
    return TransferWarehouseDetail(
      id: json['id'],
      itemId: json['item_id'],
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      qty: json['qty'] ?? 0,
      uom: json['uom'] ?? '',
      weight: json['weight'] ?? 0,
      notes: json['notes'],
    );
  }
}
