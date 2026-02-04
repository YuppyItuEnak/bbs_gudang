import 'dart:convert';

import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/list_item/presentation/pages/tambah_item_page.dart';
import 'package:bbs_gudang/features/stock_adjustment/presentation/providers/stock_adjustment_provider.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/providers/transfer_warehouse_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TambahStkAdjustPage extends StatefulWidget {
  const TambahStkAdjustPage({super.key});

  @override
  State<TambahStkAdjustPage> createState() => _TambahStkAdjustPageState();
}

class _TambahStkAdjustPageState extends State<TambahStkAdjustPage> {
  String? selectedCompanyId;
  String? selectedWarehouseId;
  String? selectedOpnameId;
  DateTime? selectedDate;

  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  List<Map<String, dynamic>> selectedItems = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final companyProvider = context.read<TransferWarehouseProvider>();
      final stockProvider = context.read<StockAdjustmentProvider>();

      // ✅ Generate Code Saat Masuk
      await stockProvider.generateCode(token: auth.token!);

      // Load Company
      String? responsibilityId;
      if (auth.user!.userDetails.isNotEmpty) {
        final primary = auth.user!.userDetails.firstWhere(
          (e) => e.isPrimary == true,
          orElse: () => auth.user!.userDetails.first,
        );
        responsibilityId = primary.fResponsibility;
      }

