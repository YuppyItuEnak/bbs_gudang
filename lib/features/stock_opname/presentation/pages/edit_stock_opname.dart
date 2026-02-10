// ignore_for_file: use_build_context_synchronously

import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/list_item/presentation/pages/tambah_item_page.dart';
import 'package:bbs_gudang/features/stock_opname/presentation/providers/stock_opname_provider.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/providers/transfer_warehouse_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditStockOpnamePage extends StatefulWidget {
  final String opnameId;

  const EditStockOpnamePage({super.key, required this.opnameId});

  @override
  State<EditStockOpnamePage> createState() => _EditStockOpnamePageState();
}

class _EditStockOpnamePageState extends State<EditStockOpnamePage> {
  String? selectedCompanyId;
  String? selectedWarehouseId;
  String? selectedUserPICId;
  String? stockOpnameNo;
  final TextEditingController _notesController = TextEditingController();
  final List<Map<String, dynamic>> selectedItems = [];
  bool _isInitialLoading = true;
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  // Theme Colors
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color bgGrey = const Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final auth = context.read<AuthProvider>();
    final opnameProvider = context.read<StockOpnameProvider>();
    final twProvider = context.read<TransferWarehouseProvider>();

    try {
      await opnameProvider.fetchDetailOpnameReport(
        token: auth.token!,
        opnameId: widget.opnameId,
      );

      final detail = opnameProvider.listDetail;
      if (detail != null) {
        setState(() {
          selectedCompanyId = detail.unitBusinessId;
          selectedWarehouseId = detail.warehouseId;
          selectedUserPICId = detail.picId;
          _notesController.text = detail.notes ?? "";
          stockOpnameNo = detail.code;
          _selectedDate = detail.date;
          _dateController.text =
              "${detail.date.day}-${detail.date.month}-${detail.date.year}";

          selectedItems.clear();
          for (var d in detail.details) {
            selectedItems.add({
              'id': d.item?.id,
              'name': d.item?.name,
              'code': d.itemCode,
              'qty': d.opnameQty,
              'uom_id': d.item?.itemUomId,
              'detail_id': d.id,
            });
          }
        });

        String? responsibilityId;
        if (auth.user!.userDetails.isNotEmpty) {
          final primary = auth.user!.userDetails.firstWhere(
            (d) => d.isPrimary == true,
            orElse: () => auth.user!.userDetails.first,
          );
          responsibilityId = primary.fResponsibility;
        }

        await Future.wait([
          twProvider.loadUserCompanies(
            token: auth.token!,
            userId: auth.user!.id,
            responsibilityId: responsibilityId!,
          ),
          auth.fetchUserPIC(token: auth.token!),
          twProvider.loadWarehouseCompany(
            token: auth.token!,
            unitBusinessId: detail.unitBusinessId,
          ),
        ]);
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      setState(() => _isInitialLoading = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _dateController.dispose();
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  Future<void> _handleUpdate(String status) async {
    final auth = context.read<AuthProvider>();
    final opnameProvider = context.read<StockOpnameProvider>();

    String picName = "-";
    try {
      picName =
          auth.userPIC.firstWhere((u) => u.id == selectedUserPICId).name ?? "-";
    } catch (_) {}

    final payload = {
      "code": stockOpnameNo,
      "status": status,
      "unit_bussiness_id": selectedCompanyId,
      "date": _selectedDate?.toIso8601String().split('T').first,
      "pic_id": selectedUserPICId,
      "pic_name": picName,
      "warehouse_id": selectedWarehouseId,
      "notes": _notesController.text,
      "t_inventory_s_opname_d": selectedItems
          .map(
            (item) => {
              "item_id": item['id'],
              "item_code": item['code'],
              "item_uom_id": (item['uom_id']?.toString().isNotEmpty ?? false)
                  ? item['uom_id']
                  : null,
              "opname_qty": item['qty'],
            },
          )
          .toList(),
    };

    final success = await opnameProvider.updateStockOpname(
      token: auth.token!,
      opnameId: widget.opnameId,
      payload: payload,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update Berhasil'),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          "Edit Stock Opname",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: _isInitialLoading
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildSectionLabel("Data Referensi"),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(
                          "Stock Opname No",
                          stockOpnameNo ?? '-',
                        ),
                        const SizedBox(height: 16),
                        _buildCompanyDropdown(),
                        const SizedBox(height: 16),
                        _buildDateInput(),
                        const SizedBox(height: 16),
                        _buildWarehouseDropdown(),
                        const SizedBox(height: 16),
                        _buildUserPICDropdown(),
                        const SizedBox(height: 16),
                        _buildNotesInput(),
                        const SizedBox(height: 30),
                        _buildSectionLabel("Daftar Barang"),
                        const SizedBox(height: 12),
                        _buildItemListSection(),
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

  // --- UI COMPONENTS ---

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

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateInput() {
    return _fieldWrapper(
      label: "Tanggal Opname",
      child: TextField(
        controller: _dateController,
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: const InputDecoration(
          hintText: "Pilih Tanggal",
          prefixIcon: Icon(Icons.calendar_today, size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCompanyDropdown() {
    return Consumer<TransferWarehouseProvider>(
      builder: (_, provider, __) => _fieldWrapper(
        label: "Company",
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: provider.companies.any((c) => c.id == selectedCompanyId)
                ? selectedCompanyId
                : null,
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
        ),
      ),
    );
  }

  Widget _buildWarehouseDropdown() {
    return Consumer<TransferWarehouseProvider>(
      builder: (_, provider, __) => _fieldWrapper(
        label: "Gudang",
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: provider.warehouses.any((w) => w.id == selectedWarehouseId)
                ? selectedWarehouseId
                : null,
            hint: const Text("Pilih Gudang"),
            isExpanded: true,
            items: provider.warehouses
                .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                .toList(),
            onChanged: selectedCompanyId == null
                ? null
                : (val) => setState(() => selectedWarehouseId = val),
          ),
        ),
      ),
    );
  }

  Widget _buildUserPICDropdown() {
    return Consumer<AuthProvider>(
      builder: (_, provider, __) => _fieldWrapper(
        label: "User PIC",
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: provider.userPIC.any((u) => u.id == selectedUserPICId)
                ? selectedUserPICId
                : null,
            isExpanded: true,
            items: provider.userPIC
                .map(
                  (u) =>
                      DropdownMenuItem(value: u.id, child: Text(u.name ?? '-')),
                )
                .toList(),
            onChanged: (val) => setState(() => selectedUserPICId = val),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesInput() {
    return TextField(
      controller: _notesController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: "Catatan",
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

  Widget _buildItemListSection() {
    return Column(
      children: [
        ...selectedItems.asMap().entries.map((entry) {
          int idx = entry.key;
          var item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Label & Code
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          item['code'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Qty Controller
                  Row(
                    children: [
                      // Tombol Kurang
                      _qtyButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (item['qty'] > 1) {
                            setState(() => selectedItems[idx]['qty']--);
                          }
                        },
                      ),

                      // Angka Qty
                      Container(
                        constraints: const BoxConstraints(minWidth: 40),
                        alignment: Alignment.center,
                        child: Text(
                          "${item['qty']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      // Tombol Tambah
                      _qtyButton(
                        icon: Icons.add,
                        onTap: () {
                          setState(() => selectedItems[idx]['qty']++);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(width: 8),

                  // Delete Button
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => selectedItems.removeAt(idx)),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _navigateToSelectItem,
          icon: Icon(Icons.add_circle_outline, color: primaryGreen),
          label: Text(
            "Tambah Item Baru",
            style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Helper widget untuk tombol qty
  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgGrey,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildBottomButton() {
    final isSubmitting = context.watch<StockOpnameProvider>().isLoading;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: (isFormValid && !isSubmitting)
                  ? () => _handleUpdate("DRAFT")
                  : null,
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
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: (isFormValid && !isSubmitting)
                  ? () => _handleUpdate("POSTED")
                  : null,
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "UPDATE & POST",
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

  Widget _fieldWrapper({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
