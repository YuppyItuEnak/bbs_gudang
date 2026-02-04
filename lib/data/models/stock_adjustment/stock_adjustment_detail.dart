import 'package:bbs_gudang/data/models/list_item/list_item_model.dart';

class StockAdjustmentDetail {
  final String id;
  final String itemCode;
  final String reason;
  final double qtyBefore;
  final double qtyAfter;
  final double adjustment;
  final ItemBarangModel? item;

  StockAdjustmentDetail({
    required this.id,
    required this.itemCode,
    required this.reason,
    required this.qtyBefore,
    required this.qtyAfter,
    required this.adjustment,
    this.item,
  });

  factory StockAdjustmentDetail.fromJson(Map<String, dynamic> json) {
    return StockAdjustmentDetail(
      id: json['id'],
      itemCode: json['item_code'],
      reason: json['reason'] ?? '',
      qtyBefore: (json['qty_before'] as num).toDouble(),
      qtyAfter: (json['qty_after'] as num).toDouble(),
      adjustment: (json['adjustment'] as num).toDouble(),
      item: json['m_item'] != null ? ItemBarangModel.fromJson(json['m_item']) : null,
    );
  }
}

// class Item {
//   final String id;
//   final String code;
//   final String name;
//   final String? itemUomId; // Tambahkan ini
//   final String? itemGroupCoaId; // Tambahkan ini
//   final double? cost; // Tambahkan jika ada

//   Item({
//     required this.id,
//     required this.code,
//     required this.name,
//     this.itemUomId,
//     this.itemGroupCoaId,
//     this.cost,
//   });

//   factory Item.fromJson(Map<String, dynamic> json) {
//     return Item(
//       id: json['id'] ?? '',
//       code: json['code'] ?? '',
//       name: json['name'] ?? '',
//       // Sesuaikan key 'item_uom_id' dengan apa yang dikirim oleh API Anda
//       itemUomId: json['item_uom_id'] ?? json['f_item_uom'],
//       itemGroupCoaId: json['item_group_coa_id'] ?? json['f_item_group_coa'],
//       cost: (json['cost'] ?? 0).toDouble(),
//     );
//   }
// }
