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
  bool isSubmitting = false;

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
              children: [InfoPenerimaanBarang(), ItemPenerimaanBarang()],
            ),

            /// BUTTON SIMPAN
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            if (token == null) return;

                            setState(() => isSubmitting = true);

                            final provider = context
                                .read<PenerimaanBarangProvider>();

                            // ================= DEBUG BASIC STATE =================
                            debugPrint(
                              "====== DEBUG SUBMIT PENERIMAAN BARANG ======",
                            );
                            debugPrint("PO ID: ${provider.purchaseOrderId}");
                            debugPrint("PR ID: ${provider.purchaseRequestId}");
                            debugPrint("Supplier ID: ${provider.supplierId}");
                            debugPrint(
                              "Unit Business ID: ${provider.unitBusinessId}",
                            );
                            debugPrint("Warehouse ID: ${provider.warehouseId}");
                            debugPrint(
                              "Items Selected Count: ${provider.selectedItems.length}",
                            );

                            debugPrint("Selected Items RAW:");
                            debugPrint(provider.selectedItems.toString());

                            // ================= CHECK PAYLOAD =================
                            final checkPayload = {
                              "purchase_order_id": provider.purchaseOrderId,
                              "items": provider.selectedItems.map((item) {
                                debugPrint("ITEM DEBUG:");
                                debugPrint(
                                  "purchase_order_d_id: ${item["purchase_order_d_id"]}",
                                );
                                debugPrint(
                                  "qty_receipt: ${item["qty_receipt"]}",
                                );

                                return {
                                  "purchase_order_d_id":
                                      item["purchase_order_d_id"],
                                  "qty_receipt": item["qty_receipt"],
                                };
                              }).toList(),
                            };

                            debugPrint("CHECK PAYLOAD FINAL:");
                            debugPrint(checkPayload.toString());

                            try {
                              // ================= STEP 1 — CHECK STATUS PO =================
                              final checkResult = await provider
                                  .checkBeforeSubmit(
                                    token: token,
                                    payload: checkPayload,
                                  );

                              debugPrint("CHECK RESULT API:");
                              debugPrint(checkResult.toString());

                              if (checkResult["can_post"] != true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      checkResult["message"] ??
                                          "Tidak bisa submit",
                                    ),
                                  ),
                                );
                                return;
                              }

                              final dateStr = provider.invoiceDate == null
                                  ? null
                                  : DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(provider.invoiceDate!);

                              // ================= SUBMIT PAYLOAD =================
                              final submitPayload = {
                                "supplier_id": provider.supplierId,
                                "supplier_name": provider.supplierName,
                                "purchase_request_id":
                                    provider.purchaseRequestId,
                                "purchase_order_id": provider.purchaseOrderId,
                                "unit_bussiness_id": provider.unitBusinessId,
                                "unit_bussiness_name":
                                    provider.unitBusinessName,
                                "warehouse_id": provider.warehouseId,
                                "item_group_coa_id": provider.itemGroupCoaId,
                                "item_group_coa": provider.itemGroup,
                                "police_number": provider.policeNo,
                                "driver_name": provider.driverName,
                                "no_sj_supplier": provider.supplierSjNo,
                                "notes": provider.headerNote,
                                "code": provider.pbCode,
                                "status": "POSTED",
                                "date": dateStr,
                                "date_sj_supplier": dateStr,
                                "t_penerimaan_barang_d": provider.selectedItems
                                    .map((item) {
                                      return {
                                        "purchase_order_id":
                                            provider.purchaseOrderId,
                                        "purchase_order_d_id":
                                            item["purchase_order_d_id"],
                                        "purchase_request_d_id":
                                            item["purchase_request_d_id"],

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

                                        "coa_inventory_id":
                                            item["coa_inventory_id"],
                                        "coa_unbilled_id":
                                            item["coa_unbilled_id"],
                                        "coa_purchase_return_id":
                                            item["coa_purchase_return_id"],

                                        "notes": item["notes"] ?? "",
                                      };
                                    })
                                    .toList(),
                              };

                              debugPrint("SUBMIT PAYLOAD FINAL:");
                              debugPrint(submitPayload.toString());

                              await provider.submitPenerimaanBarang(
                                token: token,
                                payload: submitPayload,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Berhasil simpan Penerimaan Barang",
                                  ),
                                ),
                              );

                              Navigator.pop(context, true);
                            } catch (e, stack) {
                              debugPrint("ERROR SUBMIT:");
                              debugPrint(e.toString());
                              debugPrint(stack.toString());

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            } finally {
                              debugPrint("====== END DEBUG ======");
                              setState(() => isSubmitting = false);
                            }
                          },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.green.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Simpan",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
