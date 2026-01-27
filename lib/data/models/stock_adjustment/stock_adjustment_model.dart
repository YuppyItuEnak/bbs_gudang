import 'package:bbs_gudang/data/models/stock_adjustment/stock_adjustment_detail.dart';
// import 'package:bbs_gudang/data/models/stock_opname/stock_opname_detail.dart';

class StockAdjustmentModel {
  final String id;
  final String code;
  final String status;
  final String unitBusinessId;
  final String date;
  final String warehouseId;
  final String? opnameId;
  final String? notes;

  final int? approvalCount;
  final int? approvedCount;
  final int? currentApprovalLevel;

  final String? submittedBy;
  final double? totalDiff;
  final int? ioMultiplier;

  final List<StockAdjustmentDetail> details;
  final UnitBusinessModel? unitBusiness;
  final WarehouseModel? warehouse;
  final StockOpnameRefModel? opname;
  final UserModel? user;

  StockAdjustmentModel({
    required this.id,
    required this.code,
    required this.status,
    required this.unitBusinessId,
    required this.date,
    required this.warehouseId,
    required this.details,
    this.opnameId,
    this.notes,
    this.approvalCount,
    this.approvedCount,
    this.currentApprovalLevel,
    this.submittedBy,
    this.totalDiff,
    this.ioMultiplier,
    this.unitBusiness,
    this.warehouse,
    this.opname,
    this.user,
  });

  factory StockAdjustmentModel.fromJson(Map<String, dynamic> json) {
    return StockAdjustmentModel(
      id: json['id'],
      code: json['code'],
      status: json['status'],
      unitBusinessId: json['unit_bussiness_id'],
      date: json['date'],
      details: (json['t_inventory_s_adjustment_ds'] as List)
          .map((i) => StockAdjustmentDetail.fromJson(i))
          .toList(),
      warehouseId: json['warehouse_id'],
      opnameId: json['opname_id'],
      notes: json['notes'],

      approvalCount: json['approval_count'],
      approvedCount: json['approved_count'],
      currentApprovalLevel: json['current_approval_level'],

      submittedBy: json['submitted_by'],
      totalDiff: json['total_diff']?.toDouble(),
      ioMultiplier: json['io_multiplier'],

      unitBusiness: json['m_unit_bussiness'] != null
          ? UnitBusinessModel.fromJson(json['m_unit_bussiness'])
          : null,
      warehouse: json['m_warehouse'] != null
          ? WarehouseModel.fromJson(json['m_warehouse'])
          : null,
      opname: json['t_inventory_s_opname'] != null
          ? StockOpnameRefModel.fromJson(json['t_inventory_s_opname'])
          : null,
      user: json['user_default'] != null
          ? UserModel.fromJson(json['user_default'])
          : null,
    );
  }
}

/// Nested Models
class UnitBusinessModel {
  final String id;
  final String name;
  UnitBusinessModel({required this.id, required this.name});
  factory UnitBusinessModel.fromJson(Map<String, dynamic> json) =>
      UnitBusinessModel(id: json['id'], name: json['name']);
}

class WarehouseModel {
  final String id;
  final String name;
  WarehouseModel({required this.id, required this.name});
  factory WarehouseModel.fromJson(Map<String, dynamic> json) =>
      WarehouseModel(id: json['id'], name: json['name']);
}

class StockOpnameRefModel {
  final String id;
  final String code;
  StockOpnameRefModel({required this.id, required this.code});
  factory StockOpnameRefModel.fromJson(Map<String, dynamic> json) =>
      StockOpnameRefModel(id: json['id'], code: json['code']);
}

class UserModel {
  final String id;
  final String name;
  UserModel({required this.id, required this.name});
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(id: json['id'], name: json['name']);
}
