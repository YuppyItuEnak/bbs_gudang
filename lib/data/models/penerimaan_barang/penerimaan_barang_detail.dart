class PenerimaanBarangDetailModel {
  final String id;
  final int? qtyReceipt;
  final int? qtyReceived;
  final String? notes;

  final PbDetailItemModel? item;
  final PbDetailPrDetailModel? prDetail;
  final PbDetailPurchaseOrderDetailModel? poDetail;

  PenerimaanBarangDetailModel({
    required this.id,
    this.qtyReceipt,
    this.qtyReceived,
    this.notes,
    this.item,
    this.prDetail,
    this.poDetail,
  });

  factory PenerimaanBarangDetailModel.fromJson(Map<String, dynamic> json) {
    return PenerimaanBarangDetailModel(
      id: json['id'] ?? '',
      qtyReceipt: json['qty_receipt'],
      qtyReceived: json['qty_received'],
      notes: json['notes'],

      item: json['pbDetailItem'] != null
          ? PbDetailItemModel.fromJson(json['pbDetailItem'])
          : null,

      prDetail: json['pbDetailPrDetail'] != null
          ? PbDetailPrDetailModel.fromJson(json['pbDetailPrDetail'])
          : null,

      poDetail: json['pbDetailPurchaseOrderDetail'] != null
          ? PbDetailPurchaseOrderDetailModel.fromJson(
              json['pbDetailPurchaseOrderDetail'],
            )
          : null,
    );
  }
}

class PbDetailItemModel {
  final String id;
  final String? code;
  final String? name;
  final int? excessTolerance;
  final String? itemTypeName;
  final String? itemGroupName;

  PbDetailItemModel({
    required this.id,
    this.code,
    this.name,
    this.excessTolerance,
    this.itemTypeName,
    this.itemGroupName,
  });

  factory PbDetailItemModel.fromJson(Map<String, dynamic> json) {
    return PbDetailItemModel(
      id: json['id'] ?? '',
      code: json['code'],
      name: json['name'],
      excessTolerance: json['excess_tolerance'],
      itemTypeName: json['item_type_name'],
      itemGroupName: json['item_group_name'],
    );
  }
}

class PbDetailPrDetailModel {
  final String id;
  final int? qty;
  final String? itemName;
  final String? itemCode;
  final String? itemUom;

  PbDetailPrDetailModel({
    required this.id,
    this.qty,
    this.itemName,
    this.itemCode,
    this.itemUom,
  });

  factory PbDetailPrDetailModel.fromJson(Map<String, dynamic> json) {
    return PbDetailPrDetailModel(
      id: json['id'] ?? '',
      qty: json['qty'],
      itemName: json['item_name'],
      itemCode: json['item_code'],
      itemUom: json['item_uom'],
    );
  }
}

class PbDetailPurchaseOrderDetailModel {
  final String id;
  final int? qty;
  final String? price;
  final String? total;
  final String? itemName;
  final String? itemCode;
  final String? uom;

  PbDetailPurchaseOrderDetailModel({
    required this.id,
    this.qty,
    this.price,
    this.total,
    this.itemName,
    this.itemCode,
    this.uom,
  });

  factory PbDetailPurchaseOrderDetailModel.fromJson(Map<String, dynamic> json) {
    return PbDetailPurchaseOrderDetailModel(
      id: json['id'] ?? '',
      qty: json['qty'],
      price: json['price'],
      total: json['total'],
      itemName: json['item_name'],
      itemCode: json['item_code'],
      uom: json['uom'],
    );
  }
}
