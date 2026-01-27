class ItemBarangModel {
  final String id;
  final String code;
  final String name;
  final String status;
  final String itemTypeName;
  final String itemDivisionName;
  final String itemGroupName;
  final bool isActive;

  ItemBarangModel({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
    required this.itemTypeName,
    required this.itemDivisionName,
    required this.itemGroupName,
    required this.isActive,
  });

  factory ItemBarangModel.fromJson(Map<String, dynamic> json) {
    return ItemBarangModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      status: json['status'],
      itemTypeName: json['item_type_name'] ?? "-",
      itemDivisionName: json['item_division_name'] ?? "-",
      itemGroupName: json['item_group_name'] ?? "-",
      isActive: json['is_active'] ?? false,
    );
  }
}
