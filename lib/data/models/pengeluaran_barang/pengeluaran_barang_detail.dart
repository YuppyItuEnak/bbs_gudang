class PengeluaranBarangDetail {
  final String id;
  final String suratJalanId;
  final String itemId;
  final int qty;
  final int price;
  final int amount;
  final int weight;
  final int qtyReturn;
  final String? itemName;
  final int qtySnapshot;
  final String uomUnit;
  final int uomValue;
  final String uomId;
  final int qtyInventory;
  final double resultCogs;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MItemModel? item;

  PengeluaranBarangDetail({
    required this.id,
    required this.suratJalanId,
    required this.itemId,
    required this.qty,
    required this.price,
    required this.amount,
    required this.weight,
    required this.qtyReturn,
    this.itemName,
    required this.qtySnapshot,
    required this.uomUnit,
    required this.uomValue,
    required this.uomId,
    required this.qtyInventory,
    required this.resultCogs,
    required this.createdAt,
    required this.updatedAt,
    this.item,
  });

  factory PengeluaranBarangDetail.fromJson(Map<String, dynamic> json) {
    return PengeluaranBarangDetail(
      id: json['id'],
      suratJalanId: json['surat_jalan_id'],
      itemId: json['item_id'],
      qty: json['qty'],
      price: json['price'],
      amount: json['amount'],
      weight: json['weight'],
      qtyReturn: json['qty_return'],
      itemName: json['item_name'],
      qtySnapshot: json['qty_snapshot'],
      uomUnit: json['uom_unit'],
      uomValue: json['uom_value'],
      uomId: json['uom_id'],
      qtyInventory: json['qty_inventory'],
      resultCogs: (json['result_cogs'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      item: json['m_item'] != null
          ? MItemModel.fromJson(json['m_item'])
          : null,
    );
  }
}


class MItemModel {
  final String id;
  final String code;
  final String name;
  final bool isActive;
  final String itemTypeName;
  final String itemDivisionName;
  final String itemGroupName;
  final String alias;
  final String? dimension;
  final String? thickness;
  final String? length;
  final String? type;
  final String? size;
  final double? actualWeight;
  final double? marketingWeight;
  final String photo;
  final String status;
  final bool isUsed;
  final DateTime createdAt;
  final DateTime updatedAt;

  MItemModel({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    required this.itemTypeName,
    required this.itemDivisionName,
    required this.itemGroupName,
    required this.alias,
    this.dimension,
    this.thickness,
    this.length,
    this.type,
    this.size,
    this.actualWeight,
    this.marketingWeight,
    required this.photo,
    required this.status,
    required this.isUsed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MItemModel.fromJson(Map<String, dynamic> json) {
    return MItemModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      isActive: json['is_active'],
      itemTypeName: json['item_type_name'],
      itemDivisionName: json['item_division_name'],
      itemGroupName: json['item_group_name'],
      alias: json['alias'],
      dimension: json['dimension'],
      thickness: json['thickness'],
      length: json['length'],
      type: json['type'],
      size: json['size'],
      actualWeight: json['actual_weight'] != null
          ? (json['actual_weight'] as num).toDouble()
          : null,
      marketingWeight: json['marketing_weight'] != null
          ? (json['marketing_weight'] as num).toDouble()
          : null,
      photo: json['photo'],
      status: json['status'],
      isUsed: json['is_used'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
