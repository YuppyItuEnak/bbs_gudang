import 'package:bbs_gudang/data/models/list_item/list_item_model.dart';
import 'package:flutter/material.dart';

T safeParse<T>(String field, dynamic value, T Function(dynamic val) parser) {
  try {
    return parser(value);
  } catch (e) {
    debugPrint(
      '❌ DETAIL PARSE ERROR field="$field" | value=$value | type=${value.runtimeType}',
    );
    rethrow;
  }
}

int parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class DeliveryPlanDetailModel {
  final String id;
  final String deliveryPlanId;
  final String soId;
  final String customerId;
  final int itemQty;
  final double totalWeight;
  final int totalAmount;
  final String shipToName;
  final String shipToAddress;
  final String? npwp;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<DeliveryPlanDetailItemModel> items;
  final SalesOrderModel? salesOrder;
  final CustomerModel? customer;

  DeliveryPlanDetailModel({
    required this.id,
    required this.deliveryPlanId,
    required this.soId,
    required this.customerId,
    required this.itemQty,
    required this.totalWeight,
    required this.totalAmount,
    required this.shipToName,
    required this.shipToAddress,
    this.npwp,
    this.createdAt,
    this.updatedAt,
    required this.items,
    this.salesOrder,
    this.customer,
  });

  factory DeliveryPlanDetailModel.fromJson(Map<String, dynamic> json) {
    debugPrint("🧪 DETAIL ID: ${json['id']}");
    debugPrint("🧪 RAW ITEMS KEY: ${json['t_delivery_plan_d_items']}");
    debugPrint(
      "🧪 ITEMS TYPE: ${json['t_delivery_plan_d_items']?.runtimeType}",
    );

    return DeliveryPlanDetailModel(
      id: json['id'] ?? '',
      deliveryPlanId: json['delivery_plan_id'] ?? '',
      soId: json['so_id'] ?? '',
      customerId: json['customer_id'] ?? '',

      itemQty: parseInt(json['item_qty']),
      totalWeight: parseDouble(json['total_weight']),
      totalAmount: parseInt(json['total_amount']),

      shipToName: json['ship_to_name'] ?? '',
      shipToAddress: json['ship_to_address'] ?? '',
      npwp: json['npwp'],

      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),

      items: (json['t_delivery_plan_d_items'] as List? ?? [])
          .map((e) => DeliveryPlanDetailItemModel.fromJson(e))
          .toList(),

      salesOrder: json['t_sales_order'] != null
          ? SalesOrderModel.fromJson(json['t_sales_order'])
          : null,

      customer: json['m_customer'] != null
          ? CustomerModel.fromJson(json['m_customer'])
          : null,
    );
  }
}

class DeliveryPlanDetailItemModel {
  final String id;
  final String itemId;
  final int qtySo;
  int qtyDp;
  final int amount;
  final int price;
  final double weight;
  final int uomValue;
  final String uomUnit;

  final ItemBarangModel? item;
  final ItemUomModel? uom;

  DeliveryPlanDetailItemModel({
    required this.id,
    required this.itemId,
    required this.qtySo,
    required this.qtyDp,
    required this.amount,
    required this.price,
    required this.weight,
    required this.uomValue,
    required this.uomUnit,
    this.item,
    this.uom,
  });

  factory DeliveryPlanDetailItemModel.fromJson(Map<String, dynamic> json) {
    return DeliveryPlanDetailItemModel(
      id: json['id'] ?? '',
      itemId: json['item_id'] ?? '',

      qtySo: parseInt(json['qty_so']),
      qtyDp: parseInt(json['qty_dp']),

      amount: parseInt(json['amount']),
      price: parseInt(json['price']),

      weight: parseDouble(json['weight']),

      uomValue: parseInt(json['uom_value']),
      uomUnit: json['uom_unit'] ?? '',

      item: json['m_item'] != null ? ItemBarangModel.fromJson(json['m_item']) : null,
      uom: json['tdpDetailItemUom'] != null
          ? ItemUomModel.fromJson(json['tdpDetailItemUom'])
          : null,
    );
  }
}

class ItemModel {
  final String id;
  final String code;
  final String name;
  final String? alias;
  final String? dimension;
  final String? thickness;
  final String? length;
  final String? type;
  final String? size;
  final bool isActive;

  ItemModel({
    required this.id,
    required this.code,
    required this.name,
    this.alias,
    this.dimension,
    this.thickness,
    this.length,
    this.type,
    this.size,
    required this.isActive,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      alias: json['alias'],
      dimension: json['dimension'],
      thickness: json['thickness'],
      length: json['length'],
      type: json['type'],
      size: json['size'],
      isActive: json['is_active'] ?? false,
    );
  }
}

class ItemUomModel {
  final String id;
  final bool status;

  ItemUomModel({required this.id, required this.status});

  factory ItemUomModel.fromJson(Map<String, dynamic> json) {
    return ItemUomModel(id: json['id'] ?? '', status: json['sta'] ?? false);
  }
}

class CustomerModel {
  final String id;
  final String name;
  final String code;

  CustomerModel({required this.id, required this.name, required this.code});

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class SalesOrderModel {
  final String id;
  final String code;
  final String? top_id;
  final DateTime? date;
  final String? expedition;
  final String? expeditionType;
  final String? customerName;

  SalesOrderModel({
    required this.id,
    required this.code,
    this.top_id,
    this.date,
    this.expedition,
    this.expeditionType,
    this.customerName,
  });

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      top_id: json['top_id'],
      date: DateTime.tryParse(json['date'] ?? ''),
      expedition: json['expedition'],
      expeditionType: json['expedition_type'],
      customerName: json['customer_name'],
    );
  }
}

class VehicleModel {
  final String id;
  final String code;
  final String name;
  final String? nopol;

  VehicleModel({
    required this.id,
    required this.code,
    required this.name,
    this.nopol,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      nopol: json['nopol'],
    );
  }
}
