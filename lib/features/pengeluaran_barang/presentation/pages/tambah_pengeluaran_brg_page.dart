import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/pages/edit_pengeluaran_brg_form.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/pages/tambah_item_pengeluaran_page.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/providers/pengeluaran_barang_provider.dart'
    show PengeluaranBarangProvider;
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/widgets/tmbh_pengeluaran_input_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/item_pengeluaran_tile.dart';

class TambahPengeluaranBrgPage extends StatefulWidget {
  const TambahPengeluaranBrgPage({super.key});

  @override
  State<TambahPengeluaranBrgPage> createState() =>
      _TambahPengeluaranBrgPageState();
}

class _TambahPengeluaranBrgPageState extends State<TambahPengeluaranBrgPage> {
  // CONTROLLERS FOR AUTO FILL
  final companyCtrl = TextEditingController();
  final deliveryAreaCtrl = TextEditingController();
  final expeditionTypeCtrl = TextEditingController();
  final licensePlateCtrl = TextEditingController();
  final totalWeightCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final expeditionCtrl = TextEditingController();
  final vehicleCtrl = TextEditingController();
  final totalAmountCtrl = TextEditingController();
  final driverCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<PengeluaranBarangProvider>().fetchDeliveryPlanCode(
          token: token,
        );
      }
    });
  }

  /// 🔄 AUTO FILL FROM DETAIL DP
  void _autoFill(PengeluaranBarangProvider pb) {
    final detail = pb.detailDPCode;
    if (detail == null) return;

    final firstDetail = detail.details?.isNotEmpty == true
        ? detail.details!.first
        : null;

    companyCtrl.text = detail.unitBussiness?.name ?? '';
    deliveryAreaCtrl.text = detail.deliveryArea?.code ?? '';
    licensePlateCtrl.text = detail.nopol ?? '';
    totalWeightCtrl.text = detail.weight?.toString() ?? '';
    dateCtrl.text = detail.date != null
        ? DateFormat('dd/MM/yyyy').format(detail.date!)
        : '';

    vehicleCtrl.text = detail.vehicle?.name ?? '';
    totalAmountCtrl.text = detail.total?.toString() ?? '';
    driverCtrl.text = detail.driver ?? '';

    // ✅ EXPEDITION dari SALES ORDER di DETAILS
    expeditionCtrl.text = firstDetail?.salesOrder?.expeditionType ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pengeluaran Barang",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Consumer<PengeluaranBarangProvider>(
        builder: (context, pb, _) {
          // Trigger autofill when detail loaded
          _autoFill(pb);

          final selectedId = pb.selectedDeliveryPlanId;

          final uniqueList = {
            for (var e in pb.listDeliveryPlanCode) e.id: e,
          }.values.toList();

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ===== NO DP DROPDOWN =====
                      const SizedBox(height: 10),
                      const Text(
                        "No. Pengeluaran Barang",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            key: ValueKey(selectedId),
                            isExpanded: true,
                            hint: const Text("Pilih Delivery Plan"),

                            value: uniqueList.any((e) => e.id == selectedId)
                                ? selectedId
                                : null,

                            items: uniqueList.map((e) {
                              return DropdownMenuItem<String>(
                                value: e.id,
                                child: Text(e.code),
                              );
                            }).toList(),

                            onChanged: (value) async {
                              if (value == null) return;

                              pb.setSelectedDeliveryPlanId(value);

                              final token = context.read<AuthProvider>().token;

                              if (token != null) {
                                await pb.fetchDetailDPCode(
                                  token: token,
                                  id: value,
                                );
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// ===== AUTO GENERATED FIELDS =====
                      TmbhPengeluaranInputField(
                        label: "Company",
                        controller: companyCtrl,
                        hint: "Company",
                      ),

                      TmbhPengeluaranInputField(
                        label: "Delivery Area",
                        controller: deliveryAreaCtrl,
                        hint: "Delivery Area",
                      ),

                      TmbhPengeluaranInputField(
                        label: "Expedition Type",
                        controller: expeditionTypeCtrl,
                        hint: "Expedition Type",
                      ),

                      TmbhPengeluaranInputField(
                        label: "License Plate",
                        controller: licensePlateCtrl,
                        hint: "License Plate",
                      ),

                      TmbhPengeluaranInputField(
                        label: "Total Weight",
                        controller: totalWeightCtrl,
                        hint: "Total Weight",
                      ),

                      TmbhPengeluaranInputField(
                        label: "Date",
                        controller: dateCtrl,
                        hint: "DD/MM/YYYY",
                        suffixIcon: Icons.calendar_today_outlined,
                      ),

                      TmbhPengeluaranInputField(
                        label: "Expedition",
                        controller: expeditionCtrl,
                        hint: "Expedition",
                      ),

                      TmbhPengeluaranInputField(
                        label: "Vehicle",
                        controller: vehicleCtrl,
                        hint: "Vehicle",
                      ),

                      TmbhPengeluaranInputField(
                        label: "Total Amount",
                        controller: totalAmountCtrl,
                        hint: "Total Amount",
                      ),

                      TmbhPengeluaranInputField(
                        label: "Driver",
                        controller: driverCtrl,
                        hint: "Driver",
                      ),

                      const SizedBox(height: 25),

                      /// ===== DETAIL ITEMS =====
                      const Text(
                        "Detail Pengeluaran Barang",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const ItemPengeluaranTile(
                        noSo: "SO-001",
                        namaBarang: "Barang A",
                        qty: "2 roll",
                        qtySo: "100",
                        qtyDikirim: "80",
                        sisa: "20",
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              /// ===== SAVE BUTTON =====
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
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
            ],
          );
        },
      ),
    );
  }
}
