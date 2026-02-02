class AvailablePoModel {
  final String id;
  final String code;
  final DateTime? date;
  final String? status;
  final String? grandTotal;
  final PoSupplierModel? supplier;

  AvailablePoModel({
    required this.id,
    required this.code,
    this.date,
    this.status,
    this.grandTotal,
    this.supplier,
  });

  factory AvailablePoModel.fromJson(Map<String, dynamic> json) {
    return AvailablePoModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      status: json['status'],
      grandTotal: json['grand_total']?.toString(),
      supplier: json['poSupplier'] != null
          ? PoSupplierModel.fromJson(json['poSupplier'])
          : null,
    );
  }
}

class PoSupplierModel {
  final String id;
  final String name;

  PoSupplierModel({required this.id, required this.name});

  factory PoSupplierModel.fromJson(Map<String, dynamic> json) {
    return PoSupplierModel(id: json['id'] ?? '', name: json['name'] ?? '');
  }
}
