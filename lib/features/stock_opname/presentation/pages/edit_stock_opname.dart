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
  String? stockOpnameNo; // Variabel baru untuk No Stock Opname
  String? opnameDate;

  final TextEditingController _notesController = TextEditingController();
  final List<Map<String, dynamic>> selectedItems = [];
  bool _isInitialLoading = true;
  final TextEditingController _dateController =
      TextEditingController(); // Controller untuk Tanggal
  DateTime? _selectedDate;

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
      // 1. Ambil detail data opname dari API
      await opnameProvider.fetchDetailOpnameReport(
        token: auth.token!,
        opnameId: widget.opnameId,
      );

      final detail = opnameProvider.listDetail;
      if (detail != null) {
        // 2. Isi form dengan data dari API
        setState(() {
          selectedCompanyId = detail.unitBusinessId;
          selectedWarehouseId = detail.warehouseId;
          selectedUserPICId = detail.picId;
          _notesController.text = detail.notes ?? "";
          stockOpnameNo = detail.code;
          _selectedDate = detail.date;
          _dateController.text =
              "${detail.date.day}-${detail.date.month}-${detail.date.year}";
          // Mapping items detail ke format list lokal
          selectedItems.clear();
          for (var d in detail.details) {
            selectedItems.add({
              'id': d.item?.id,
              'name': d.item?.name,
              'code': d.itemCode,
              'qty': d.opnameQty,
              'uom_id': d.item?.itemUomId,
              // Tambahkan detail_id jika API update membutuhkan ID baris tabel detail
              'detail_id': d.id,
            });
          }
        });

        // 3. Muat data pendukung dropdown (Company, Warehouse, PIC)
        // Load Company & PIC
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
          // Load Warehouse berdasarkan company yang terpilih
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
      MaterialPageRoute(builder: (_) => TambahItem(token: token!)),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  Future<void> _handleUpdate(String status) async {
    final auth = context.read<AuthProvider>();
    final opnameProvider = context.read<StockOpnameProvider>();

    // Mencari nama PIC berdasarkan ID yang dipilih untuk payload 'pic_name'
    String picName = "-";
    try {
      picName =
          auth.userPIC.firstWhere((u) => u.id == selectedUserPICId).name ?? "-";
    } catch (_) {}

    // Susun Payload sesuai request API Anda
    final payload = {
      "code": stockOpnameNo,
      "status": status,
      "unit_bussiness_id": selectedCompanyId,
      "date": _selectedDate?.toIso8601String().split('T').first,
      "pic_id": selectedUserPICId,
      "pic_name": picName,
      "warehouse_id": selectedWarehouseId,
      "notes": _notesController.text,
      "item_division_id": null,
      "item_kind_id": null,
      "item_group_id": null,
      "item_group_coa_id": null,
      "t_inventory_s_opname_d": selectedItems.map((item) {
        // Pastikan item_uom_id tidak string kosong ""
        final uomId =
            (item['uom_id'] != null && item['uom_id'].toString().isNotEmpty)
            ? item['uom_id']
            : null;

        return {
          "item_id": item['id'],
          "item_code": item['code'],
          "item_uom_id": uomId, // Kirim null jika kosong, jangan ""
          "opname_qty": item['qty'],
        };
      }).toList(),
    };

    // Eksekusi Update melalui Provider
    final success = await opnameProvider.updateStockOpname(
      token: auth.token!,
      opnameId: widget.opnameId,
      payload: payload,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock Opname $stockOpnameNo berhasil diperbarui ke $status',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Kembali ke list dan refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: ${opnameProvider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
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
          "Edit Stock Opname",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Company",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        _buildCompanyDropdown(),
                        const SizedBox(height: 15),
                        const Text(
                          "Stock Opname No",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        _buildReadOnlyField(stockOpnameNo ?? '-'),

                        const SizedBox(height: 15),

                        /// EDITABLE: DATE
                        const Text(
                          "Date",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        _buildDateInput(),
                        const Text(
                          "Gudang",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        _buildWarehouseDropdown(),
                        const SizedBox(height: 15),
                        const Text(
                          "User PIC",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        _buildUserPICDropdown(),
                        const SizedBox(height: 15),
                        _buildNotesInput(),
                        const SizedBox(height: 25),
                        _buildItemListSection(),
                      ],
                    ),
                  ),
                ),
                _buildBottomButton(),
              ],
            ),
    );
  }

  // --- UI HELPER WIDGETS (Sama dengan TambahPage dengan sedikit penyesuaian) ---

  Widget _buildDateInput() {
    return TextField(
      controller: _dateController,
      readOnly: true, // User tidak mengetik manual, tapi lewat picker
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        hintText: "Pilih Tanggal",
        prefixIcon: const Icon(Icons.calendar_today, size: 20),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  /// WIDGET READONLY (HANYA UNTUK NO STOCK OPNAME)
  Widget _buildReadOnlyField(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCompanyDropdown() {
    return Consumer<TransferWarehouseProvider>(
      builder: (_, provider, __) {
        return _dropdownContainer(
          DropdownButton<String>(
            value: provider.companies.any((c) => c.id == selectedCompanyId)
                ? selectedCompanyId
                : null,
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
            value: provider.warehouses.any((w) => w.id == selectedWarehouseId)
                ? selectedWarehouseId
                : null,
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
        return DropdownButtonFormField<String>(
          value: provider.userPIC.any((u) => u.id == selectedUserPICId)
              ? selectedUserPICId
              : null,
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
                  child: Text(u.name ?? '-', overflow: TextOverflow.ellipsis),
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

  Widget _buildItemListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Items", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              "${selectedItems.length} Items",
              style: const TextStyle(color: Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...selectedItems.asMap().entries.map((entry) {
          int idx = entry.key;
          var item = entry.value;
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: ListTile(
              title: Text(
                item['name'],
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(item['code']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Qty: ${item['qty']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () =>
                        setState(() => selectedItems.removeAt(idx)),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _navigateToSelectItem,
            icon: const Icon(Icons.add),
            label: const Text("Add Item"),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    final isSubmitting = context.watch<StockOpnameProvider>().isLoading;

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
                onPressed: (isFormValid && !isSubmitting)
                    ? () => _handleUpdate("DRAFT")
                    : null,
                child: const Text("Update Draft"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
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
                    : const Text("Update & Post"),
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
