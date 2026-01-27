import 'package:bbs_gudang/data/models/transfer_warehouse/transfer_warehouse_detail.dart';

class TransferWarehouseModel {
  final String id;
  final String unitBusinessId;
  final String code;
  final String sourceWarehouseId;
  final String destinationWarehouseId;
  final String status;
  final int? tonnage;
  final String? notes;
  final DateTime date;

  final UnitBusinessModel unitBusiness;
  final WarehouseModel sourceWarehouse;
  final WarehouseModel destinationWarehouse;
  final List<TransferWarehouseDetail> details;

  TransferWarehouseModel({
    required this.id,
    required this.unitBusinessId,
    required this.code,
    required this.sourceWarehouseId,
    required this.destinationWarehouseId,
    required this.status,
    this.tonnage,
    this.notes,
    required this.date,
    required this.unitBusiness,
    required this.sourceWarehouse,
    required this.destinationWarehouse,
    required this.details,
  });

  factory TransferWarehouseModel.fromJson(Map<String, dynamic> json) {
    return TransferWarehouseModel(
      id: json['id'],
      unitBusinessId: json['unit_bussiness_id'],
      code: json['code'],
      sourceWarehouseId: json['source_warehouse_id'],
      destinationWarehouseId: json['destination_warehouse_id'],
      status: json['status'],
      tonnage: json['tonnage'],
      notes: json['notes'],
      date: DateTime.parse(json['date']),
      unitBusiness: UnitBusinessModel.fromJson(json['m_unit_bussiness']),
      sourceWarehouse: WarehouseModel.fromJson(json['source_warehouse']),
      destinationWarehouse: WarehouseModel.fromJson(
        json['destination_warehouse'],
      ),

      details: json['t_inventory_transfer_warehouse_ds'] == null
          ? []
          : (json['t_inventory_transfer_warehouse_ds'] as List)
                .map((e) => TransferWarehouseDetail.fromJson(e))
                .toList(),
    );
  }
}

class WarehouseModel {
  final String id;
  final String name;

  WarehouseModel({required this.id, required this.name});

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(id: json['id'], name: json['name']);
  }
}

class UnitBusinessModel {
  final String id;
  final String name;

  UnitBusinessModel({required this.id, required this.name});

  factory UnitBusinessModel.fromJson(Map<String, dynamic> json) {
    return UnitBusinessModel(id: json['id'], name: json['name']);
  }
}
