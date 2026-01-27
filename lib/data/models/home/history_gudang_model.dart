class HistoryGudangModel {
  final int no;
  final String company;
  final String date;
  final String warehouse;
  final String itemCode;
  final String itemName;
  final String transactionType;
  final String transactionCode;
  final String customerSupplier;
  final int qtyIn;
  final int qtyOut;
  final int qtyBalance;
  final String valueBalance;

  HistoryGudangModel({
    required this.no,
    required this.company,
    required this.date,
    required this.warehouse,
    required this.itemCode,
    required this.itemName,
    required this.transactionType,
    required this.transactionCode,
    required this.customerSupplier,
    required this.qtyIn,
    required this.qtyOut,
    required this.qtyBalance,
    required this.valueBalance,
  });

  factory HistoryGudangModel.fromJson(Map<String, dynamic> json) {
    return HistoryGudangModel(
      no: json['no'],
      company: json['company'],
      date: json['date'],
      warehouse: json['warehouse'],
      itemCode: json['item_code'],
      itemName: json['item_name'],
      transactionType: json['transaction_type'],
      transactionCode: json['transaction_code'],
      customerSupplier: json['customer_supplier'],
      qtyIn: json['qty_in'],
      qtyOut: json['qty_out'],
      qtyBalance: json['qty_balance'],
      valueBalance: json['value_balance'],
    );
  }


}
