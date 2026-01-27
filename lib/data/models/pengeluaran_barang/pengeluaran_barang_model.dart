import 'package:bbs_gudang/data/models/pengeluaran_barang/pengeluaran_barang_detail.dart';

class PengeluaranBarangModel {
  final String id;
  final String deliveryPlanId;
  final String date;
  final int status;
  final String unitBussinessId;
  final String code;
  final int printCount;
  final String customerId;
  final String topId;
  final String shipTo;
  final String npwp;
  final String soId;

  final String? unitBussiness; // 🔥 nullable
  final String? customer;
  final String? deliveryArea;
  final String? expeditionType;
  final String? notes;

  final bool siUsed;
  final String createdBy;
  final String? updatedBy;
  final List<PengeluaranBarangDetail> pengeluaranBrgDetail;

  final int? jurnalAmount; // 🔥 nullable numeric
  final bool isTaken;
  final String? takenBy;

  final SalesOrderModel? salesOrder;
  final UnitBussinessModel? unitBussinessModel;
  final CustomerModel? customerModel;
  final DeliveryPlanModel? deliveryPlan;

  PengeluaranBarangModel({
    required this.id,
    required this.deliveryPlanId,
    required this.date,
    required this.status,
    required this.unitBussinessId,
    required this.code,
    required this.printCount,
    required this.customerId,
    required this.topId,
    required this.shipTo,
    required this.npwp,
    required this.soId,
    this.unitBussiness,
    this.customer,
    this.deliveryArea,
    this.expeditionType,
    this.notes,
    required this.siUsed,
    required this.createdBy,
    this.updatedBy,
    required this.pengeluaranBrgDetail,
    this.jurnalAmount,
    required this.isTaken,
    this.takenBy,
    this.salesOrder,
    this.unitBussinessModel,
    this.customerModel,
    this.deliveryPlan,
  });

  factory PengeluaranBarangModel.fromJson(Map<String, dynamic> json) {
    return PengeluaranBarangModel(
      id: json['id'],
      deliveryPlanId: json['delivery_plan_id'],
      date: json['date'],
      status: json['status'],
      unitBussinessId: json['unit_bussiness_id'],
      code: json['code'],
      printCount: json['print_count'],
      customerId: json['customer_id'],
      topId: json['top_id'],
      shipTo: json['ship_to'],
      npwp: json['npwp'] ?? '',
      soId: json['so_id'],

      unitBussiness: json['unit_bussiness'],
      customer: json['customer'],
      deliveryArea: json['delivery_area'],
      expeditionType: json['expedition_type'],
      notes: json['notes'],

      siUsed: json['si_used'] ?? false,
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      pengeluaranBrgDetail: json['t_surat_jalan_ds'] == null
          ? []
          : (json['t_surat_jalan_ds'] as List)
                .map((e) => PengeluaranBarangDetail.fromJson(e))
                .toList(),

      jurnalAmount: json['jurnal_amount'] == null
          ? null
          : (json['jurnal_amount'] as num).toInt(),

      isTaken: json['is_taken'] ?? false,
      takenBy: json['taken_by'],

      salesOrder: json['t_sales_order'] == null
          ? null
          : SalesOrderModel.fromJson(json['t_sales_order']),

      unitBussinessModel: json['m_unit_bussiness'] == null
          ? null
          : UnitBussinessModel.fromJson(json['m_unit_bussiness']),

      customerModel: json['m_customer'] == null
          ? null
          : CustomerModel.fromJson(json['m_customer']),

      deliveryPlan: json['t_delivery_plan'] == null
          ? null
          : DeliveryPlanModel.fromJson(json['t_delivery_plan']),
    );
  }
}

class SalesOrderModel {
  final String id;
  final String code;
  final String date;
  final String estDate;
  final int status;
  final int dpp;
  final int totalDisc;
  final int ppn;
  final int grandTotal;
  final String customerName;
  final String shipToName;

  SalesOrderModel({
    required this.id,
    required this.code,
    required this.date,
    required this.estDate,
    required this.status,
    required this.dpp,
    required this.totalDisc,
    required this.ppn,
    required this.grandTotal,
    required this.customerName,
    required this.shipToName,
  });

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderModel(
      id: json['id'],
      code: json['code'],
      date: json['date'],
      estDate: json['est_date'],
      status: json['status'],
      dpp: (json['dpp'] as num).toInt(),
      totalDisc: (json['total_disc'] as num).toInt(),
      ppn: (json['ppn'] as num).toInt(),
      grandTotal: (json['grand_total'] as num).toInt(),
      customerName: json['customer_name'],
      shipToName: json['ship_to_name'],
    );
  }
}

class UnitBussinessModel {
  final String id;
  final String code;
  final String name;
  final String? address;
  final bool status;

  UnitBussinessModel({
    required this.id,
    required this.code,
    required this.name,
    this.address,
    required this.status,
  });

  factory UnitBussinessModel.fromJson(Map<String, dynamic> json) {
    return UnitBussinessModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      address: json['address'] ?? '',
      status: json['status'],
    );
  }
}

class CustomerModel {
  final String id;
  final String name;
  final String? email; // 🔥 FIX
  final String phone;
  final String code;

  CustomerModel({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    required this.code,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      email: json['email'], // aman walau null
      phone: json['phone'] ?? '', // kadang number/string
      code: json['code'],
    );
  }
}

class DeliveryPlanModel {
  final String id;
  final String code;
  final String date;
  final int status;
  final int total;

  final String? driver;
  final String? unitBussiness;
  final String? deliveryArea;
  final String? expeditionType;
  final String? expedition;
  final String? vehicle;
  final String? notes;
  final String? nopol;

  DeliveryPlanModel({
    required this.id,
    required this.code,
    required this.date,
    required this.status,
    required this.total,
    this.driver,
    this.unitBussiness,
    this.deliveryArea,
    this.expeditionType,
    this.expedition,
    this.vehicle,
    this.notes,
    this.nopol,
  });

  factory DeliveryPlanModel.fromJson(Map<String, dynamic> json) {
    return DeliveryPlanModel(
      id: json['id'],
      code: json['code'],
      date: json['date'],
      status: json['status'],
      total: (json['total'] as num).toInt(),

      driver: json['driver'],
      unitBussiness: json['unit_bussiness'],
      deliveryArea: json['delivery_area'],
      expeditionType: json['expedition_type'],
      expedition: json['expedition'],
      vehicle: json['vehicle'],
      notes: json['notes'],
      nopol: json['nopol'],
    );
  }
}
