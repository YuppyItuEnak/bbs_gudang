import 'package:bbs_gudang/data/models/penerimaan_barang/penerimaan_barang_detail.dart';

class PenerimaanBarangModel {
  final String id;

  final String? unitBussinessId;
  final String? unitBussinessName;
  final String? code;

  final String? itemTypeId;
  final String? purchaseOrderId;

  final String? policeNumber;
  final String? noSjSupplier;
  final String? notes;

  final String? status;
  final DateTime? date;

  final String? supplierId;
  final String? supplierName;

  final String? purchaseRequestId;
  final String? driverName;

  final DateTime? dateSjSupplier;
  final String? warehouseId;

  final String? postedBy;
  final DateTime? postedAt;

  final String? createdBy;
  final String? updatedBy;

  final String? itemGroupCoaId;
  final String? itemGroupCoa;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<PenerimaanBarangDetailModel>?
  details; // List of PenerimaanBarangDetailModel>

  PenerimaanBarangModel({
    required this.id,
    this.unitBussinessId,
    this.unitBussinessName,
    this.code,
    this.itemTypeId,
    this.purchaseOrderId,
    this.policeNumber,
    this.noSjSupplier,
    this.notes,
    this.status,
    this.date,
    this.supplierId,
    this.supplierName,
    this.purchaseRequestId,
    this.driverName,
    this.dateSjSupplier,
    this.warehouseId,
    this.postedBy,
    this.postedAt,
    this.createdBy,
    this.updatedBy,
    this.itemGroupCoaId,
    this.itemGroupCoa,
    this.createdAt,
    this.updatedAt,
    this.details,
  });

  factory PenerimaanBarangModel.fromJson(Map<String, dynamic> json) {
    return PenerimaanBarangModel(
      id: json['id']?.toString() ?? '',

      unitBussinessId: json['unit_bussiness_id'],
      unitBussinessName: json['unit_bussiness_name'],
      code: json['code'],

      itemTypeId: json['item_type_id'],
      purchaseOrderId: json['purchase_order_id'],

      policeNumber: json['police_number'],
      noSjSupplier: json['no_sj_supplier'],
      notes: json['notes'],

      status: json['status'],

      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,

      supplierId: json['supplier_id'],
      supplierName: json['supplier_name'],

      purchaseRequestId: json['purchase_request_id'],
      driverName: json['driver_name'],

      dateSjSupplier: json['date_sj_supplier'] != null
          ? DateTime.tryParse(json['date_sj_supplier'])
          : null,

      warehouseId: json['warehouse_id'],

      postedBy: json['posted_by'],
      postedAt: json['posted_at'] != null
          ? DateTime.tryParse(json['posted_at'])
          : null,

      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],

      itemGroupCoaId: json['item_group_coa_id'],
      itemGroupCoa: json['item_group_coa'],

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      details: json['pbDetailPenerimaanBarangs'] != null
          ? (json['pbDetailPenerimaanBarangs'] as List)
                .map((e) => PenerimaanBarangDetailModel.fromJson(e))
                .toList()
          : [],
    );
  }
}
