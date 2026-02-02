import 'package:flutter/material.dart';

class PengeluaranBarangDetail {
  final String id;
  final String suratJalanId;
  final String itemId;

  final int qty;
  final int price;
  final int amount;
  final int weight;
  final int qtyReturn;
  final int qtySnapshot;
  final int uomValue;
  final int qtyInventory;

  final String? itemName;
  final String uomUnit;
  final String uomId;

  final double resultCogs;

  final DateTime createdAt;
  final DateTime updatedAt;

  final MItemModel? item;

  PengeluaranBarangDetail({
    required this.id,
    required this.suratJalanId,
    required this.itemId,
    required this.qty,
    required this.price,
    required this.amount,
    required this.weight,
    required this.qtyReturn,
    this.itemName,
    required this.qtySnapshot,
    required this.uomUnit,
    required this.uomValue,
    required this.uomId,
    required this.qtyInventory,
    required this.resultCogs,
    required this.createdAt,
    required this.updatedAt,
    this.item,
  });

  factory PengeluaranBarangDetail.fromJson(Map<String, dynamic> json) {
    return PengeluaranBarangDetail(
      id: json['id'] ?? '',
      suratJalanId: json['surat_jalan_id'] ?? '',
      itemId: json['item_id'] ?? '',

      qty: (json['qty'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toInt() ?? 0,
      qtyReturn: (json['qty_return'] as num?)?.toInt() ?? 0,
      qtySnapshot: (json['qty_snapshot'] as num?)?.toInt() ?? 0,
      uomValue: (json['uom_value'] as num?)?.toInt() ?? 0,
      qtyInventory: (json['qty_inventory'] as num?)?.toInt() ?? 0,

      itemName: json['item_name'],
      uomUnit: json['uom_unit'] ?? '-',
      uomId: json['uom_id'] ?? '',

      resultCogs: (json['result_cogs'] as num?)?.toDouble() ?? 0.0,

      createdAt:
          DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),

      item: json['m_item'] != null ? MItemModel.fromJson(json['m_item']) : null,
    );
  }
}

class MItemModel {
  final String id;
  final String code;
  final String name;
  final bool isActive;
  final String itemTypeName;
  final String itemDivisionName;
  final String itemGroupName;
  final String alias;

  final String? dimension;
  final String? thickness;
  final String? length;
  final String? type;
  final String? size;

  final double? actualWeight;
  final double? marketingWeight;

  final String photo;
  final String status;
  final bool isUsed;

  final DateTime createdAt;
  final DateTime updatedAt;

  MItemModel({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    required this.itemTypeName,
    required this.itemDivisionName,
    required this.itemGroupName,
    required this.alias,
    this.dimension,
    this.thickness,
    this.length,
    this.type,
    this.size,
    this.actualWeight,
    this.marketingWeight,
    required this.photo,
    required this.status,
    required this.isUsed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MItemModel.fromJson(Map<String, dynamic> json) {
    try {
      return MItemModel(
        id: json['id'] ?? '',
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        isActive: json['is_active'] ?? false,

        itemTypeName: json['item_type_name'] ?? '',
        itemDivisionName: json['item_division_name'] ?? '',
        itemGroupName: json['item_group_name'] ?? '',
        alias: json['alias'] ?? '',

        dimension: json['dimension'],
        thickness: json['thickness'],
        length: json['length'],
        type: json['type'],
        size: json['size'],

        actualWeight: (json['actual_weight'] as num?)?.toDouble(),
        marketingWeight: (json['marketing_weight'] as num?)?.toDouble(),

        photo: json['photo'] ?? '',
        status: json['status'] ?? '',
        isUsed: json['is_used'] ?? false,

        createdAt:
            DateTime.tryParse(json['createdAt'] ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt:
            DateTime.tryParse(json['updatedAt'] ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
    } catch (e) {
      debugPrint("❌ ERROR PARSE MItemModel");
      debugPrint(e.toString());
      debugPrint(json.toString());
      rethrow;
    }
  }
}
