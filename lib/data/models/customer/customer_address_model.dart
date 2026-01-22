class CustomerAddressModel {
  final String id;
  final String address;
  final String name;
  final String customerId;
  final bool isDefault;
  final String notes;
  final bool isActive;

  CustomerAddressModel({
    required this.id,
    required this.address,
    required this.name,
    required this.customerId,
    required this.isDefault,
    required this.notes,
    required this.isActive,
  });

  factory CustomerAddressModel.fromJson(Map<String, dynamic> json) {
    return CustomerAddressModel(
      id: json['id'],
      address: json['address'] ?? '',
      name: json['name'] ?? '',
      customerId: json['customer_id'],
      isDefault: json['is_default'] ?? false,
      notes: json['notes'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}
