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
  // Definisi Warna Hijau BBS
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color secondaryGreen = const Color(0xFFE8F5E9);

  final noPBCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final deliveryAreaCtrl = TextEditingController();
  final licensePlateCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final driverCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialLoad());
  }

  Future<void> _initialLoad() async {
    final auth = context.read<AuthProvider>();
    final pb = context.read<PengeluaranBarangProvider>();
    final token = auth.token;

    if (token != null) {
      await pb.fetchDetailPengeluaranBrg(token: token, id: widget.pbId);
      await pb.fetchDeliveryPlanCode(token: token);

      final detail = pb.detailPengeluaranBarang;
      if (detail != null) {
        _fillControllers(detail);
        final dpId = detail.deliveryPlanId;

        if (dpId != null) {
          pb.setSelectedDeliveryPlanId(dpId);
          await pb.fetchDetailDPCode(token: token, id: dpId);

          if (pb.detailDPCode != null) {
            _syncQtyFromPBtoDP(pb); 
            setState(() {
              licensePlateCtrl.text = pb.detailDPCode?.nopol ?? '-';
              driverCtrl.text = pb.detailDPCode?.driver ?? '-';
              deliveryAreaCtrl.text =
                  pb.detailDPCode?.deliveryArea?.code ?? '-';
            });
          }
        }
      }
    }
  }

  void _syncQtyFromPBtoDP(PengeluaranBarangProvider pb) {
    final savedItems = pb.detailPengeluaranBarang?.pengeluaranBrgDetail ?? [];
    final dpDetails = pb.detailDPCode?.details ?? [];

    if (savedItems.isEmpty || dpDetails.isEmpty) return;

    for (var detail in dpDetails) {
      for (var item in detail.items) {
        // Cari item yang ID-nya cocok antara template DP dan data PB yang tersimpan
        final matchedSavedItem = savedItems.firstWhere(
          (saved) => saved.itemId == (item.item?.id ?? item.itemId),
          orElse: () => savedItems.firstWhere(
            (s) => s.itemId == item.itemId,
            orElse: () => savedItems[0],
          ), // fallback safety
        );

        // Jika ditemukan item yang sama di database PB, timpa qty-nya ke UI
        if (matchedSavedItem != null &&
            savedItems.any((s) => s.itemId == (item.item?.id ?? item.itemId))) {
          item.qtyDp = matchedSavedItem.qty;
        }
      }
    }
  }

  void _fillControllers(dynamic detail) {
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
        backgroundColor: primaryGreen, // Ubah ke Hijau sesuai gambar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Pengeluaran Barang",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PengeluaranBarangProvider>(
        builder: (context, pb, _) {
          if (pb.isLoading && pb.detailPengeluaranBarang == null) {
            return Center(
              child: CircularProgressIndicator(color: primaryGreen),
            );
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
                      const SizedBox(height: 20),
                      _buildLabel("No. Pengeluaran Barang"),
                      const SizedBox(height: 6),
                      TmbhPengeluaranInputField(
                        label: "",
                        hint: "",
                        controller: noPBCtrl,
                        enabled: false,
                      ),
                      const SizedBox(height: 15),
                      _buildLabel("No. Delivery Plan (Referensi)"),
                      const SizedBox(height: 6),
                      _buildDropdown(pb),
                      const SizedBox(height: 15),
                      const Divider(thickness: 1),
                      const SizedBox(height: 10),
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
                      Text(
                        "Detail Item",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryGreen, // Warna header item hijau
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDropdown(PengeluaranBarangProvider pb) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
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
    // Gunakan data dari detailDPCode karena ini yang menampung perubahan local/edit qty
    final details = pb.detailDPCode?.details;

    if (pb.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (details == null || details.isEmpty) {
      return const Center(child: Text("Tidak ada item ditemukan"));
    }

    return ListView.builder(
      // Lebih stabil daripada Column + map untuk list besar
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: details.length,
      itemBuilder: (context, dIdx) {
        final detail = details[dIdx];
        return Column(
          children: detail.items.asMap().entries.map((entryItem) {
            int iIdx = entryItem.key;
            var item = entryItem.value;

            return ItemPengeluaranTile(
              // Gunakan ID unik dari database agar Flutter tidak tertukar saat render
              key: ValueKey("item_${item.id}_${item.item?.id}"),
              noSo: detail.salesOrder?.code ?? "-",
              noDO: pb.detailPengeluaranBarang?.code ?? "-",
              namaBarang: item.item?.name ?? "-",
              qty: "${item.qtyDp} ${item.uomUnit}",
              qtySo: (item.qtySo ?? 0).toString(),
              qtyDikirim: (item.qtyDp ?? 0).toString(),
              sisa: ((item.qtySo ?? 0) - (item.qtyDp ?? 0)).toString(),
              isSwiped: true,
              onEditTap: () => _showEditQtyDialog(pb, dIdx, iIdx),
              onDeleteTap: () => _confirmDelete(pb, dIdx, iIdx),
            );
          }).toList(),
        );
      },
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
              onPressed: pb.isUpdating || pb.isLoading
                  ? null
                  : () => _handleUpdateLogic(pb, status: 1),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: pb.isUpdating
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryGreen,
                      ),
                    )
                  : Text(
                      "Save",
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: pb.isUpdating || pb.isLoading
                  ? null
                  : () => _handleUpdateLogic(pb, status: 2),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: pb.isUpdating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
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
    );
  }

  void _showEditQtyDialog(PengeluaranBarangProvider pb, int dIdx, int iIdx) {
    final item = pb.detailDPCode!.details[dIdx].items[iIdx];
    final qtyEditCtrl = TextEditingController(text: item.qtyDp.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          "Edit Qty: ${item.item?.name}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: qtyEditCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Masukkan Qty (${item.uomUnit})",
            labelStyle: TextStyle(color: primaryGreen),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryGreen),
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              double? newQty = double.tryParse(qtyEditCtrl.text);
              if (newQty != null) pb.updateItemQtyLocal(dIdx, iIdx, newQty);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
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

  void _handleUpdateLogic(
    PengeluaranBarangProvider pb, {
    required int status,
  }) async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;

    if (token == null || pb.detailDPCode == null) return;

    await pb.updatePengeluaranBrg(
      token: token,
      status: status,
      nopol: licensePlateCtrl.text,
      vehicle: driverCtrl.text,
      onSuccess: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 1 ? "Draft berhasil disimpan" : "Berhasil diposting",
            ),
            backgroundColor: primaryGreen,
          ),
        );
        Navigator.pop(context, true);
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      },
    );
  }
}
