import 'package:bbs_gudang/data/models/delivery_plan/request_delivery_plan.dart';
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
  final noDOCtrl = TextEditingController();

  final Map<String, int> _editedQuantities = {};

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

  SuratJalanRequestModel _buildPayload(
    PengeluaranBarangProvider pb, {
    required int status,
  }) {
    final dp = pb.detailDPCode!;
    final unitBusiness = dp.unitBussiness!;

    return SuratJalanRequestModel(
      deliveryPlanId: dp.id,
      unitBusinessId: unitBusiness.id,
      status: status, // 🔥 DINAMIS
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      vehicle: dp.vehicle?.name,
      nopol: dp.nopol,
      expeditionType: expeditionTypeCtrl.text,
      details: dp.details.map((detail) {
        return SuratJalanDetailPayload(
          soId: detail.salesOrder?.id ?? '',
          customerId: detail.customerId ?? '',
          customerName: detail.customer?.name ?? '',
          shipTo: detail.shipToAddress ?? '',
          npwp: detail.npwp ?? '',
          topId: detail.salesOrder?.top_id ?? '',
          items: detail.items.map((item) {
            final currentQty = _editedQuantities[item.item!.id] ?? item.qtyDp;
            return SuratJalanItemPayload(
              itemId: item.item!.id,
              qty: currentQty,
              price: item.price ?? 0,
              weight: (item.weight ?? 0).toDouble(),
              uomId: item.uom?.id ?? '',
              uomUnit: item.uomUnit,
              uomValue: item.uomValue ?? 1,
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  /// 🔄 AUTO FILL FROM DETAIL DP
  void _autoFill(PengeluaranBarangProvider pb) {
    final detail = pb.detailDPCode;
    if (detail == null) return;

    final firstDetail = detail.details.isNotEmpty == true
        ? detail.details.first
        : null;

    companyCtrl.text = detail.unitBussiness?.name ?? '';
    deliveryAreaCtrl.text = detail.deliveryArea?.code ?? '-';
    licensePlateCtrl.text = detail.nopol ?? '';
    totalWeightCtrl.text = detail.weight.toString() ?? '';
    dateCtrl.text = detail.date != null
        ? DateFormat('dd/MM/yyyy').format(detail.date!)
        : '';

    vehicleCtrl.text = detail.vehicle?.name ?? '';
    totalAmountCtrl.text = detail.total.toString() ?? '';
    driverCtrl.text = detail.driver ?? '';

    // ✅ EXPEDITION dari SALES ORDER di DETAILS
    expeditionTypeCtrl.text = firstDetail?.salesOrder?.expeditionType ?? '';
    expeditionCtrl.text = detail.unitBussiness?.name ?? '';
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
                        "No. Delivery Plan",
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

                            items: uniqueList.isEmpty
                                ? [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      enabled: false, // Agar tidak bisa dipilih
                                      child: Text(
                                        "No Pengeluaran Barang Kosong",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ]
                                : uniqueList.map((e) {
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
                                // 1️⃣ Fetch detail DP
                                await pb.fetchDetailDPCode(
                                  token: token,
                                  id: value,
                                );

                                _autoFill(pb);

                                // 2️⃣ Ambil unit business ID dari detail DP
                                final unitBusinessId =
                                    pb.detailDPCode?.unitBussiness?.id;

                                // 3️⃣ Generate No DO
                                if (unitBusinessId != null) {
                                  await pb.generateNoDO(
                                    token: token,
                                    unitBusinessId: unitBusinessId,
                                  );
                                }
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

                      // TmbhPengeluaranInputField(
                      //   label: "Total Amount",
                      //   controller: totalAmountCtrl,
                      //   hint: "Total Amount",
                      // ),
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

                      if (pb.detailDPCode?.details.isEmpty ?? true)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("Tidak ada detail item"),
                        ),

                      if (pb.detailDPCode != null)
                        Column(
                          children: pb.detailDPCode!.details
                              .expand(
                                (detail) => detail.items.map((item) {
                                  final soCode = detail.salesOrder?.code ?? "-";
                                  final namaBarang = item.item?.name ?? "-";
                                  final qtySo = item.qtySo;
                                  final qtyDp = item.qtyDp;
                                  final sisa = qtySo - qtyDp;
                                  final itemId = item.item!.id;
                                  final currentQty =
                                      _editedQuantities[itemId] ?? item.qtyDp;

                                  return ItemPengeluaranTile(
                                    noSo: soCode,
                                    noDO: pb.isLoadingDOCode
                                        ? "Generating..."
                                        : (pb.DOCode ?? "-"),
                                    namaBarang: namaBarang,
                                    qty: "$qtyDp ${item.uomUnit}",
                                    qtySo: qtySo.toString(),
                                    qtyDikirim: qtyDp.toString(),
                                    sisa: sisa.toString(),

                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            if (currentQty > 0) {
                                              setState(
                                                () =>
                                                    _editedQuantities[itemId] =
                                                        currentQty - 1,
                                              );
                                            }
                                          },
                                        ),
                                        Text(
                                          "$currentQty",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                            color: Colors.green,
                                          ),
                                          onPressed: () {
                                            // Batasi tambah agar tidak melebihi Qty SO jika diperlukan
                                            if (currentQty < item.qtySo) {
                                              setState(
                                                () =>
                                                    _editedQuantities[itemId] =
                                                        currentQty + 1,
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              )
                              .toList(),
                        ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              /// ===== SAVE BUTTON =====
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    /// ===== SAVE (DRAFT) =====
                    Expanded(
                      child: OutlinedButton(
                        onPressed: pb.isLoading
                            ? null
                            : () async {
                                if (!_isInputValid(pb)) return;
                                final token = context
                                    .read<AuthProvider>()
                                    .token;
                                if (token == null || pb.detailDPCode == null) {
                                  return;
                                }

                                final payload = _buildPayload(pb, status: 1);

                                final success = await pb
                                    .createPengeluaranBarang(
                                      token: token,
                                      payload: payload,
                                    );

                                if (success) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Draft berhasil disimpan",
                                        ),
                                      ),
                                    );
                                    // 🔙 KEMBALI KE HALAMAN LIST
                                    Navigator.pop(context, true);
                                  }
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          pb.errorMessage ??
                                              "Gagal simpan draft",
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF4CAF50)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// ===== POSTED =====
                    Expanded(
                      child: ElevatedButton(
                        onPressed: pb.isLoading
                            ? null
                            : () async {
                                if (!_isInputValid(pb)) return;
                                final token = context
                                    .read<AuthProvider>()
                                    .token;
                                if (token == null || pb.detailDPCode == null) {
                                  return;
                                }

                                final payload = _buildPayload(pb, status: 2);

                                final success = await pb
                                    .createPengeluaranBarang(
                                      token: token,
                                      payload: payload,
                                    );

                                if (success) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Pengeluaran Barang berhasil diposting",
                                        ),
                                      ),
                                    );
                                    // 🔙 KEMBALI KE HALAMAN LIST
                                    Navigator.pop(context, true);
                                  }
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          pb.errorMessage ??
                                              "Gagal posting data",
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "Posted",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isInputValid(PengeluaranBarangProvider pb) {
    if (pb.detailDPCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih Delivery Plan terlebih dahulu!"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }
}
