class ItemModel {
  final String id;
  final String code;
  final String name;
  final String? itemTypeName;
  final String? itemDivisionName;
  final String? itemGroupName;
  final Pricelist? pricelist;
  final String? photo;
  final String? uom;

  ItemModel({
    required this.id,
    required this.code,
    required this.name,
    this.itemTypeName,
    this.itemDivisionName,
    this.itemGroupName,
    this.pricelist,
    this.photo,
    this.uom,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      itemTypeName: json['item_type_name'],
      itemDivisionName: json['item_division_name'],
      uom: json['itemUom']['value1'],
      itemGroupName: json['item_group_name'],
      pricelist: json['m_pricelist'] != null
          ? Pricelist.fromJson(json['m_pricelist'])
          : null,
      photo: json['photo'],
    );
  }
}

class Pricelist {
  final String id;
  final double price;

  Pricelist({required this.id, required this.price});

  factory Pricelist.fromJson(Map<String, dynamic> json) {
    return Pricelist(
      id: json['id'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
