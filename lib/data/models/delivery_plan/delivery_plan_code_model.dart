import 'package:bbs_gudang/data/models/delivery_plan/delivery_plan_detail_model.dart';
import 'package:flutter/material.dart';

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

T safeParse<T>(String field, dynamic value, T Function(dynamic val) parser) {
  try {
    return parser(value);
  } catch (e) {
    debugPrint(
      '❌ PARSE ERROR field="$field" | value=$value | type=${value.runtimeType}',
    );
    rethrow;
  }
}

class DeliveryPlanCodeModel {
  final String id;
  final String? unitBussinessId;
  final String code;
  final String? deliveryAreaId;
  final String? expeditionTypeId;
  final String? expeditionId;
  final String? vehicleId;
  final String? driver;
  final DateTime? date;
  final int status;
  final int total;
  final double weight;
  final String? notes;
  final bool sjUsed;
  final String? nopol;

  final int revisedCount;
  final int approvalCount;
  final int approvedCount;
  final int? currentApprovalLevel;

  final String? createdBy;
  final String? updatedBy;
  final String? requestApprovalBy;
  final DateTime? requestApprovalAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final UnitBussinessModel? unitBussiness;
  final VehicleModel? vehicle;
  final List<DeliveryPlanDetailModel> details;
  final DeliveryAreaModel? deliveryArea;

  DeliveryPlanCodeModel({
    required this.id,
    this.unitBussinessId,
    required this.code,
    this.deliveryAreaId,
    this.expeditionTypeId,
    this.expeditionId,
    this.vehicleId,
    this.driver,
    this.date,
    required this.status,
    required this.total,
    required this.weight,
    this.notes,
    required this.sjUsed,
    this.nopol,
    required this.revisedCount,
    required this.approvalCount,
    required this.approvedCount,
    this.currentApprovalLevel,
    this.createdBy,
    this.updatedBy,
    this.requestApprovalBy,
    this.requestApprovalAt,
    this.createdAt,
    this.updatedAt,
    this.unitBussiness,
    this.vehicle,
    required this.details,
    this.deliveryArea,
  });

  factory DeliveryPlanCodeModel.fromJson(Map<String, dynamic> json) {
    return DeliveryPlanCodeModel(
      id: json['id']?.toString() ?? '',

      unitBussinessId: json['unit_bussiness_id'],
      code: json['code'] ?? '',

      deliveryAreaId: json['delivery_area_id'],
      expeditionTypeId: json['expedition_type_id'],
      expeditionId: json['expedition_id'],
      vehicleId: json['vehicle_id'],

      driver: json['driver'],

      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,

      status: parseInt(json['status']),
      total: parseInt(json['total']),
      weight: parseDouble(json['weight']),

      notes: json['notes'],

      sjUsed: json['sj_used'] == true || json['sj_used'] == 1,

      nopol: json['nopol'],

      revisedCount: parseInt(json['revised_count']),
      approvalCount: parseInt(json['approval_count']),
      approvedCount: parseInt(json['approved_count']),

      currentApprovalLevel: json['current_approval_level'] != null
          ? parseInt(json['current_approval_level'])
          : null,

      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      requestApprovalBy: json['request_approval_by'],

      requestApprovalAt: DateTime.tryParse(json['request_approval_at'] ?? ''),
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),

      unitBussiness: json['m_unit_bussiness'] != null
          ? UnitBussinessModel.fromJson(json['m_unit_bussiness'])
          : null,

      vehicle: json['m_vehicle'] != null
          ? VehicleModel.fromJson(json['m_vehicle'])
          : null,

      details: (json['t_delivery_plan_ds'] as List? ?? [])
          .map((e) => DeliveryPlanDetailModel.fromJson(e))
          .toList(),

      deliveryArea: json['m_delivery_area'] != null
          ? DeliveryAreaModel.fromJson(json['m_delivery_area'])
          : null,
    );
  }
}

class UnitBussinessModel {
  final String id;
  final String code;
  final String name;
  final String? address;

  UnitBussinessModel({
    required this.id,
    required this.code,
    required this.name,
    this.address,
  });

  factory UnitBussinessModel.fromJson(Map<String, dynamic> json) {
    return UnitBussinessModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      address: json['address'],
    );
  }
}

class DeliveryAreaModel {
  final String id;
  final String code;
  final String description;
  final bool isActive;

  DeliveryAreaModel({
    required this.id,
    required this.code,
    required this.description,
    required this.isActive,
  });

  factory DeliveryAreaModel.fromJson(Map<String, dynamic> json) {
    return DeliveryAreaModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}

class ExpeditionTypeModel {
  final String id;
  final String? value1;
  final bool status;

  ExpeditionTypeModel({required this.id, this.value1, required this.status});

  factory ExpeditionTypeModel.fromJson(Map<String, dynamic> json) {
    return ExpeditionTypeModel(
      id: json['id'] ?? '',
      value1: json['value1'],
      status: json['status'] ?? false,
    );
  }
}
