class Quotation {
  final String id;
  final String? unitBussinessId;
  final String code;
  final String? customerId;
  final int status;
  final String date;
  final String? topId;
  final String? salesId;
  final int total;
  final String source;
  final String? notes;
  final String? internalNote;
  final String? addressId;
  final String customerName;
  final String? unitBussiness;
  final String sales;
  final String? shipToName;
  final String? shipToAddress;
  final String? top;
  final int currentApprovalLevel;
  final int revisedCount;
  final int approvalCount;
  final int approvedCount;
  final String createdBy;
  final String updatedBy;
  final String requestApprovalBy;
  final String requestApprovalAt;
  final String? salesArea;
  final String? deliveryAreaId;
  final String? deliveryAreaName;
  final String? expeditionId;
  final String? expeditionName;
  final String ppnType;
  final String ppnTypeText;
  final int ppnValue;
  final int dpp;
  final int dppLainnya;
  final int totalDiscount;
  final int grandTotal;
  final int ppn;
  final bool isUsed;
  final bool? isJasa;
  final String createdAt;
  final String updatedAt;

  Quotation({
    required this.id,
    this.unitBussinessId,
    required this.code,
    this.customerId,
    required this.status,
    required this.date,
    this.topId,
    this.salesId,
    required this.total,
    required this.source,
    this.notes,
    this.internalNote,
    this.addressId,
    required this.customerName,
    this.unitBussiness,
    required this.sales,
    this.shipToName,
    this.shipToAddress,
    this.top,
    required this.currentApprovalLevel,
    required this.revisedCount,
    required this.approvalCount,
    required this.approvedCount,
    required this.createdBy,
    required this.updatedBy,
    required this.requestApprovalBy,
    required this.requestApprovalAt,
    this.salesArea,
    this.deliveryAreaId,
    this.deliveryAreaName,
    this.expeditionId,
    this.expeditionName,
    required this.ppnType,
    required this.ppnTypeText,
    required this.ppnValue,
    required this.dpp,
    required this.dppLainnya,
    required this.totalDiscount,
    required this.grandTotal,
    required this.ppn,
    required this.isUsed,
    this.isJasa,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      id: json['id'] ?? '',
      unitBussinessId: json['unit_bussiness_id'],
      code: json['code'] ?? '',
      customerId: json['customer_id'],
      status: json['status'] ?? 0,
      date: json['date'] ?? '',
      topId: json['top_id'],
      salesId: json['sales_id'],
      total: json['total'] ?? 0,
      source: json['source'] ?? '',
      notes: json['notes'],
      internalNote: json['internal_note'],
      addressId: json['address_id'],
      customerName: json['customer_name'] ?? '',
      unitBussiness: json['unit_bussiness'],
      sales: json['sales'] ?? '',
      shipToName: json['ship_to_name'],
      shipToAddress: json['ship_to_address'],
      top: json['top'],
      currentApprovalLevel: json['current_approval_level'] ?? 0,
      revisedCount: json['revised_count'] ?? 0,
      approvalCount: json['approval_count'] ?? 0,
      approvedCount: json['approved_count'] ?? 0,
      createdBy: json['created_by'] ?? '',
      updatedBy: json['updated_by'] ?? '',
      requestApprovalBy: json['request_approval_by'] ?? '',
      requestApprovalAt: json['request_approval_at'] ?? '',
      salesArea: json['sales_area'],
      deliveryAreaId: json['delivery_area_id'],
      deliveryAreaName: json['delivery_area_name'],
      expeditionId: json['expedition_id'],
      expeditionName: json['expedition_name'],
      ppnType: json['ppn_type'] ?? '',
      ppnTypeText: json['ppn_type_text'] ?? '',
      ppnValue: json['ppn_value'] ?? 0,
      dpp: json['dpp'] ?? 0,
      dppLainnya: json['dpp_lainnya'] ?? 0,
      totalDiscount: json['total_discount'] ?? 0,
      grandTotal: json['grand_total'] ?? 0,
      ppn: json['ppn'] ?? 0,
      isUsed: json['is_used'] ?? false,
      isJasa: json['is_jasa'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unit_bussiness_id': unitBussinessId,
      'code': code,
      'customer_id': customerId,
      'status': status,
      'date': date,
      'top_id': topId,
      'sales_id': salesId,
      'total': total,
      'source': source,
      'notes': notes,
      'internal_note': internalNote,
      'address_id': addressId,
      'customer_name': customerName,
      'unit_bussiness': unitBussiness,
      'sales': sales,
      'ship_to_name': shipToName,
      'ship_to_address': shipToAddress,
      'top': top,
      'current_approval_level': currentApprovalLevel,
      'revised_count': revisedCount,
      'approval_count': approvalCount,
      'approved_count': approvedCount,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'request_approval_by': requestApprovalBy,
      'request_approval_at': requestApprovalAt,
      'sales_area': salesArea,
      'delivery_area_id': deliveryAreaId,
      'delivery_area_name': deliveryAreaName,
      'expedition_id': expeditionId,
      'expedition_name': expeditionName,
      'ppn_type': ppnType,
      'ppn_type_text': ppnTypeText,
      'ppn_value': ppnValue,
      'dpp': dpp,
      'dpp_lainnya': dppLainnya,
      'total_discount': totalDiscount,
      'grand_total': grandTotal,
      'ppn': ppn,
      'is_used': isUsed,
      'is_jasa': isJasa,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Quotation(code: $code, customerName: $customerName, total: $total)';
  }
}
