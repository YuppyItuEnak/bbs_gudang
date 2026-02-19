class KartuStockModel {
  final int? no;
  final String? company;
  final String? date;
  final String? warehouse;
  final String? itemCode;
  final String? itemName;
  final String? transactionType;
  final String? transactionCode;
  final String? customerSupplier;
  final String? weightPerUnit;
  final String? transactionValue;
  final num? qtyIn;
  final num? qtyOut;
  final num? qtyBalance;
  final num? weightIn;
  final String? weightOut;
  final String? unitPrice;
  final String? hpp;
  final num? valueIn;
  final String? valueOut;
  final String? valueBalance;

  KartuStockModel({
    this.no,
    this.company,
    this.date,
    this.warehouse,
    this.itemCode,
    this.itemName,
    this.transactionType,
    this.transactionCode,
    this.customerSupplier,
    this.weightPerUnit,
    this.transactionValue,
    this.qtyIn,
    this.qtyOut,
    this.qtyBalance,
    this.weightIn,
    this.weightOut,
    this.unitPrice,
    this.hpp,
    this.valueIn,
    this.valueOut,
    this.valueBalance,
  });

  factory KartuStockModel.fromJson(Map<String, dynamic> json) {
    // Helper function untuk menangani data yang bisa berupa String atau Num
    String parseToString(dynamic value) {
      if (value == null) return '0';
      return value.toString();
    }

    return KartuStockModel(
      no: json['no'] is int
          ? json['no']
          : int.tryParse(json['no']?.toString() ?? '0'),
      company: json['company'] ?? '',
      date: json['date'] ?? '',
      warehouse: json['warehouse'] ?? '',
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      transactionType: json['transaction_type'] ?? '',
      transactionCode: json['transaction_code'] ?? '',
      customerSupplier: json['customer_supplier'] ?? '',
      weightPerUnit: parseToString(json['weight_per_unit']),
      transactionValue: parseToString(json['transaction_value']),
      qtyIn: json['qty_in'] is num ? json['qty_in'] : 0,
      qtyOut: json['qty_out'] is num ? json['qty_out'] : 0,
      qtyBalance: json['qty_balance'] is num ? json['qty_balance'] : 0,
      weightIn: json['weight_in'] is num ? json['weight_in'] : 0,
      // Perbaikan: Pastikan valueOut dan valueBalance dikonversi ke String
      weightOut: parseToString(json['weight_out']),
      unitPrice: parseToString(json['unit_price']),
      hpp: parseToString(json['hpp']),
      valueIn: json['value_in'] is num ? json['value_in'] : 0,
      valueOut: parseToString(json['value_out']),
      valueBalance: parseToString(json['value_balance']),
    );
  }
}