      companyProvider.loadUserCompanies(
        token: auth.token!,
        userId: auth.user!.id,
        responsibilityId: responsibilityId!,
      );
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(msg)));
  }

  // ===============================
  // DATE PICKER
  // ===============================
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // ===============================
  // SELECT ITEM
  // ===============================
  void _navigateToSelectItem() async {
    final token = context.read<AuthProvider>().token!;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TambahItem(token: token)),
    );

    // ✅ DEBUG RAW RESULT
    // debugPrint("RAW RESULT FROM TambahItemPage => $result");

    if (result != null && result is List) {
      setState(() {
        for (final item in result) {
          // ✅ DEBUG RAW ITEM
          // debugPrint("RAW ITEM => $item");
          debugPrint("DEBUG: Data item dari pencarian => $item");

          final itemId = item['id'];

          final index = selectedItems.indexWhere((e) => e['item_id'] == itemId);

          if (index != -1) {
            selectedItems[index]['qty'] =
                (selectedItems[index]['qty'] ?? 0) + (item['qty'] ?? 1);
          } else {
            selectedItems.add({
              "item_id": item['id'],
              "code": item['code'],
              "name": item['name'],
              "item_uom_id": item['item_uom_id'], // HARUS DARI API ITEM
              "item_group_coa_id": item['item_group_coa_id'],
              "qty_before": item['qty_before'] ?? 0,
              "qty_after": item['qty'] ?? 1,
              "cost": item['cost'] ?? 0,
            });
          }
        }
      });

      debugPrint("NORMALIZED ITEMS => $selectedItems");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FB),
      appBar: AppBar(
        title: const Text(
          "Stock Adjustment",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("No Adjustment"),
                  _buildAdjustmentCode(),
                  const SizedBox(height: 16),

                  _sectionTitle("Company"),
                  _buildCompanySelector(),
                  const SizedBox(height: 16),

                  _sectionTitle("Gudang"),
                  _buildGudangSelector(),
                  const SizedBox(height: 16),

                  _sectionTitle("Referensi Opname"),
                  _buildOpnameDropdown(),
                  const SizedBox(height: 16),

                  _sectionTitle("Tanggal Adjustment"),
                  _buildDateField(),
                  const SizedBox(height: 16),

                  _sectionTitle("Catatan"),
                  _buildTextInput(_catatanController, "Catatan"),
                  const SizedBox(height: 24),

                  _buildItemSection(),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  // ===============================
  // CODE DISPLAY
  // ===============================
  Widget _buildAdjustmentCode() {
    return Consumer<StockAdjustmentProvider>(
      builder: (_, provider, __) {
        if (provider.isGeneratingCode) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text("Generating code..."),
              ],
            ),
          );
        }

        if (provider.generatedCode == null) {
          return const Text(
            "Failed generate code",
            style: TextStyle(color: Colors.red),
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            provider.generatedCode!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  // ===============================
  // COMPANY
  // ===============================
  Widget _buildCompanySelector() {
    return Consumer<TransferWarehouseProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingCompany) {
          return const CircularProgressIndicator();
        }

        return _buildDropdown(
          value: selectedCompanyId,
          hint: "Pilih Company",
          items: provider.companies
              .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedCompanyId = val;
              selectedWarehouseId = null;
              selectedOpnameId = null;
              selectedItems.clear();
            });

            provider.loadWarehouseCompany(
              token: context.read<AuthProvider>().token!,
              unitBusinessId: val!,
            );
          },
        );
      },
    );
  }

  // ===============================
  // GUDANG
  // ===============================
  Widget _buildGudangSelector() {
    return Consumer<TransferWarehouseProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingWarehouse) {
          return const CircularProgressIndicator();
        }

        return _buildDropdown(
          value: selectedWarehouseId,
          hint: "Pilih Gudang",
          items: provider.warehouses
              .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
              .toList(),
          onChanged: selectedCompanyId == null
              ? null
              : (val) {
                  setState(() {
                    selectedWarehouseId = val;
                    selectedOpnameId = null;
                  });

                  final opnameProvider = context
                      .read<StockAdjustmentProvider>();

                  opnameProvider.clear();

                  opnameProvider.loadOpnameReference(
                    token: context.read<AuthProvider>().token!,
                    unitBusinessId: selectedCompanyId!,
                    warehouseId: val!,
                  );
                },
        );
      },
    );
  }

  // ===============================
  // OPNAME
  // ===============================
  Widget _buildOpnameDropdown() {
    return Consumer<StockAdjustmentProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildDropdown(
          value: selectedOpnameId,
          hint: "Pilih Referensi Opname",
          items: provider.opnames
              .map<DropdownMenuItem<String>>(
                (o) => DropdownMenuItem(value: o['id'], child: Text(o['code'])),
              )
              .toList(),
          onChanged: selectedWarehouseId == null
              ? null
              : (val) {
                  setState(() => selectedOpnameId = val);

                  final selected = provider.opnames.firstWhere(
                    (e) => e['id'] == val,
                  );

                  provider.setSelectedOpname(selected);
                },
        );
      },
    );
  }

  // ===============================
  // DATE FIELD
  // ===============================
  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _dateController,
            decoration: const InputDecoration(
              hintText: "Pilih tanggal",
              border: InputBorder.none,
              suffixIcon: Icon(Icons.calendar_today),
            ),
          ),
        ),
      ),
    );
  }

  // ===============================
  // ITEM LIST
  // ===============================
  Widget _buildItemSection() {
    if (selectedItems.isEmpty) {
      return OutlinedButton(
        onPressed: _navigateToSelectItem,
        child: const Text("+ Add Item"),
      );
    }

    return Column(
      children: selectedItems.map((item) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(item['name'] ?? '-'),
            subtitle: Text(item['code'] ?? '-'),
            trailing: Text("Qty: ${item['qty']}"),
          ),
        );
      }).toList(),
    );
  }

  // ===============================
  // SUBMIT
  // ===============================
  Future<void> _submitAdjustment({required bool sendApproval}) async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<StockAdjustmentProvider>();

    debugPrint("SELECTED ITEMS RAW => $selectedItems");
    debugPrint(
      "CHECK UOM => ${selectedItems.map((e) => e['item_uom_id']).toList()}",
    );

    if (provider.generatedCode == null) {
      return _showError("Kode adjustment belum tergenerate");
    }
    if (selectedCompanyId == null) return _showError("Company belum dipilih");
    if (selectedWarehouseId == null) return _showError("Gudang belum dipilih");
    if (selectedDate == null) return _showError("Tanggal belum dipilih");
    if (selectedItems.isEmpty) return _showError("Item belum ditambahkan");

    if (selectedItems.any((e) => e['item_uom_id'] == null)) {
      return _showError(
        "Ada item tanpa UOM. Lengkapi UOM di master item terlebih dahulu",
      );
    }

    if (sendApproval) {
      final canSubmit = await provider.checkCanSubmit(
        token: auth.token!,
        authUserId: auth.user!.id,
        menuId: '4ad48011-9a08-4073-bde0-10f88bfebc81',
        unitBusinessId: selectedCompanyId,
      );

      if (!canSubmit) {
        _showError(provider.error ?? 'Tidak bisa submit approval');
        return;
      }
    }

    final payload = {
      "code": provider.generatedCode,
      "unit_bussiness_id": selectedCompanyId,
      "warehouse_id": selectedWarehouseId,
      "date": DateFormat('yyyy-MM-dd').format(selectedDate!),
      "notes": _catatanController.text,
      "submitted_by": auth.user!.id,
      "status": sendApproval ? "SUBMITTED" : "DRAFT",

      "inventory_adjustment_account_id":
          provider.selectedOpname?['inventory_adjustment_account_id'],
      "total_diff": provider.selectedOpname?['total_diff'] ?? 0,
      "io_multiplier": 1,
      "t_inventory_s_adjustment_d": selectedItems.map((e) {
        final qtyBefore = e['qty_before'] ?? 0;
        final qtyAfter = e['qty_after'] ?? e['qty'] ?? 0;
        final adjustment = qtyAfter - qtyBefore;

        return {
          "item_id": e['item_id'],
          "item_code": e['code'],
          "item_uom_id": e['item_uom_id'],
          "item_group_coa_id": e['item_group_coa_id'],
          "reason": "From Stock Opname",
          "notes": "",
          "qty_before": qtyBefore,
          "qty_after": qtyAfter,
          "adjustment": adjustment,
          "cost": e['cost'] ?? 0,
        };
      }).toList(),
    };

    debugPrint("FINAL PAYLOAD => ${jsonEncode(payload)}");

    try {
      await provider.createAdjustment(token: auth.token!, payload: payload);
      Navigator.pop(context, true);
    } catch (e) {
      _showError(e.toString());
    }
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _submitAdjustment(sendApproval: false),
              child: const Text("Save Draft"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _submitAdjustment(sendApproval: true),
              child: const Text("Send Approval"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(color: Colors.grey)),
  );

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: value,
          hint: Text(hint),
          items: items,
          onChanged: onChanged,
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildTextInput(TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }
}
