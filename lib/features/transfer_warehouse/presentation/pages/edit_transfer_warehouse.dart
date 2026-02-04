import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/providers/transfer_warehouse_provider.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/pages/list_item_terpilih_page.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/widgets/detail_item_terpilih.dart';
import 'package:bbs_gudang/features/list_item/presentation/pages/tambah_item_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditTransferWarehousePage extends StatefulWidget {
  final String transferId;

  const EditTransferWarehousePage({super.key, required this.transferId});

  @override
  State<EditTransferWarehousePage> createState() =>
      _EditTransferWarehousePageState();
}

class _EditTransferWarehousePageState extends State<EditTransferWarehousePage> {
  final TextEditingController _noTWController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? selectedDate;

  String? selectedGudangAwal;
  String? selectedGudangTujuan;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<TransferWarehouseProvider>();

    await provider.fetchDetailTransferWarehouse(
      token: auth.token!,
      id: widget.transferId,
    );

    final detail = provider.detailTransferWarehouse;
    if (detail != null) {
      setState(() {
        _noTWController.text = detail.code;
        _companyController.text = detail.unitBusiness.name;
        selectedGudangAwal = detail.sourceWarehouseId;
        selectedGudangTujuan = detail.destinationWarehouseId;
        _catatanController.text = detail.notes ?? "";
        if (detail.date != null) {
          selectedDate = DateTime.parse(detail.date.toString());
          _dateController.text = "${selectedDate!.toLocal()}".split(' ')[0];
        }
      });

      await provider.loadWarehouseCompany(
        unitBusinessId: detail.unitBusinessId,
        token: auth.token!,
      );

      // Mapping Items dengan menyertakan 'detail_id'
      final mappedItems = detail.details
          .map(
            (d) => {
              'detail_id':
                  d.id, // ID unik dari t_inventory_transfer_warehouse_d
              'id': d.itemId, // ID Master Item
              'item_code': d.itemCode,
              'item_name': d.itemName,
              'qty': d.qty,
              'uom_name': d.uom,
              'weight': d.weight,
              'notes': d.notes ?? "",
            },
          )
          .toList();

      provider.setItems(mappedItems);
    }
  }

  Future<void> _handleUpdate(BuildContext context, String status) async {
    final provider = context.read<TransferWarehouseProvider>();
    final auth = context.read<AuthProvider>();

    // Validasi input
    if (selectedGudangAwal == null || selectedGudangTujuan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gudang awal dan tujuan harus diisi")),
      );
      return;
    }

    final detail = provider.detailTransferWarehouse;
    if (detail == null) return;

    try {
      // Mencari nama gudang berdasarkan ID yang dipilih untuk payload objek relasi
      final sourceWarehouseName = provider.warehouses
          .firstWhere((w) => w.id == selectedGudangAwal)
          .name;
      final destWarehouseName = provider.warehouses
          .firstWhere((w) => w.id == selectedGudangTujuan)
          .name;

      await provider.updateTransfer(
        token: auth.token!,
        id: widget.transferId,
        code: _noTWController.text,
        unitBusinessId: detail.unitBusinessId,
        unitBusinessName: detail.unitBusiness.name,
        sourceWarehouseId: selectedGudangAwal!,
        sourceWarehouseName: sourceWarehouseName,
        destinationWarehouseId: selectedGudangTujuan!,
        destinationWarehouseName: destWarehouseName,
        status: status,
        notes: _catatanController.text,
        date: _dateController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Transfer berhasil diupdate ke $status")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal update: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransferWarehouseProvider>();
    final auth = context.read<AuthProvider>();
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
          "Edit Transfer Warehouse",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("No. Transfer Warehouse"),
                        _buildReadOnlyField(_noTWController),
                        const SizedBox(height: 16),
                        _buildLabel("Company"),
                        _buildReadOnlyField(_companyController),
                        const SizedBox(height: 16),
                        // Di dalam SingleChildScrollView -> Column
                        _buildLabel("Date"),
                        TextField(
                          controller: _dateController,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          decoration: InputDecoration(
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              color: Colors.green,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel("Gudang Awal"),
                        _buildWarehouseDropdown(
                          value: selectedGudangAwal,
                          onChanged: (val) =>
                              setState(() => selectedGudangAwal = val),
                          provider: provider,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel("Gudang Tujuan"),
                        _buildWarehouseDropdown(
                          value: selectedGudangTujuan,
                          excludeId: selectedGudangAwal,
                          onChanged: (val) =>
                              setState(() => selectedGudangTujuan = val),
                          provider: provider,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel("Catatan Header"),
                        TextField(
                          controller: _catatanController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        DetailItemTerpilih(
                          count: provider.items.length,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ListItemTerpilihPage(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAddButton(auth, provider),
                      ],
                    ),
                  ),
                ),
                _buildBottomButtons(provider),
              ],
            ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  // --- WIDGET HELPERS ---
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
    ),
  );

  Widget _buildReadOnlyField(TextEditingController controller) => TextField(
    controller: controller,
    enabled: false,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
  );

  Widget _buildWarehouseDropdown({
    required String? value,
    String? excludeId,
    required Function(String?) onChanged,
    required TransferWarehouseProvider provider,
  }) {
    return DropdownButtonFormField<String>(
      value: provider.warehouses.any((w) => w.id == value) ? value : null,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: provider.warehouses
          .where((w) => w.id != excludeId)
          .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildAddButton(
    AuthProvider auth,
    TransferWarehouseProvider provider,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TambahItem(token: auth.token!)),
          );

          if (result != null && result is List) {
            // Ambil list item yang sudah ada saat ini
            List<Map<String, dynamic>> currentItems = List.from(provider.items);

            // Tambahkan item-item baru hasil dari TambahItem ke list tersebut
            currentItems.addAll(List<Map<String, dynamic>>.from(result));

            // Masukkan kembali list yang sudah digabung ke provider
            provider.setItems(currentItems);
          }
        },
        child: const Text("+ Add Item"),
      ),
    );
  }

  Widget _buildBottomButtons(TransferWarehouseProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: provider.isSubmitting
                  ? null
                  : () => _handleUpdate(context, "DRAFT"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text("Save Draft"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: provider.isSubmitting
                  ? null
                  : () => _handleUpdate(context, "POSTED"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: provider.isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Posted"),
            ),
          ),
        ],
      ),
    );
  }
}
