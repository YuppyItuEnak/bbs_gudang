import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/list_item/presentation/pages/tambah_item_page.dart';
import 'package:bbs_gudang/features/stock_adjustment/presentation/providers/stock_adjustment_provider.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/providers/transfer_warehouse_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditStkAdjustPage extends StatefulWidget {
  final String id;

  const EditStkAdjustPage({super.key, required this.id});

  @override
  State<EditStkAdjustPage> createState() => _EditStkAdjustPageState();
}

class _EditStkAdjustPageState extends State<EditStkAdjustPage> {
  // Warna Tema (Diselaraskan dengan Tambah Page)
  final Color primaryGreen = const Color(0xff4CAF50);
  final Color backgroundGrey = const Color(0xffF5F5F5);

  String? selectedCompanyId;
  String? selectedWarehouseId;
  String? selectedOpnameId;
  String? adjustmentCode;

  final TextEditingController _catatanController = TextEditingController();
  List<Map<String, dynamic>> selectedItems = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final provider = context.read<StockAdjustmentProvider>();
      final transferProvider = context.read<TransferWarehouseProvider>();

      await provider.fetchDetailAdjustment(token: auth.token!, id: widget.id);

      final detail = provider.detailData;
      if (detail == null) return;

      selectedCompanyId = detail.unitBusinessId;
      adjustmentCode = detail.code;
      selectedWarehouseId = detail.warehouseId;
      selectedOpnameId = detail.opnameId;
      _catatanController.text = detail.notes ?? '';

      String? responsibilityId;
      if (auth.user!.userDetails.isNotEmpty) {
        final primary = auth.user!.userDetails.firstWhere(
          (e) => e.isPrimary == true,
          orElse: () => auth.user!.userDetails.first,
        );
        responsibilityId = primary.fResponsibility;
      }

      await transferProvider.loadUserCompanies(
        token: auth.token!,
        userId: auth.user!.id,
        responsibilityId: responsibilityId!,
      );

      await transferProvider.loadWarehouseCompany(
        token: auth.token!,
        unitBusinessId: selectedCompanyId!,
      );

      await provider.loadOpnameReference(
        token: auth.token!,
        unitBusinessId: selectedCompanyId!,
        warehouseId: selectedWarehouseId!,
      );

      selectedItems = detail.details.map<Map<String, dynamic>>((e) {
        return {
          "id": e.item?.id ?? e.id,
          "name": e.item?.name ?? "-",
          "code": e.item?.code ?? e.itemCode,
          "item_uom_id": e.item?.itemUomId,
          "item_group_coa_id": e.item?.itemGroupCoaId,
          "qty": (e.qtyAfter as num).toDouble(),
          "qtyBefore": (e.qtyBefore ?? 0 as num).toDouble(),
          "adjustment": (e.adjustment ?? 0 as num).toDouble(),
          "reason": e.reason ?? "",
        };
      }).toList();

