class PurchaseRequestModel {
  String? id;
  String? unitBussinessId;
  String? code;
  String? divisionId;
  String? notes;
  String? revisionReason;
  String? rejectReason;
  String? itemTypeId;
  String? status;
  String? date;
  String? dateRequired;
  String? dateExpired;
  int? currentApprovalLevel;
  int? revisedCount;
  int? approvalCount;
  int? approvedCount;
  String? unitBussinessName;
  String? division;
  String? itemType;
  String? submittedBy;
  String? submittedAt;
  String? createdBy;
  String? updatedBy;
  String? itemGroupCoaId;
  String? itemGroupCoa;
  String? createdAt;
  String? updatedAt;

  List<PurchaseRequestDetailModel>? purchaseRequestDetails;
  PurchaseRequestDivisionModel? purchaseRequestDivision;
  dynamic purchaseRequestItemType;

  PurchaseRequestModel({
    this.id,
    this.unitBussinessId,
    this.code,
    this.divisionId,
    this.notes,
    this.revisionReason,
    this.rejectReason,
    this.itemTypeId,
    this.status,
    this.date,
    this.dateRequired,
    this.dateExpired,
    this.currentApprovalLevel,
    this.revisedCount,
    this.approvalCount,
    this.approvedCount,
    this.unitBussinessName,
    this.division,
    this.itemType,
    this.submittedBy,
    this.submittedAt,
    this.createdBy,
    this.updatedBy,
    this.itemGroupCoaId,
    this.itemGroupCoa,
    this.createdAt,
    this.updatedAt,
    this.purchaseRequestDetails,
    this.purchaseRequestDivision,
    this.purchaseRequestItemType,
  });

  factory PurchaseRequestModel.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestModel(
      id: json['id'] ?? '',
      unitBussinessId: json['unit_bussiness_id'] ?? '',
      code: json['code'] ?? '',
      divisionId: json['division_id'] ?? '',
      notes: json['notes'] ?? '',
      revisionReason: json['revision_reason'] ?? '',
      rejectReason: json['reject_reason'] ?? '',
      itemTypeId: json['item_type_id'] ?? '',
      status: json['status'] ?? '',
      date: json['date'] ?? '',
      dateRequired: json['date_required'] ?? '',
      dateExpired: json['date_expired'] ?? '',
      currentApprovalLevel: json['current_approval_level'] ?? 0,
      revisedCount: json['revised_count'] ?? 0,
      approvalCount: json['approval_count'] ?? 0,
      approvedCount: json['approved_count'] ?? 0,
      unitBussinessName: json['unit_bussiness_name'] ?? '',
      division: json['division'] ?? '',
      itemType: json['item_type'] ?? '',
      submittedBy: json['submitted_by'] ?? '',
      submittedAt: json['submitted_at'] ?? '',
      createdBy: json['createdBy'] ?? '',
      updatedBy: json['updatedBy'] ?? '',
      itemGroupCoaId: json['item_group_coa_id'] ?? '',
      itemGroupCoa: json['item_group_coa'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',

      purchaseRequestDetails: (json['purchaseRequestDetails'] as List? ?? [])
          .map((e) => PurchaseRequestDetailModel.fromJson(e))
          .toList(),

      purchaseRequestDivision: json['purchaseRequestDivision'] != null
          ? PurchaseRequestDivisionModel.fromJson(
              json['purchaseRequestDivision'],
            )
          : PurchaseRequestDivisionModel(),

      purchaseRequestItemType: json['purchaseRequestItemType'],
    );
  }
}

class PurchaseRequestDetailModel {
  String? id;
  String? purchaseRequestId;
  String? itemId;
  String? itemUomId;
  int? qty;
  int? onHand;
  String? notes;
  String? itemName;
  String? itemCode;
  String? itemUom;
  String? assetId;
  String? itemType;
  String? createdAt;
  String? updatedAt;

  PurchaseRequestDetailItemModel? purchaseRequestDetailItem;

  PurchaseRequestDetailModel({
    this.id,
    this.purchaseRequestId,
    this.itemId,
    this.itemUomId,
    this.qty,
    this.onHand,
    this.notes,
    this.itemName,
    this.itemCode,
    this.itemUom,
    this.assetId,
    this.itemType,
    this.createdAt,
    this.updatedAt,
    this.purchaseRequestDetailItem,
  });

