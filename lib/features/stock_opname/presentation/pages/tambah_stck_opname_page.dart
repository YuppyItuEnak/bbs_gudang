import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/list_item/presentation/pages/tambah_item_page.dart';
import 'package:bbs_gudang/features/stock_opname/presentation/providers/stock_opname_provider.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/providers/transfer_warehouse_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TambahStckOpnamePage extends StatefulWidget {
  const TambahStckOpnamePage({super.key});

  @override
  State<TambahStckOpnamePage> createState() => _TambahStckOpnamePageState();
}

class _TambahStckOpnamePageState extends State<TambahStckOpnamePage> {
  String? selectedCompanyId;
  String? selectedWarehouseId;
  String? selectedUserPICId;

  final TextEditingController _notesController = TextEditingController();
  final List<Map<String, dynamic>> selectedItems = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();

      String? responsibilityId;
      if (auth.user!.userDetails.isNotEmpty) {
        final primary = auth.user!.userDetails.firstWhere(
          (d) => d.isPrimary == true,
          orElse: () => auth.user!.userDetails.first,
        );
        responsibilityId = primary.fResponsibility;
      }

      context.read<TransferWarehouseProvider>().loadUserCompanies(
        token: auth.token!,
        userId: auth.user!.id,
        responsibilityId: responsibilityId!,
      );

      context.read<AuthProvider>().fetchUserPIC(token: auth.token!);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get isFormValid =>
      selectedCompanyId != null &&
      selectedWarehouseId != null &&
      selectedUserPICId != null &&
      selectedItems.isNotEmpty;

  Future<void> _navigateToSelectItem() async {
    final token = context.read<AuthProvider>().token;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahItem(token: token!, isOpnameMode: true),
      ),
    );

    if (result != null && result is List) {
      setState(() {
        for (final item in result) {
          final index = selectedItems.indexWhere((e) => e['id'] == item['id']);
          if (index != -1) {
            selectedItems[index]['qty'] += item['qty'];
          } else {
            selectedItems.add(item);
          }
        }
      });
    }
  }

  Future<void> _submitStockOpname(String status) async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<StockOpnameProvider>();

    final payload = {
      "unit_bussiness_id": selectedCompanyId,
      "warehouse_id": selectedWarehouseId,
      "pic_id": selectedUserPICId,
      "date": DateTime.now().toIso8601String().split('T').first,
      "notes": _notesController.text,
      "status": status,
      "details": selectedItems.map((item) {
        return {
          "item_id": item['id'],
          "current_on_hand_quantity": 0,
          "opname_qty": item['qty'],
        };
      }).toList(),
    };

    await provider.submitStockOpname(token: auth.token!, payload: payload);

    if (!mounted) return;

    if (provider.result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock Opname ${provider.result!.code} ($status) berhasil disimpan',
          ),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Stock Opname",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text("Company", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildCompanyDropdown(),
                  const SizedBox(height: 15),
                  const Text("Gudang", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildWarehouseDropdown(),
                  const SizedBox(height: 15),
                  const Text("User PIC", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildUserPICDropdown(),
                  const SizedBox(height: 15),
                  _buildNotesInput(),
                  const SizedBox(height: 25),
                  selectedItems.isEmpty
                      ? _buildInitialAddButton()
                      : _buildItemListSection(),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  // ===================== WIDGETS =====================

  Widget _buildCompanyDropdown() {
    return Consumer<TransferWarehouseProvider>(
      builder: (_, provider, __) {
        return _dropdownContainer(
          DropdownButton<String>(
            value: selectedCompanyId,
            hint: const Text("Pilih Company"),
            isExpanded: true,
            items: provider.companies
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (val) {
              setState(() {
                selectedCompanyId = val;
                selectedWarehouseId = null;
              });
              context.read<TransferWarehouseProvider>().loadWarehouseCompany(
                token: context.read<AuthProvider>().token!,
                unitBusinessId: val!,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWarehouseDropdown() {
    return Consumer<TransferWarehouseProvider>(
      builder: (_, provider, __) {
        if (selectedCompanyId == null) {
          return _disabledDropdown("Pilih Company terlebih dahulu");
        }

        return _dropdownContainer(
          DropdownButton<String>(
            value: selectedWarehouseId,
            hint: const Text("Pilih Gudang"),
            isExpanded: true,
            items: provider.warehouses
                .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                .toList(),
            onChanged: (val) => setState(() => selectedWarehouseId = val),
          ),
        );
      },
    );
  }

  Widget _buildUserPICDropdown() {
    return Consumer<AuthProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.userPIC.isEmpty) {
          return _disabledDropdown("Data User PIC kosong");
        }

        return DropdownButtonFormField<String>(
          value: selectedUserPICId,
          menuMaxHeight: 300,
          decoration: InputDecoration(
            hintText: "Pilih User PIC",
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: provider.userPIC
              .map(
                (u) => DropdownMenuItem(
                  value: u.id,
                  child: Text(u?.name ?? '-', overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => selectedUserPICId = val),
        );
      },
    );
  }

  Widget _buildNotesInput() {
    return TextField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: "Catatan (opsional)",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildInitialAddButton() {
    return OutlinedButton(
      onPressed: _navigateToSelectItem,
      child: const Text("+ Add Item"),
    );
  }

  Widget _buildItemListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Items",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "Hasil Opname",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...selectedItems.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  // Info Barang
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item['code'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Kontrol Qty
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.redAccent,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() {
                              if (selectedItems[index]['qty'] > 1) {
                                selectedItems[index]['qty']--;
                              } else {
                                // Tampilkan konfirmasi hapus jika qty sudah 1
                                _confirmRemoveItem(index);
                              }
                            });
                          },
                        ),
                        Container(
                          constraints: const BoxConstraints(minWidth: 40),
                          alignment: Alignment.center,
                          child: Text(
                            "${item['qty']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.green,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedItems[index]['qty']++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
        // Tombol Tambah Barang Lagi
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _navigateToSelectItem,
            icon: const Icon(Icons.add_box_outlined),
            label: const Text("Tambah Barang Lain"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Tambahkan fungsi helper untuk hapus item
  void _confirmRemoveItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Item?"),
        content: const Text(
          "Apakah Anda yakin ingin menghapus barang ini dari list opname?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              setState(() => selectedItems.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isFormValid
                    ? () => _submitStockOpname("DRAFT")
                    : null,
                child: const Text("Save as Draft"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: isFormValid
                    ? () => _submitStockOpname("POSTED")
                    : null,
                child: const Text("Post"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  Widget _disabledDropdown(String text) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }
}
