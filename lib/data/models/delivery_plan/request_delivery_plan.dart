class SuratJalanRequestModel {
  final String deliveryPlanId;
  final String unitBusinessId;
  final int status; // 1 = draft, 2 = posted
  final String date;
  final String? vehicle;
  final String? nopol;
  final String? expeditionType;
  final List<SuratJalanDetailPayload> details;

  SuratJalanRequestModel({
    required this.deliveryPlanId,
    required this.unitBusinessId,
    required this.status,
    required this.date,
    this.vehicle,
    this.nopol,
    this.expeditionType,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      "delivery_plan_id": deliveryPlanId,
      "unit_bussiness_id": unitBusinessId,
      "status": status,
      "date": date,
      "vehicle": vehicle,
      "nopol": nopol,
      "expedition_type": expeditionType,
      "details": details.map((e) => e.toJson()).toList(),
    };
  }
}

class SuratJalanDetailPayload {
  final String soId;
  final String customerId;
  final String customerName;
  final String shipTo;
  final String? npwp;
  final String? topId;
  final List<SuratJalanItemPayload> items;

  SuratJalanDetailPayload({
    required this.soId,
    required this.customerId,
    required this.customerName,
    required this.shipTo,
    this.npwp,
    this.topId,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      "so_id": soId,
      "customer_id": customerId,
      "customer_name": customerName,
      "ship_to": shipTo,
      "npwp": npwp,
      "top_id": topId,
      "items": items.map((e) => e.toJson()).toList(),
    };
  }
}

class SuratJalanItemPayload {
  final String itemId;
  final int qty;
  final int price;
  final double weight;
  final String uomId;
  final String uomUnit;
  final int uomValue;

  SuratJalanItemPayload({
    required this.itemId,
    required this.qty,
    required this.price,
    required this.weight,
    required this.uomId,
    required this.uomUnit,
    required this.uomValue,
  });

  Map<String, dynamic> toJson() {
    return {
      "item_id": itemId,
      "qty": qty,
      "price": price,
      "weight": weight,
      "uom_id": uomId,
      "uom_unit": uomUnit,
      "uom_value": uomValue,
    };
  }
}
