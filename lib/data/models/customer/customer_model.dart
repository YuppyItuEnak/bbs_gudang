class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String? notes;
  final String unitBussinessId;
  final String topId;
  final String nameTypeId;
  final String contactPerson;
  final bool isActive;
  final String groupId;
  final bool pn;
  final bool isThirdParty;
  final String coaId;
  final String phone;
  final String salesAreaId;
  final String salesId;
  final String code;
  final double? latitude;
  final double? longitude;
  final String? prospekId;
  final int status;
  final int currentApprovalLevel;
  final int? revisedCount;
  final int approvalCount;
  final int approvedCount;
  final DateTime? requestApprovalAt;
  final String? requestApprovalBy;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    this.notes,
    required this.unitBussinessId,
    required this.topId,
    required this.nameTypeId,
    required this.contactPerson,
    required this.isActive,
    required this.groupId,
    required this.pn,
    required this.isThirdParty,
    required this.coaId,
    required this.phone,
    required this.salesAreaId,
    required this.salesId,
    required this.code,
    this.latitude,
    this.longitude,
    this.prospekId,
    required this.status,
    required this.currentApprovalLevel,
    this.revisedCount,
    required this.approvalCount,
    required this.approvedCount,
    this.requestApprovalAt,
    this.requestApprovalBy,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      notes: json['notes'],
      unitBussinessId: json['unit_bussiness_id'],
      topId: json['top_id'],
      nameTypeId: json['name_type_id'],
      contactPerson: json['contact_person'],
      isActive: json['is_active'],
      groupId: json['group_id'],
      pn: json['pn'],
      isThirdParty: json['is_third_party'],
      coaId: json['coa_id'],
      phone: json['phone'],
      salesAreaId: json['sales_area_id'],
      salesId: json['sales_id'],
      code: json['code'],
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      prospekId: json['prospek_id'],
      status: json['status'],
      currentApprovalLevel: json['current_approval_level'],
      revisedCount: json['revised_count'],
      approvalCount: json['approval_count'],
      approvedCount: json['approved_count'],
      requestApprovalAt: json['request_approval_at'] != null
          ? DateTime.parse(json['request_approval_at'])
          : null,
      requestApprovalBy: json['request_approval_by'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'notes': notes,
      'unit_bussiness_id': unitBussinessId,
      'top_id': topId,
      'name_type_id': nameTypeId,
      'contact_person': contactPerson,
      'is_active': isActive,
      'group_id': groupId,
      'pn': pn,
      'is_third_party': isThirdParty,
      'coa_id': coaId,
      'phone': phone,
      'sales_area_id': salesAreaId,
      'sales_id': salesId,
      'code': code,
      'latitude': latitude,
      'longitude': longitude,
      'prospek_id': prospekId,
      'status': status,
      'current_approval_level': currentApprovalLevel,
      'revised_count': revisedCount,
      'approval_count': approvalCount,
      'approved_count': approvedCount,
      'request_approval_at': requestApprovalAt?.toIso8601String(),
      'request_approval_by': requestApprovalBy,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
