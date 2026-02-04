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
          "qty": e.qtyAfter,
          "qtyBefore": e.qtyBefore ?? 0,
          "adjustment": e.adjustment ?? 0,
          "reason": e.reason ?? "",
        };
      }).toList();

      print("SELECTED ITEMS: $selectedItems");

      setState(() {});
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(msg)));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text(msg)));
  }

  // ==========================
  // ADD ITEM
  // ==========================
  void _navigateToSelectItem() async {
    final token = context.read<AuthProvider>().token!;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TambahItem(token: token)),
    );

    if (result != null && result is List) {
      setState(() {
        for (final newItem in result) {
          debugPrint("DEBUG: Data item dari pencarian => $newItem");
          final index = selectedItems.indexWhere(
            (e) => e['id'] == newItem['id'],
          );

          if (index != -1) {
            selectedItems[index]['qty'] =
                (selectedItems[index]['qty'] ?? 0) + (newItem['qty'] ?? 0);
            selectedItems[index]['adjustment'] =
                selectedItems[index]['qty'] -
                (selectedItems[index]['qtyBefore'] ?? 0);
          } else {
            selectedItems.add({
              "id": newItem['id'],
              "name": newItem['name'],
              "code": newItem['code'],
              "item_uom_id": newItem['item_uom_id'], // HARUS DARI API ITEM
              "item_group_coa_id": newItem['item_group_coa_id'],
              "qty": newItem['qty'] ?? 1,
              "qtyBefore": newItem['qtyBefore'] ?? 0,
              "adjustment": 0,
              "reason": "",
            });
          }
        }
      });
    }
  }

  // ==========================
  // SUBMIT
  // ==========================
  Future<void> _submitAdjustment({required bool sendApproval}) async {
    if (selectedItems.isEmpty) {
      _showError("Item belum ditambahkan");
      return;
    }

    for (var item in selectedItems) {
      print(
        "CHECK ITEM ${item['name']}: UOM=${item['item_uom_id']}, COA=${item['item_group_coa_id']}",
      );
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
        _showError(provider.error ?? 'Tidak bisa submit approval');
        return;
      }
    }

    final payload = {
      "unit_bussiness_id": selectedCompanyId,
      "warehouse_id": selectedWarehouseId,
      "opname_id": selectedOpnameId,
      "notes": _catatanController.text,
      "submitted_by": auth.user!.id,
      "status": sendApproval ? "SUBMITTED" : "DRAFT",

      "date": DateTime.now().toIso8601String().split('T').first,

      "inventory_adjustment_account_id":
          provider.selectedOpname?['inventory_adjustment_account_id'],

      "total_diff": 0,
      "io_multiplier": 1,

      "t_inventory_s_adjustment_d": selectedItems.map((e) {
        final qtyBefore = e['qtyBefore'] ?? 0;
        final qtyAfter = e['qty'];

        return {
          "item_id": e['id'],
          "item_code": e['code'],
          "item_uom_id": e['item_uom_id'],
          "item_group_coa_id": e['item_group_coa_id'],
          "qty_before": qtyBefore,
          "qty_after": qtyAfter,
          "adjustment": qtyAfter - qtyBefore,
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

  // ==========================
  // UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FB),
      appBar: AppBar(
        title: const Text(
          "Edit Stock Adjustment",
          style: TextStyle(fontWeight: FontWeight.bold),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (adjustmentCode != null) ...[
                        _sectionTitle("No Adjustment"),
                        _readonlyBox(adjustmentCode!),
                        const SizedBox(height: 16),
                      ],

                      _sectionTitle("Company"),
                      _buildCompanySelector(),
                      const SizedBox(height: 16),

                      _sectionTitle("Gudang"),
                      _buildGudangSelector(),
                      const SizedBox(height: 16),

                      _sectionTitle("Referensi Opname"),
                      _buildOpnameDropdown(),
                      const SizedBox(height: 16),

                      _sectionTitle("Catatan"),
                      _buildTextInput(_catatanController, "Catatan"),
                      const SizedBox(height: 24),

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

  Widget _readonlyBox(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }

  // ==========================
  // ITEM UI
  // ==========================
  Widget _buildItemSection() {
    if (selectedItems.isEmpty) {
      return Center(
        child: OutlinedButton(
          onPressed: _navigateToSelectItem,
          child: const Text("+ Add Item"),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Item Terpilih",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _navigateToSelectItem,
              child: const Text("+ Add Item"),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...selectedItems.map((item) {
          return Card(
            child: ListTile(
              title: Text(item['name']),
              subtitle: Text(item['code']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (item['qty'] > 1) {
                        setState(() {
                          item['qty']--;
                          item['adjustment'] =
                              item['qty'] - (item['qtyBefore'] ?? 0);
                        });
                      }
                    },
                  ),
                  Text(item['qty'].toString()),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        item['qty']++;
                        item['adjustment'] =
                            item['qty'] - (item['qtyBefore'] ?? 0);
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => selectedItems.remove(item));
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================
  // BUTTONS
  // ==========================
  Widget _buildBottomButton(StockAdjustmentProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: provider.isUpdating
                    ? null
                    : () => _submitAdjustment(sendApproval: false),
                child: provider.isUpdating
                    ? const CircularProgressIndicator()
                    : const Text("Update Draft"),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: provider.isUpdating
                    ? null
                    : () => _submitAdjustment(sendApproval: true),
                child: provider.isUpdating
                    ? const CircularProgressIndicator()
                    : const Text("Send Approval"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // DROPDOWNS
  // ==========================
  Widget _buildCompanySelector() {
    return Consumer<TransferWarehouseProvider>(
      builder: (_, provider, __) {
        return _buildDropdown(
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

            final auth = context.read<AuthProvider>();
            await provider.loadWarehouseCompany(
              token: auth.token!,
              unitBusinessId: val,
            );
          },
        );
      },
    );
  }

  Widget _buildGudangSelector() {
    return Consumer<TransferWarehouseProvider>(
      builder: (_, provider, __) {
        return _buildDropdown(
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

            final auth = context.read<AuthProvider>();
            final saProvider = context.read<StockAdjustmentProvider>();

            await saProvider.loadOpnameReference(
              token: auth.token!,
              unitBusinessId: selectedCompanyId!,
              warehouseId: val,
            );
          },
        );
      },
    );
  }

  Widget _buildOpnameDropdown() {
    return Consumer<StockAdjustmentProvider>(
      builder: (_, provider, __) {
        return _buildDropdown(
          value: selectedOpnameId,
          hint: "Pilih Referensi Opname",
          items: provider.opnames
              .map<DropdownMenuItem<String>>(
                (o) => DropdownMenuItem(value: o['id'], child: Text(o['code'])),
              )
              .toList(),
          onChanged: (val) => setState(() => selectedOpnameId = val),
        );
      },
    );
  }

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
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint),
          items: items,
          onChanged: onChanged,
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
