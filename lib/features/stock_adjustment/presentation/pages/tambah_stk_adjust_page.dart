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
  // Warna sesuai gambar profil yang diunggah
  final Color primaryGreen = const Color(0xff4CAF50);
  final Color backgroundGrey = const Color(0xffF5F5F5);

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

      await stockProvider.generateCode(token: auth.token!);

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: ColorScheme.light(primary: primaryGreen)),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _navigateToSelectItem() async {
    final token = context.read<AuthProvider>().token!;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TambahItem(token: token)),
    );

    if (result != null && result is List) {
      setState(() {
        for (final item in result) {
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
              "item_uom_id": item['item_uom_id'],
              "item_group_coa_id": item['item_group_coa_id'],
              "qty_before": item['qty_before'] ?? 0,
              "qty_after": item['qty'] ?? 1,
              "qty": item['qty'] ?? 1,
              "cost": item['cost'] ?? 0,
            });
          }
        }
      });
    }
  }

  // FITUR UPDATE QTY
  void _updateItemQty(int index, double delta) {
    setState(() {
      double currentQty = (selectedItems[index]['qty'] as num).toDouble();
      double newQty = currentQty + delta;
      if (newQty >= 0) {
        selectedItems[index]['qty'] = newQty;
        selectedItems[index]['qty_after'] = newQty;
      }
    });
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
          "Stock Adjustment",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                  _sectionCard("Informasi Utama", [
                    _fieldLabel("No. Adjustment"),
                    _buildAdjustmentCode(),
                    const SizedBox(height: 16),
                    _fieldLabel("Company"),
                    _buildCompanySelector(),
                    const SizedBox(height: 16),
                    _fieldLabel("Gudang"),
                    _buildGudangSelector(),
                  ]),
                  const SizedBox(height: 20),
                  _sectionCard("Referensi & Waktu", [
                    _fieldLabel("Referensi Opname"),
                    _buildOpnameDropdown(),
                    const SizedBox(height: 16),
                    _fieldLabel("Tanggal Adjustment"),
                    _buildDateField(),
                  ]),
                  const SizedBox(height: 20),
                  _sectionCard("Tambahan", [
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
          _buildBottomButton(),
        ],
      ),
    );
  }

  // REUSABLE WIDGETS UNTUK UI BARU
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

  Widget _buildAdjustmentCode() {
    return Consumer<StockAdjustmentProvider>(
      builder: (_, provider, __) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: provider.isGeneratingCode
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  provider.generatedCode ?? "-",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCompanySelector() {
    return Consumer<TransferWarehouseProvider>(
      builder: (_, provider, __) => _buildDropdown(
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
        onChanged: selectedCompanyId == null
            ? null
            : (val) {
                setState(() {
                  selectedWarehouseId = val;
                  selectedOpnameId = null;
                });
                context.read<StockAdjustmentProvider>().clear();
                context.read<StockAdjustmentProvider>().loadOpnameReference(
                  token: context.read<AuthProvider>().token!,
                  unitBusinessId: selectedCompanyId!,
                  warehouseId: val!,
                );
              },
      ),
    );
  }

  Widget _buildOpnameDropdown() {
    return Consumer<StockAdjustmentProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) return const LinearProgressIndicator();
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
              : (val) async {
                  setState(() => selectedOpnameId = val);
                  final selectedHeader = provider.opnames.firstWhere(
                    (e) => e['id'] == val,
                  );
                  provider.setSelectedOpname(selectedHeader);
                  await provider.selectOpname(
                    token: context.read<AuthProvider>().token!,
                    opnameId: val!,
                  );
                  setState(() {
                    selectedItems = provider.selectedItems
                        .map(
                          (item) => {
                            "item_id": item['item_id'],
                            "code": item['item_code'],
                            "name": item['item_name'],
                            "item_uom_id": item['uom_id'],
                            "qty_before": item['qty_on_hand'] ?? 0,
                            "qty_after": item['qty_physical'] ?? 0,
                            "qty": item['qty_physical'] ?? 0,
                            "cost": 0,
                            "item_group_coa_id": item['item_group_coa_id'],
                          },
                        )
                        .toList();
                  });
                },
        );
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dateController.text.isEmpty
                  ? "Pilih tanggal"
                  : _dateController.text,
            ),
            Icon(Icons.calendar_month, color: primaryGreen),
          ],
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
              label: const Text("Manual"),
              style: TextButton.styleFrom(foregroundColor: primaryGreen),
            ),
          ],
        ),
        if (selectedItems.isEmpty)
          Container(
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
                Text(
                  "Belum ada item terpilih",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
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
                        ],
                      ),
                    ),
                    // CONTROLLER PLUS MINUS QTY
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => _updateItemQty(index, -1),
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
                            onPressed: () => _updateItemQty(index, 1),
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

  // BUTTON SUBMIT DENGAN LOADING STATE
  Widget _buildBottomButton() {
    return Consumer<StockAdjustmentProvider>(
      builder: (context, provider, _) {
        bool isLoading = provider.isLoading;
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
                    "Save Draft",
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
      },
    );
  }

  // Logic Submit tetap sama
  Future<void> _submitAdjustment({required bool sendApproval}) async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<StockAdjustmentProvider>();

    if (provider.generatedCode == null)
      return _showError("Kode adjustment belum tergenerate");
    if (selectedCompanyId == null) return _showError("Company belum dipilih");
    if (selectedWarehouseId == null) return _showError("Gudang belum dipilih");
    if (selectedDate == null) return _showError("Tanggal belum dipilih");
    if (selectedItems.isEmpty) return _showError("Item belum ditambahkan");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    final payload = {
      "code": provider.generatedCode,
      "unit_bussiness_id": selectedCompanyId,
      "warehouse_id": selectedWarehouseId,
      "date": DateFormat('yyyy-MM-dd').format(selectedDate!),
      "notes": _catatanController.text,
      "submitted_by": auth.user!.id,
      "status": sendApproval ? "POSTED" : "DRAFT",
      "inventory_adjustment_account_id":
          provider.selectedOpname?['inventory_adjustment_account_id'],
      "total_diff": provider.selectedOpname?['total_diff'] ?? 0,
      "io_multiplier": 1,
      "t_inventory_s_adjustment_d": selectedItems.map((e) {
        final qtyBefore = e['qty_before'] ?? 0;
        final qtyAfter = e['qty_after'] ?? e['qty'] ?? 0;
        return {
          "item_id": e['item_id'],
          "item_code": e['code'],
          "item_uom_id": e['item_uom_id'],
          "item_group_coa_id": e['item_group_coa_id'],
          "reason": "From Stock Opname",
          "notes": "",
          "qty_before": qtyBefore,
          "qty_after": qtyAfter,
          "adjustment": qtyAfter - qtyBefore,
          "cost": e['cost'] ?? 0,
        };
      }).toList(),
    };

    try {
      await provider.createAdjustment(token: auth.token!, payload: payload);
      await provider.fetchStockAdjustments(token: auth.token!, loadMore: false);
      if (mounted) {
        // Tutup Loading Dialog
        Navigator.pop(context);
        // Kembali ke halaman list dengan membawa nilai 'true'
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError("Gagal create adjustment");
    }
  }

  // DROPDOWN STYLE
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 13)),
          items: items,
          onChanged: onChanged,
          isExpanded: true,
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
