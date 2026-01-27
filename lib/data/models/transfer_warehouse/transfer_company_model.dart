class TransferCompanyModel {
  final String id;
  final String name;
  final int? extDueDateSi;
  final int? extDeliveryDateSo;

  TransferCompanyModel({
    required this.id,
    required this.name,
    this.extDueDateSi,
    this.extDeliveryDateSo,
  });

  factory TransferCompanyModel.fromJson(Map<String, dynamic> json) {
    return TransferCompanyModel(
      id: json['id'],
      name: json['name'],
      extDueDateSi: json['ext_due_date_si'],
      extDeliveryDateSo: json['ext_delivery_date_so'],
    );
  }
}
