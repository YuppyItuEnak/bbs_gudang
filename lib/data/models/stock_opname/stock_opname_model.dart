import 'package:bbs_gudang/data/models/stock_opname/stock_opname_detail.dart';

class StockOpnameModel {
  final String id;

  /// FK
  final String unitBusinessId;
  final String warehouseId;

  /// Data utama
  final String code;
  final String status;
  final DateTime date;
  final String picName;
  final String picId;
  final String notes;
  final int editCount;

  /// Optional FK lainnya
  final String? itemGroupId;
  final String? itemKindId;
  final String? groupId;
  final String? itemDivisionId;
  final String? submittedBy;
  final String? itemGroupCoaId;

  /// RELATION (OPTIONAL)
  final WarehouseModel? warehouse;
  final UnitBusinessModel? unitBusiness;

  /// DETAIL
  final List<StockOpnameDetailModel> details;

  StockOpnameModel({
    required this.id,
    required this.unitBusinessId,
    required this.warehouseId,
    required this.code,
    required this.status,
    required this.date,
    required this.picName,
    required this.picId,
    required this.notes,
    required this.editCount,
    this.itemGroupId,
    this.itemKindId,
    this.groupId,
    this.itemDivisionId,
    this.submittedBy,
    this.itemGroupCoaId,
    this.warehouse,
    this.unitBusiness,
    required this.details,
  });

  factory StockOpnameModel.fromJson(Map<String, dynamic> json) {
    return StockOpnameModel(
      id: json['id'] ?? '',

      unitBusinessId: json['unit_bussiness_id'] ?? '',
      warehouseId: json['warehouse_id'] ?? '',

      code: json['code'] ?? '',
      status: json['status'] ?? 'DRAFT',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      picName: json['pic_name'] ?? '-',
      picId: json['pic_id'] ?? '',
      notes: json['notes'] ?? '',
      editCount: json['edit_count'] ?? 0,

      itemGroupId: json['item_group_id'],
      itemKindId: json['item_kind_id'],
      groupId: json['group_id'],
      itemDivisionId: json['item_division_id'],
      submittedBy: json['submitted_by'],
      itemGroupCoaId: json['item_group_coa_id'],

      /// RELATION (JANGAN DIPAKSA ADA)
      warehouse: json['m_warehouse'] != null
          ? WarehouseModel.fromJson(json['m_warehouse'])
          : null,

      unitBusiness: json['m_unit_bussiness'] != null
          ? UnitBusinessModel.fromJson(json['m_unit_bussiness'])
          : null,

      /// DETAIL
      details: json['t_inventory_s_opname_ds'] == null
          ? []
          : (json['t_inventory_s_opname_ds'] as List)
                .map((e) => StockOpnameDetailModel.fromJson(e))
                .toList(),
    );
  }
}

class WarehouseModel {
  final String id;
  final String name;
  final String notes;
  final bool status;

  WarehouseModel({
    required this.id,
    required this.name,
    required this.notes,
    required this.status,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'],
      name: json['name'],
      notes: json['notes'] ?? '',
      status: json['status'] ?? false,
    );
  }
}

class UnitBusinessModel {
  final String id;
  final String code;
  final String name;
  final String address;
  final bool status;

  UnitBusinessModel({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.status,
  });

  factory UnitBusinessModel.fromJson(Map<String, dynamic> json) {
    return UnitBusinessModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      address: json['address'] ?? '',
      status: json['status'] ?? false,
    );
  }
}
