class QuotationDetail {
  final String id;
  final String code;
  final String customerName;
  final int status;
  final String date;
  final String? top;
  final String? shipToAddress;
  final String? notes;
  final double dpp;
  final double totalDiscount;
  final double ppn;
  final double grandTotal;
  final List<QuotationDetailItem> items;

  QuotationDetail({
    required this.id,
    required this.code,
    required this.customerName,
    required this.status,
    required this.date,
    this.top,
    this.shipToAddress,
    this.notes,
    required this.dpp,
    required this.totalDiscount,
    required this.ppn,
    required this.grandTotal,
    required this.items,
  });

  factory QuotationDetail.fromJson(Map<String, dynamic> json) {
    var list = json['t_sales_quotation_ds'] as List? ?? [];
    List<QuotationDetailItem> itemsList = list
        .map((i) => QuotationDetailItem.fromJson(i))
        .toList();

    return QuotationDetail(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      customerName: json['customer_name'] ?? '',
      status: int.tryParse('${json['status']}') ?? 1,
      date: json['date'] ?? '',
      top: json['salesQuotationTop']['value1'] ?? '',
      shipToAddress: json['m_customer_d_address'] != null
          ? json['m_customer_d_address']['address']
          : json['ship_to_address'],
      notes: json['notes'],
      dpp: (json['dpp'] as num?)?.toDouble() ?? 0.0,
      totalDiscount: (json['total_discount'] as num?)?.toDouble() ?? 0.0,
      ppn: (json['ppn'] as num?)?.toDouble() ?? 0.0,
      grandTotal:
          (json['grand_total'] as num?)?.toDouble() ??
          (json['total'] as num?)?.toDouble() ??
          0.0,
      items: itemsList,
    );
  }
}

class QuotationDetailItem {
  final String id;
  final String itemName;
  final String itemCode;
  final double qty;
  final double price;
  final double subtotal;
  final String? notes;

  QuotationDetailItem({
    required this.id,
    required this.itemName,
    required this.itemCode,
    required this.qty,
    required this.price,
    required this.subtotal,
    this.notes,
  });

  factory QuotationDetailItem.fromJson(Map<String, dynamic> json) {
    String code = '';
    if (json['m_item'] != null) {
      code = json['m_item']['code'] ?? '';
    }

    return QuotationDetailItem(
      id: json['id'] ?? '',
      itemName: json['item_name'] ?? '',
      itemCode: code,
      qty: (json['qty'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
    );
  }
}
