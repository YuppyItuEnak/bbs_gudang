class CompanyWarehouseModel {
  final String id;
  final String unitBusinessId;
  final String name;

  CompanyWarehouseModel({
    required this.id,
    required this.unitBusinessId,
    required this.name,
  });

  factory CompanyWarehouseModel.fromJson(Map<String, dynamic> json) {
    return CompanyWarehouseModel(
      id: json['id'],
      unitBusinessId: json['unit_bussiness_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unit_bussiness_id': unitBusinessId,
      'name': name,
    };
  }
}
