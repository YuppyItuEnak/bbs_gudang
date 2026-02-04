import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';

import 'package:bbs_gudang/features/pengeluaran_barang/presentation/providers/pengeluaran_barang_provider.dart';

import 'package:bbs_gudang/features/pengeluaran_barang/presentation/widgets/tmbh_pengeluaran_input_field.dart';

import 'package:bbs_gudang/features/pengeluaran_barang/presentation/widgets/item_pengeluaran_tile.dart';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

class EditPengeluaranBrgPage extends StatefulWidget {
  final String pbId;

  const EditPengeluaranBrgPage({super.key, required this.pbId});

  @override
  State<EditPengeluaranBrgPage> createState() => _EditPengeluaranBrgPageState();
}

class _EditPengeluaranBrgPageState extends State<EditPengeluaranBrgPage> {
  final noPBCtrl = TextEditingController();

  final companyCtrl = TextEditingController();

  final deliveryAreaCtrl = TextEditingController();

  final licensePlateCtrl = TextEditingController();

  final dateCtrl = TextEditingController();

  final driverCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Gunakan postFrameCallback agar context tersedia dengan aman

    WidgetsBinding.instance.addPostFrameCallback((_) => _initialLoad());
  }

  Future<void> _initialLoad() async {
    final auth = context.read<AuthProvider>();
    final pb = context.read<PengeluaranBarangProvider>();
    final token = auth.token;

    if (token != null) {
      // 1. Ambil detail utama PB
      await pb.fetchDetailPengeluaranBrg(token: token, id: widget.pbId);

      // 2. Ambil list semua DP untuk dropdown
      await pb.fetchDeliveryPlanCode(token: token);

      final detail = pb.detailPengeluaranBarang;
      if (detail != null) {
        _fillControllers(detail);

        // --- PERBAIKAN DI SINI ---
        // Cek apakah delivery_plan_id ada (sesuai JSON yang anda kirim)
        // Jika model Anda memetakan delivery_plan_id ke field lain, sesuaikan.
        final dpId = detail
            .deliveryPlanId; // Pastikan di Model detail ini mengarah ke 'delivery_plan_id'

        if (dpId != null) {
          print("DEBUG: Menemukan DP ID dari JSON: $dpId");

          // Set ID agar dropdown terpilih
          pb.setSelectedDeliveryPlanId(dpId);

          // Ambil detail item berdasarkan DP tersebut
          await pb.fetchDetailDPCode(token: token, id: dpId);

          // Setelah fetch, update controller field yang bergantung pada DP
          if (pb.detailDPCode != null) {
            setState(() {
              licensePlateCtrl.text = pb.detailDPCode?.nopol ?? '-';
              driverCtrl.text = pb.detailDPCode?.driver ?? '-';
              deliveryAreaCtrl.text =
                  pb.detailDPCode?.deliveryArea?.code ?? '-';
            });
          }
        } else {
          print("DEBUG: delivery_plan_id TIDAK DITEMUKAN di JSON");
        }
      }
    }
  }

  void _fillControllers(dynamic detail) {
    print("DEBUG: Data masuk ke controller -> ${detail.code}");

    setState(() {
      noPBCtrl.text = detail.code ?? '';

      companyCtrl.text = detail.unitBussinessModel?.name ?? '-';

      deliveryAreaCtrl.text = detail.deliveryArea ?? '-';

      licensePlateCtrl.text = detail.deliveryPlan?.nopol ?? '-';

      driverCtrl.text = detail.deliveryPlan?.driver ?? '-';

      if (detail.date != null && detail.date!.isNotEmpty) {
        try {
          DateTime parsedDate = DateTime.parse(detail.date!);

          dateCtrl.text = DateFormat('dd/MM/yyyy').format(parsedDate);
        } catch (e) {
          dateCtrl.text = detail.date!;
        }
      }
    });
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
          "Edit Pengeluaran Barang",

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
          // Jika sedang loading detail utama

          if (pb.isLoading && pb.detailPengeluaranBarang == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (pb.detailPengeluaranBarang == null) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // Di dalam Column children:
                      const Text(
                        "No. Pengeluaran Barang",

                        style: TextStyle(
                          fontSize: 13,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Tampilkan No PB asli (Disabled)
                      TmbhPengeluaranInputField(
                        label: "",

                        hint: "",

                        controller: noPBCtrl,

                        enabled: false,
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "No. Delivery Plan (Referensi)",

                        style: TextStyle(
                          fontSize: 13,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      _buildDropdown(pb), // Ini untuk ganti DP

                      const SizedBox(height: 15),

                      const Divider(),

                      TmbhPengeluaranInputField(
                        label: "Company",

                        hint: "Company",

                        controller: companyCtrl,

                        enabled: false,
                      ),

                      TmbhPengeluaranInputField(
                        label: "Delivery Area",

                        hint: "Area",

                        controller: deliveryAreaCtrl,

                        enabled: false,
                      ),

                      TmbhPengeluaranInputField(
                        label: "License Plate",

                        hint: "Nopol",

                        controller: licensePlateCtrl,

                        enabled: false,
                      ),

                      TmbhPengeluaranInputField(
                        label: "Driver",

                        hint: "Driver",

                        controller: driverCtrl,

                        enabled: false,
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        "Detail Item",

                        style: TextStyle(
                          fontWeight: FontWeight.bold,

                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildItemList(pb),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              _buildActionButtons(pb),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdown(PengeluaranBarangProvider pb) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),

      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),

        borderRadius: BorderRadius.circular(10),

        border: Border.all(color: Colors.grey.shade300),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,

          value:
              pb.listDeliveryPlanCode.any(
                (e) => e.id == pb.selectedDeliveryPlanId,
              )
              ? pb.selectedDeliveryPlanId
              : null,

          hint: const Text("Pilih Delivery Plan"),

          items: pb.listDeliveryPlanCode.map((e) {
            return DropdownMenuItem<String>(
              value: e.id,

              child: Text(e.code, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),

          onChanged: (value) async {
            if (value == null) return;

            pb.setSelectedDeliveryPlanId(value);

            final token = context.read<AuthProvider>().token;

            if (token != null) {
              await pb.fetchDetailDPCode(token: token, id: value);

              // Trigger auto-fill manual jika data DP berubah

              if (pb.detailDPCode != null) {
                deliveryAreaCtrl.text =
                    pb.detailDPCode?.deliveryArea?.code ?? '-';

                licensePlateCtrl.text = pb.detailDPCode?.nopol ?? '-';

                driverCtrl.text = pb.detailDPCode?.driver ?? '-';
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildItemList(PengeluaranBarangProvider pb) {
    if (pb.detailDPCode == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    if (pb.detailDPCode!.details.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: Text("Tidak ada item ditemukan")),
      );
    }

    return Column(
      // Penting: Pastikan Column tidak menyebabkan unbounded constraints
      mainAxisSize: MainAxisSize.min,
      children: pb.detailDPCode!.details.asMap().entries.expand((entryDetail) {
        int dIdx = entryDetail.key;
        return entryDetail.value.items.asMap().entries.map((entryItem) {
          int iIdx = entryItem.key;
          var item = entryItem.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: LayoutBuilder(
              // Menggunakan LayoutBuilder untuk memastikan constraints
              builder: (context, constraints) {
                return ItemPengeluaranTile(
                  noSo: entryDetail.value.salesOrder?.code ?? "-",
                  noDO: pb.isLoadingDOCode ? "Wait..." : (pb.detailPengeluaranBarang?.code ?? "-"),
                  namaBarang: item.item?.name ?? "-",
                  qty: "${item.qtyDp} ${item.uomUnit}",
                  qtySo: (item.qtySo ?? 0).toString(),
                  qtyDikirim: (item.qtyDp ?? 0).toString(),
                  sisa: ((item.qtySo ?? 0) - (item.qtyDp ?? 0)).toString(),
                  isSwiped: true,
                  onEditTap: () => _showEditQtyDialog(pb, dIdx, iIdx),
                  onDeleteTap: () => _confirmDelete(pb, dIdx, iIdx),
                );
              },
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildActionButtons(PengeluaranBarangProvider pb) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),

      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),

            blurRadius: 10,

            offset: const Offset(0, -5),
          ),
        ],
      ),

      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),

              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),

                minimumSize: const Size(0, 50),
              ),

              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: ElevatedButton(
              onPressed: pb.isLoading ? null : () => _handleUpdate(pb),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),

                minimumSize: const Size(0, 50),
              ),

              child: Text(
                pb.isLoading ? "..." : "Update",

                style: const TextStyle(
                  color: Colors.white,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Dialogs ---

  void _showEditQtyDialog(PengeluaranBarangProvider pb, int dIdx, int iIdx) {
    final item = pb.detailDPCode!.details[dIdx].items[iIdx];

    final qtyEditCtrl = TextEditingController(text: item.qtyDp.toString());

    showDialog(
      context: context,

      builder: (context) => AlertDialog(
        title: Text(
          "Edit Qty: ${item.item?.name}",

          style: const TextStyle(fontSize: 16),
        ),

        content: TextField(
          controller: qtyEditCtrl,

          keyboardType: TextInputType.number,

          decoration: InputDecoration(
            labelText: "Masukkan Qty (${item.uomUnit})",

            border: const OutlineInputBorder(),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),

            child: const Text("Batal"),
          ),

          ElevatedButton(
            onPressed: () {
              double? newQty = double.tryParse(qtyEditCtrl.text);

              if (newQty != null) pb.updateItemQtyLocal(dIdx, iIdx, newQty);

              Navigator.pop(context);
            },

            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(PengeluaranBarangProvider pb, int dIdx, int iIdx) {
    showDialog(
      context: context,

      builder: (context) => AlertDialog(
        title: const Text("Hapus Item"),

        content: const Text("Apakah Anda yakin ingin menghapus item ini?"),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),

            child: const Text("Batal"),
          ),

          TextButton(
            onPressed: () {
              pb.removeItemLocal(dIdx, iIdx);

              Navigator.pop(context);
            },

            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleUpdate(PengeluaranBarangProvider pb) async {
    // Jalankan logika update data ke API
  }
}
