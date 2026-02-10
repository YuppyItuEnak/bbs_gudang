// ignore_for_file: use_build_context_synchronously

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

  // Warna Brand (diambil dari nuansa hijau di gambar profil)
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color secondaryGreen = const Color(0xFFE8F5E9);

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
          behavior: SnackBarBehavior.floating,
          backgroundColor: primaryGreen,
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
      backgroundColor: const Color(0xFFF8F9FA), // Background sedikit abu bersih
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          "Tambah Stock Opname",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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
                  const SizedBox(height: 24),
                  _buildSectionLabel("Informasi Umum"),
                  const SizedBox(height: 12),
                  _buildCompanyDropdown(),
                  const SizedBox(height: 16),
                  _buildWarehouseDropdown(),
                  const SizedBox(height: 16),
                  _buildUserPICDropdown(),
                  const SizedBox(height: 16),
                  _buildNotesInput(),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionLabel("Daftar Item"),
                      if (selectedItems.isNotEmpty)
                        Text(
                          "${selectedItems.length} Item dipilih",
                          style: TextStyle(
                            color: primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  selectedItems.isEmpty
                      ? _buildInitialAddButton()
                      : _buildItemListSection(),
                  const SizedBox(height: 30),
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

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCompanyDropdown() {
    return Consumer<TransferWarehouseProvider>(
      builder: (_, provider, __) {
        return _dropdownFieldWrapper(
          label: "Company",
          child: DropdownButton<String>(
            value: selectedCompanyId,
            hint: const Text("Pilih Unit Bisnis"),
            isExpanded: true,
            underline: const SizedBox(),
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
        bool isDisabled = selectedCompanyId == null;
        return _dropdownFieldWrapper(
          label: "Gudang",
          child: DropdownButton<String>(
            value: selectedWarehouseId,
            hint: Text(isDisabled ? "Pilih Company dulu" : "Pilih Gudang"),
            isExpanded: true,
            underline: const SizedBox(),
            items: provider.warehouses
                .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                .toList(),
            onChanged: isDisabled
                ? null
                : (val) => setState(() => selectedWarehouseId = val),
          ),
        );
      },
    );
  }

  Widget _buildUserPICDropdown() {
    return Consumer<AuthProvider>(
      builder: (_, provider, __) {
        return _dropdownFieldWrapper(
          label: "User PIC",
          child: provider.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : DropdownButton<String>(
                  value: selectedUserPICId,
                  hint: const Text("Pilih Penanggung Jawab"),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: provider.userPIC
                      .map(
                        (u) => DropdownMenuItem(
                          value: u.id,
                          child: Text(
                            u.name ?? '-',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedUserPICId = val),
                ),
        );
      },
    );
  }

  Widget _buildNotesInput() {
    return TextField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: "Catatan",
        hintText: "Tambahkan keterangan tambahan...",
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildInitialAddButton() {
    return InkWell(
      onTap: _navigateToSelectItem,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline, size: 40, color: primaryGreen),
            const SizedBox(height: 8),
            const Text(
              "Belum ada item. Ketuk untuk menambah.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemListSection() {
    return Column(
      children: [
        ...selectedItems.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                item['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                item['code'],
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              trailing: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _qtyActionBtn(Icons.remove, () {
                      setState(() {
                        if (selectedItems[index]['qty'] > 1) {
                          selectedItems[index]['qty']--;
                        } else {
                          _confirmRemoveItem(index);
                        }
                      });
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "${item['qty']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _qtyActionBtn(Icons.add, () {
                      setState(() => selectedItems[index]['qty']++);
                    }, isAdd: true),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _navigateToSelectItem,
          icon: const Icon(Icons.add),
          label: const Text("Tambah Item Lainnya"),
          style: TextButton.styleFrom(foregroundColor: primaryGreen),
        ),
      ],
    );
  }

  Widget _qtyActionBtn(
    IconData icon,
    VoidCallback onTap, {
    bool isAdd = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isAdd ? primaryGreen : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            if (!isAdd)
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: isAdd ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  void _confirmRemoveItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Item?"),
        content: const Text("Hapus barang ini dari list opname?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
            ),
            onPressed: () {
              setState(() => selectedItems.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
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
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(color: primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isFormValid ? () => _submitStockOpname("DRAFT") : null,
              child: Text(
                "SIMPAN DRAFT",
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
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isFormValid
                  ? () => _submitStockOpname("POSTED")
                  : null,
              child: const Text(
                "POSTING",
                style: TextStyle(
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

  // Wrapper untuk merapikan Dropdown
  Widget _dropdownFieldWrapper({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: child,
        ),
      ],
    );
  }
}
