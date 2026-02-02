import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/list_item/presentation/pages/tambah_item_page.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/pages/list_item_terpilih_page.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/providers/transfer_warehouse_provider.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/widgets/detail_item_terpilih.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TambahTransferPage extends StatefulWidget {
  const TambahTransferPage({super.key});

  @override
  State<TambahTransferPage> createState() => _TambahTransferPageState();
}

class _TambahTransferPageState extends State<TambahTransferPage> {
  String? selectedCompany;
  String? selectedGudangAwal;
  String? selectedGudangTujuan;

  final TextEditingController _catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();

    String? responsibilityId;
    if (auth.user!.userDetails.isNotEmpty) {
      final primaryDetail = auth.user!.userDetails.firstWhere(
        (d) => d.isPrimary == true,
        orElse: () => auth.user!.userDetails.first,
      );
      responsibilityId = primaryDetail.fResponsibility;
    }

    if (responsibilityId != null) {
      Future.microtask(() {
        context.read<TransferWarehouseProvider>().loadUserCompanies(
          token: auth.token ?? "",
          userId: auth.user?.id ?? "",
          responsibilityId: responsibilityId!,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransferWarehouseProvider>();
    final items = provider.items;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Transfer Warehouse",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Company"),
                  provider.isLoadingCompany
                      ? const Center(child: CircularProgressIndicator())
                      : _buildCompanyDropdown(provider),

                  const SizedBox(height: 20),

                  _buildLabel("Gudang Awal"),
                  _buildWarehouseDropdown(
                    provider: provider,
                    value: selectedGudangAwal,
                    hint: "Pilih Gudang Awal",
                    onChanged: (val) {
                      setState(() {
                        selectedGudangAwal = val;
                        if (selectedGudangTujuan == val) {
                          selectedGudangTujuan = null;
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildLabel("Gudang Tujuan"),
                  _buildWarehouseDropdown(
                    provider: provider,
                    value: selectedGudangTujuan,
                    hint: "Pilih Gudang Tujuan",
                    excludeId: selectedGudangAwal,
                    onChanged: (val) {
                      setState(() => selectedGudangTujuan = val);
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildLabel("Catatan Header"),
                  TextField(
                    controller: _catatanController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Catatan",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  DetailItemTerpilih(
                    count: items.length,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ListItemTerpilihPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4CAF50)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final token = context.read<AuthProvider>().token;

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TambahItem(token: token!),
                          ),
                        );

                        if (result != null && result is List) {
                          context.read<TransferWarehouseProvider>().setItems(
                            List<Map<String, dynamic>>.from(result),
                          );
                        }
                      },
                      child: const Text(
                        "+ Add Item",
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// ================= BOTTOM BUTTON =================
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Row(
              children: [
                /// SAVE AS DRAFT
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4CAF50)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await _submit(context, status: "DRAFT");
                      },
                      child: const Text(
                        "Save as Draft",
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// POSTED
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await _submit(context, status: "POSTED");
                      },
                      child: const Text(
                        "Posted",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //Function untuk menyimpan transfer
  Future<void> _submit(BuildContext context, {required String status}) async {
    final provider = context.read<TransferWarehouseProvider>();
    final auth = context.read<AuthProvider>();

    if (provider.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item belum dipilih')));
      return;
    }

    if (selectedCompany == null ||
        selectedGudangAwal == null ||
        selectedGudangTujuan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi data terlebih dahulu')),
      );
      return;
    }

    try {
      await provider.submitTransfer(
        token: auth.token!,
        unitBusinessId: selectedCompany!,
        sourceWarehouseId: selectedGudangAwal!,
        destinationWarehouseId: selectedGudangTujuan!,
        status: status,
        notes: _catatanController.text,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Transfer berhasil disimpan')));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // ================= HELPERS =================

  Widget _buildCompanyDropdown(TransferWarehouseProvider provider) {
    if (provider.isLoadingCompany) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.companies.isEmpty) {
      return const Text("Company tidak tersedia");
    }

    return DropdownButtonFormField<String>(
      value: provider.companies.any((c) => c.id == selectedCompany)
          ? selectedCompany
          : null,
      hint: const Text("Pilih Company"),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      items: provider.companies
          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
          .toList(),
      onChanged: (val) {
        debugPrint('Company dipilih: $val');

        if (val == null) return;

        setState(() {
          selectedCompany = val;
          selectedGudangAwal = null;
          selectedGudangTujuan = null;
        });

        if (val != null) {
          // debugPrint("Masuk");
          context.read<TransferWarehouseProvider>().loadWarehouseCompany(
            unitBusinessId: val,
            token: context.read<AuthProvider>().token!,
          );
        }
      },
    );
  }

  Widget _buildWarehouseDropdown({
    required TransferWarehouseProvider provider,
    required String? value,
    required String hint,
    String? excludeId,
    required Function(String?) onChanged,
  }) {
    final isEnabled = selectedCompany != null && provider.warehouses.isNotEmpty;

    return DropdownButtonFormField<String>(
      value: provider.warehouses.any((w) => w.id == value) ? value : null,
      hint: Text(hint),
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      items: provider.warehouses
          .where((w) => w.id != excludeId)
          .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
          .toList(),
      onChanged: isEnabled ? onChanged : null, // 🔥 INI KUNCI
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
