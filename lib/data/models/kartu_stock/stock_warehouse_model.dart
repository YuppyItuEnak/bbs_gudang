// Response rows adalah array: [no, company, warehouse, item_code, item_name, ?, ?, qty, net_qty, uom]
class StockWarehouseModel {
  final int? no;
  final String? companyName;
  final String? warehouseName;
  final String? itemCode;
  final String? itemName;
  final num? qty;
  final num? netQty;
  final String? uom;

  StockWarehouseModel({
    this.no,
    this.companyName,
    this.warehouseName,
    this.itemCode,
    this.itemName,
    this.qty,
    this.netQty,
    this.uom,
  });

  factory StockWarehouseModel.fromList(List<dynamic> row) {
    return StockWarehouseModel(
      no: row[0] is int ? row[0] : int.tryParse(row[0]?.toString() ?? ''),
      companyName: row[1]?.toString() ?? '',
      warehouseName: row[2]?.toString() ?? '',
      itemCode: row[3]?.toString() ?? '',
      itemName: row[4]?.toString() ?? '',
      qty: row[7] is num ? row[7] : num.tryParse(row[7]?.toString() ?? '0') ?? 0,
      netQty: row[8] is num ? row[8] : num.tryParse(row[8]?.toString() ?? '0') ?? 0,
      uom: row[9]?.toString() ?? '-',
    );
  }
}
