import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/providers/penerimaan_barang_provider.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/widgets/info_penerimaan_barang_edit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/item_penerimaan_barang.dart';

class EditPenerimaanBarangPage extends StatefulWidget {
  final String pbId;

  const EditPenerimaanBarangPage({super.key, required this.pbId});

  @override
  State<EditPenerimaanBarangPage> createState() =>
      _EditPenerimaanBarangPageState();
}

class _EditPenerimaanBarangPageState extends State<EditPenerimaanBarangPage> {
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final token = context.read<AuthProvider>().token;
      if (token == null) return;
      final provider = context.read<PenerimaanBarangProvider>();

      context.read<PenerimaanBarangProvider>().fetchDetail(
        token: token,
        id: widget.pbId,
      );

      debugPrint("=== DEBUG EDIT PB PAGE ===");
      debugPrint("PB ID: ${widget.pbId}");
      debugPrint("PO ID dari Data: ${provider.data?.purchaseOrderId}");
       debugPrint("PR ID dari Data: ${provider.data?.purchaseRequestId}");
      debugPrint("PO Code dari Data: ${provider.selectedPO?.code}");
      debugPrint(
        "PR Code dari Data: ${provider.prCode}",
      );
      debugPrint("Supplier Name: ${provider.supplierName}");
      debugPrint("Warehouse ID: ${provider.warehouseId}");
      debugPrint("==========================");
    });
  }

  num _parseNum(dynamic v, [num defaultValue = 0]) {
    if (v == null) return defaultValue;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? defaultValue;
  }

  Future<void> _submitEditPB({
    required BuildContext context,
    required String status, // DRAFT / POSTED
  }) async {
    final provider = context.read<PenerimaanBarangProvider>();
    final auth = context.read<AuthProvider>();
    final token = auth.token;
    final userId = auth.user?.id;

    if (token == null) return;

    setState(() => isSubmitting = true);

    try {
      final dateStr = provider.invoiceDate == null
          ? null
          : DateFormat('yyyy-MM-dd').format(provider.invoiceDate!);

      final payload = {
        "unit_bussiness_id": provider.unitBusinessId,
        "unit_bussiness_name": provider.unitBusinessName,
        "code": provider.pbCode,
        "item_group_coa_id": provider.itemGroupCoaId,
        "item_group_coa": provider.itemGroup,
        "purchase_order_id": provider.data?.purchaseOrderId,
        "police_number": provider.policeNo,
        "no_sj_supplier": provider.supplierSjNo,
        "notes": provider.headerNote,
        "date": dateStr,
        "supplier_id": provider.supplierId,
        "supplier_name": provider.supplierName,
        "purchase_request_id": provider.purchaseRequestId,
        // "purchase_request_code": provider.prCode,
        "driver_name": provider.driverName,
        "date_sj_supplier": dateStr,
        "warehouse_id": provider.warehouseId,
        "status": status,

        /// 🔥 WAJIB SAAT POSTED
        if (status == "POSTED") ...{
          "posted_by": userId,
          "updatedBy": userId,
          "posted_at": DateTime.now().toIso8601String(),
        },

        /// DETAIL ITEM
        "t_penerimaan_barang_d": provider.selectedItems.map((item) {
          print("EDIT MODE PO: ${provider.selectedPO?.code}");
          print("EDIT MODE PO ID: ${provider.purchaseOrderId}");

          final price = _parseNum(item["price"]);
          final qty = _parseNum(item["qty_received"] ?? item["qty_receipt"], 0);

          return {
            "id": item["id"],
            "purchase_order_id": provider.purchaseOrderId,
            "purchase_order_d_id": item["purchase_order_d_id"],

            "purchase_request_d_id":
                (item["purchase_request_d_id"] == null ||
                    item["purchase_request_d_id"].toString().isEmpty)
                ? null
                : item["purchase_request_d_id"],

            "item_id": item["item_id"],
            "item_code": item["item_code"],
            "item_name": item["item_name"],
            "item_type": item["item_type"]?.toString().toLowerCase(),

            "qty_received": qty,
            "qty_receipt": qty,
            "qty_closing": 0,

            "item_uom_id": item["item_uom_id"],
            "item_uom": item["item_uom"],

            "price": price,
            "item_price": price,
            "unitCost": price,
            "total": price * qty,

            "coa_inventory_id": item["coa_inventory_id"],
            "coa_unbilled_id": item["coa_unbilled_id"],
            "coa_purchase_return_id": item["coa_purchase_return_id"],
            "notes": item["notes"] ?? "",
          };
        }).toList(),
      };

      debugPrint("📦 SUBMIT PB [$status]");
      debugPrint(payload.toString());

      await provider.postPenerimaanBarang(
        token: token,
        pbId: widget.pbId,
        payload: payload,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == "POSTED"
                ? "Penerimaan Barang berhasil di-POST"
                : "Penerimaan Barang berhasil disimpan (DRAFT)",
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PenerimaanBarangProvider>();

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Edit Penerimaan Barang",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            tabs: [
              Tab(text: "Info"),
              Tab(text: "Item"),
            ],
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 90),
                child: TabBarView(
                  children: [
                    InfoPenerimaanBarangEdit(),
                    ItemPenerimaanBarang(isEdit: true, allowAdd: false),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () => _submitEditPB(
                                context: context,
                                status: "DRAFT",
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Save"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () => _submitEditPB(
                                context: context,
                                status: "POSTED",
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Posted"),
                      ),
                    ),
                    if (isSubmitting)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: const Center(
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    "Sedang memproses...",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