  factory PurchaseRequestDetailModel.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestDetailModel(
      id: json['id'] ?? '',
      purchaseRequestId: json['purchase_request_id'] ?? '',
      itemId: json['item_id'] ?? '',
      itemUomId: json['item_uom_id'] ?? '',

      qty: (json['qty'] as num?)?.toInt() ?? 0,
      onHand: (json['on_hand'] as num?)?.toInt() ?? 0,

      notes: json['notes'] ?? '',
      itemName: json['item_name'] ?? '',
      itemCode: json['item_code'] ?? '',
      itemUom: json['item_uom'] ?? '',
      assetId: json['asset_id'] ?? '',
      itemType: json['item_type'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',

      purchaseRequestDetailItem: json['purchaseRequestDetailItem'] != null
          ? PurchaseRequestDetailItemModel.fromJson(
              json['purchaseRequestDetailItem'],
            )
          : PurchaseRequestDetailItemModel(),
    );
  }
}

class PurchaseRequestDetailItemModel {
  String? id;
  String? code;
  String? name;
  bool? isActive;
  String? itemTypeId;
  String? itemTypeName;
  String? itemDivision;
  String? itemKindId;
  String? itemGroupId;
  String? itemGroupName;
  String? groupId;
  String? itemUomId;
  String? alias;
  dynamic dimension;
  dynamic thickness;
  dynamic length;
  dynamic type;
  dynamic size;
  int? excessToleran;
  double? actualWeight;
  double? marketingWeig;
  int? minStock;
  int? maxStock;
  dynamic photo;
  dynamic file;
  dynamic notes;
  bool? isBatch;
  bool? isBundle;
  String? thicknessId;
  String? lengthId;
  String? itemGroupCoa;
  int? revisedCount;
  int? approvalCount;
  int? approvedCount;
  String? status;
  bool? isUsed;
  String? createdAt;
  String? updatedAt;

  PurchaseRequestDetailItemModel({
    this.id,
    this.code,
    this.name,
    this.isActive,
    this.itemTypeId,
    this.itemTypeName,
    this.itemDivision,
    this.itemKindId,
    this.itemGroupId,
    this.itemGroupName,
    this.groupId,
    this.itemUomId,
    this.alias,
    this.dimension,
    this.thickness,
    this.length,
    this.type,
    this.size,
    this.excessToleran,
    this.actualWeight,
    this.marketingWeig,
    this.minStock,
    this.maxStock,
    this.photo,
    this.file,
    this.notes,
    this.isBatch,
    this.isBundle,
    this.thicknessId,
    this.lengthId,
    this.itemGroupCoa,
    this.revisedCount,
    this.approvalCount,
    this.approvedCount,
    this.status,
    this.isUsed,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseRequestDetailItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestDetailItemModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      isActive: json['is_active'] ?? false,
      itemTypeId: json['item_type_id'] ?? '',
      itemTypeName: json['item_type_name'] ?? '',
      itemDivision: json['item_division_'] ?? '',
      itemKindId: json['item_kind_id'] ?? '',
      itemGroupId: json['item_group_id'] ?? '',
      itemGroupName: json['item_group_nam'] ?? '',
      groupId: json['group_id'] ?? '',
      itemUomId: json['item_uom_id'] ?? '',
      alias: json['alias'] ?? '',
      dimension: json['dimension'],
      thickness: json['thickness'],
      length: json['length'],
      type: json['type'],
      size: json['size'],
      excessToleran: (json['excess_toleran'] as num?)?.toInt() ?? 0,
      actualWeight: (json['actual_weight'] as num?)?.toDouble() ?? 0.0,
      marketingWeig: (json['marketing_weig'] as num?)?.toDouble() ?? 0.0,
      minStock: (json['min_stock'] as num?)?.toInt() ?? 0,
      maxStock: (json['max_stock'] as num?)?.toInt() ?? 0,
      photo: json['photo'],
      file: json['file'],
      notes: json['notes'],
      isBatch: json['is_batch'] ?? false,
      isBundle: json['is_bundle'] ?? false,
      thicknessId: json['thickness_id'] ?? '',
      lengthId: json['length_id'] ?? '',
      itemGroupCoa: json['item_group_coa'] ?? '',
      revisedCount: (json['revised_count'] as num?)?.toInt() ?? 0,
      approvalCount: (json['approval_count'] as num?)?.toInt() ?? 0,
      approvedCount: (json['approved_count'] as num?)?.toInt() ?? 0,
      status: json['status'] ?? '',
      isUsed: json['is_used'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class PurchaseRequestDivisionModel {
  String? id;
  String? value1;

  PurchaseRequestDivisionModel({this.id, this.value1});

  factory PurchaseRequestDivisionModel.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestDivisionModel(
      id: json['id'] ?? '',
      value1: json['value1'] ?? '',
    );
  }
}