      setState(() {});
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToSelectItem() async {
    final token = context.read<AuthProvider>().token!;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TambahItem(token: token, warehouseId: selectedWarehouseId,)),
    );

    if (result != null && result is List) {
      setState(() {
        for (final newItem in result) {
          final index = selectedItems.indexWhere(
            (e) => e['id'] == newItem['id'],
          );

          if (index != -1) {
            selectedItems[index]['qty'] =
                (selectedItems[index]['qty'] ?? 0) + (newItem['qty'] ?? 1);
            selectedItems[index]['adjustment'] =
                selectedItems[index]['qty'] -
                (selectedItems[index]['qtyBefore'] ?? 0);
          } else {
            selectedItems.add({
              "id": newItem['id'],
              "name": newItem['name'],
              "code": newItem['code'],
              "item_uom_id": newItem['item_uom_id'],
              "item_group_coa_id": newItem['item_group_coa_id'],
              "qty": (newItem['qty'] ?? 1 as num).toDouble(),
              "qtyBefore": (newItem['qty_before'] ?? 0 as num).toDouble(),
              "adjustment": 0.0,
              "reason": "",
            });
          }
        }
      });
    }
  }

  void _updateQty(int index, double delta) {
    setState(() {
      double currentQty = selectedItems[index]['qty'];
      double newQty = currentQty + delta;
      if (newQty >= 0) {
        selectedItems[index]['qty'] = newQty;
        selectedItems[index]['adjustment'] =
            newQty - (selectedItems[index]['qtyBefore'] ?? 0);
      }
    });
  }

  Future<void> _submitAdjustment({required bool sendApproval}) async {
    if (selectedItems.isEmpty) {
      _showError("Item belum ditambahkan");
      return;
    }

    final auth = context.read<AuthProvider>();
    final provider = context.read<StockAdjustmentProvider>();

    if (sendApproval) {
      final canSubmit = await provider.checkCanSubmit(
        token: auth.token!,
        authUserId: auth.user!.id,
        menuId: '4ad48011-9a08-4073-bde0-10f88bfebc81',
        unitBusinessId: selectedCompanyId,
      );

      if (!canSubmit) {
        _showError('Anda tidak memiliki otoritas untuk submit approval');
        return;
      }
    }

    final payload = {
      "unit_bussiness_id": selectedCompanyId,
      "warehouse_id": selectedWarehouseId,
      "opname_id": selectedOpnameId,
      "notes": _catatanController.text,
      "submitted_by": auth.user!.id,
      "status": sendApproval ? "POSTED" : "DRAFT",
      "date": DateTime.now().toIso8601String().split('T').first,
      "inventory_adjustment_account_id":
          provider.selectedOpname?['inventory_adjustment_account_id'],
      "total_diff": 0,
      "io_multiplier": 1,
      "t_inventory_s_adjustment_d": selectedItems.map((e) {
        return {
          "item_id": e['id'],
          "item_code": e['code'],
          "item_uom_id": e['item_uom_id'],
          "item_group_coa_id": e['item_group_coa_id'],
          "qty_before": e['qtyBefore'],
          "qty_after": e['qty'],
          "adjustment": e['adjustment'],
          "reason": e['reason'] ?? "",
          "notes": "",
          "cost": 0,
        };
      }).toList(),
    };

    final success = await provider.updateStockAdjustment(
      token: auth.token!,
      id: widget.id,
      payload: payload,
    );

    if (!success) {
      _showError(provider.updateError ?? "Gagal update adjustment");
      return;
    }

    _showSuccess("Stock Adjustment berhasil diperbarui");
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Edit Stock Adjustment",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Consumer<StockAdjustmentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionCard("Informasi Utama", [
                        _fieldLabel("No. Adjustment"),
                        _readonlyBox(adjustmentCode ?? "-"),
                        const SizedBox(height: 16),
                        _fieldLabel("Company"),
                        _buildCompanySelector(),
                        const SizedBox(height: 16),
                        _fieldLabel("Gudang"),
                        _buildGudangSelector(),
                      ]),
                      const SizedBox(height: 20),
                      _sectionCard("Referensi & Catatan", [
                        _fieldLabel("Referensi Opname"),
                        _buildOpnameDropdown(),
                        const SizedBox(height: 16),
                        _fieldLabel("Catatan"),
                        _buildTextInput(
                          _catatanController,
                          "Tulis catatan di sini...",
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildItemSection(),
                    ],
                  ),
                ),
              ),
              _buildBottomButton(provider),
            ],
          );
        },
      ),
    );
  }

  // --- REUSABLE UI COMPONENTS ---

  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryGreen,
              fontSize: 14,
            ),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Colors.black87,
      ),
    ),
  );

  Widget _readonlyBox(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildItemSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Daftar Item",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: _navigateToSelectItem,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text("Tambah Item"),
              style: TextButton.styleFrom(foregroundColor: primaryGreen),
            ),
          ],
        ),
        if (selectedItems.isEmpty)
          _emptyItemPlaceholder()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedItems.length,
            itemBuilder: (context, index) {
              final item = selectedItems[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item['code'] ?? '-',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Adj: ${item['adjustment']}",
                            style: TextStyle(
                              fontSize: 11,
                              color: (item['adjustment'] ?? 0) >= 0
                                  ? Colors.blue
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => _updateQty(index, -1),
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.redAccent,
                            ),
                          ),
                          Text(
                            "${item['qty']}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () => _updateQty(index, 1),
                            icon: Icon(Icons.add_circle, color: primaryGreen),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          setState(() => selectedItems.removeAt(index)),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _emptyItemPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text("Belum ada item terpilih", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBottomButton(StockAdjustmentProvider provider) {
    bool isLoading = provider.isUpdating;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading
                  ? null
                  : () => _submitAdjustment(sendApproval: false),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(color: primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Update Draft",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => _submitAdjustment(sendApproval: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Send Approval",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SELECTORS ---

  Widget _buildCompanySelector() {
    return Consumer<TransferWarehouseProvider>(
      builder: (_, provider, __) => _buildDropdown(
        value: selectedCompanyId,
        hint: "Pilih Company",
        items: provider.companies
            .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
            .toList(),
        onChanged: (val) async {
          if (val == null) return;
          setState(() {
            selectedCompanyId = val;
            selectedWarehouseId = null;
            selectedOpnameId = null;
          });
          await provider.loadWarehouseCompany(
            token: context.read<AuthProvider>().token!,
            unitBusinessId: val,
          );
        },
      ),
    );
  }

  Widget _buildGudangSelector() {
    return Consumer<TransferWarehouseProvider>(
      builder: (_, provider, __) => _buildDropdown(
        value: selectedWarehouseId,
        hint: "Pilih Gudang",
        items: provider.warehouses
            .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
            .toList(),
        onChanged: (val) async {
          if (val == null) return;
          setState(() {
            selectedWarehouseId = val;
            selectedOpnameId = null;
          });
          await context.read<StockAdjustmentProvider>().loadOpnameReference(
            token: context.read<AuthProvider>().token!,
            unitBusinessId: selectedCompanyId!,
            warehouseId: val,
          );
        },
      ),
    );
  }

  Widget _buildOpnameDropdown() {
    return Consumer<StockAdjustmentProvider>(
      builder: (_, provider, __) => _buildDropdown(
        value: selectedOpnameId,
        hint: "Pilih Referensi Opname",
        items: provider.opnames
            .map<DropdownMenuItem<String>>(
              (o) => DropdownMenuItem(value: o['id'], child: Text(o['code'])),
            )
            .toList(),
        onChanged: (val) => setState(() => selectedOpnameId = val),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?>? onChanged,
  }) {
    // Pengecekan Keamanan:
    // Pastikan 'value' ada di dalam daftar 'items'. Jika tidak ada, paksa jadi null.
    String? safeValue = value;
    if (value != null) {
      final bool hasValue = items.any((item) => item.value == value);
      if (!hasValue) {
        safeValue = null;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: safeValue, // Gunakan safeValue
          hint: Text(hint, style: const TextStyle(fontSize: 13)),
          items: items,
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down, color: primaryGreen),
        ),
      ),
    );
  }

  Widget _buildTextInput(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
