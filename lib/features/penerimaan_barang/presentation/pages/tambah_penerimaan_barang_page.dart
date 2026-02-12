import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/providers/penerimaan_barang_provider.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/widgets/info_penerimaan_barnag.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/item_penerimaan_barang.dart';

class TambahPenerimaanBarangPage extends StatefulWidget {
  const TambahPenerimaanBarangPage({super.key});

  @override
  State<TambahPenerimaanBarangPage> createState() =>
      _TambahPenerimaanBarangPageState();
}

class _TambahPenerimaanBarangPageState
    extends State<TambahPenerimaanBarangPage> {
  final GlobalKey<InfoPenerimaanBarangState> _infoKey = GlobalKey<InfoPenerimaanBarangState>();
  bool isSubmitting = false;

  Future<void> _submitPB({
    required BuildContext context,
    required String status, // DRAFT / POSTED
  }) async {
    final provider = context.read<PenerimaanBarangProvider>();
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    if (_infoKey.currentState != null) {
      if (!_infoKey.currentState!.validateForm()) {
        return; // Berhenti jika tidak valid
      }
    }

    setState(() => isSubmitting = true);

    try {
      final dateStr = provider.invoiceDate == null
          ? null
          : DateFormat('yyyy-MM-dd').format(provider.invoiceDate!);

      final payload = {
        "supplier_id": provider.supplierId,
        "supplier_name": provider.supplierName,
        "purchase_request_id": provider.purchaseRequestId,
        "purchase_request_code": provider.prCode,
        "purchase_order_id": provider.purchaseOrderId,
        "purchase_order_code": provider.selectedPO?.code,
        "unit_bussiness_id": provider.unitBusinessId,
        "unit_bussiness_name": provider.unitBusinessName,
        "warehouse_id": provider.warehouseId,
        "item_group_coa_id": provider.itemGroupCoaId,
        "item_group_coa": provider.itemGroup,
        "police_number": provider.policeNo,
        "driver_name": provider.driverName,
        "no_sj_supplier": provider.supplierSjNo,
        "notes": provider.headerNote,
        "code": provider.pbCode,

        /// 🔥 STATUS DINAMIS
        "status": status,

        "date": dateStr,
        "date_sj_supplier": dateStr,

        "t_penerimaan_barang_d": provider.selectedItems.map((item) {
          return {
            "purchase_order_id": provider.purchaseOrderId,
            "purchase_order_d_id": item["purchase_order_d_id"],
            "purchase_request_d_id": item["purchase_request_d_id"],
            "item_id": item["item_id"],
            "item_code": item["code"],
            "item_name": item["item_name"],
            "item_type": item["item_type"],
            "qty_received": item["qty_received"],
            "qty_receipt": item["qty_receipt"],
            "qty_closing": 0,
            "item_uom_id": item["item_uom_id"],
            "item_uom": item["item_uom"],
            "price": item["price"],
            "item_price": item["item_price"],
            "total": item["total"],
            "coa_inventory_id": item["coa_inventory_id"],
            "coa_unbilled_id": item["coa_unbilled_id"],
            "coa_purchase_return_id": item["coa_purchase_return_id"],
            "notes": item["notes"] ?? "",
          };
        }).toList(),
      };

      // ... di dalam try block sebelum await provider.submitPenerimaanBarang ...

      debugPrint("""
🚀 CHECK PAYLOAD SEBELUM KIRIM:
--------------------------------
ID PO: ${provider.purchaseOrderId}
ID PR: ${provider.purchaseRequestId}
NO PB (Code): ${provider.pbCode}
NO PR (PR Code): ${provider.prCode}
UNIT: ${provider.unitBusinessName}
--------------------------------
JUMLAH ITEM: ${provider.selectedItems.length}
""");

      // Cek apakah ada yang null secara spesifik
      if (provider.purchaseOrderId == null)
        debugPrint("⚠️ WARNING: purchase_order_id is NULL");
      if (provider.purchaseRequestId == null)
        debugPrint("⚠️ WARNING: purchase_request_id is NULL");

      debugPrint("📦 FULL JSON PAYLOAD:");
      debugPrint("📦 SUBMIT PB [$status]");
      debugPrint(payload.toString());

      await provider.submitPenerimaanBarang(token: token, payload: payload);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == "POSTED"
                ? "Berhasil POST Penerimaan Barang"
                : "Berhasil simpan sebagai DRAFT",
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
    final token = context.read<AuthProvider>().token;

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
            "Penerimaan Barang",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: "Info"),
              Tab(text: "Item"),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [InfoPenerimaanBarang(key: _infoKey), ItemPenerimaanBarang()],
            ),

            /// BUTTON SIMPAN
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    /// 💾 SAVE (DRAFT)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () =>
                                  _submitPB(context: context, status: "DRAFT"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// 🚀 POSTED
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () =>
                                  _submitPB(context: context, status: "POSTED"),
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
                            : const Text(
                                "Posted",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
