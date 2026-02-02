import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/list_item/presentation/pages/tambah_item_page.dart';
import 'package:bbs_gudang/features/stock_adjustment/presentation/providers/stock_adjustment_provider.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/providers/transfer_warehouse_provider.dart';
import 'package:flutter/material.dart';
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

  final TextEditingController _catatanController = TextEditingController();
  List<Map<String, dynamic>> selectedItems = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final provider = context.read<TransferWarehouseProvider>();

      String? responsibilityId;
      if (auth.user!.userDetails.isNotEmpty) {
        final primary = auth.user!.userDetails.firstWhere(
          (e) => e.isPrimary == true,
          orElse: () => auth.user!.userDetails.first,
        );
        responsibilityId = primary.fResponsibility;
      }

      provider.loadUserCompanies(
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

  void _navigateToSelectItem() async {
    final token = context.read<AuthProvider>().token!;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TambahItem(token: token)),
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
          _buildBottomButton(),
        ],
      ),
    );
  }

  // ===============================
  // COMPANY
  // ===============================
  Widget _buildCompanySelector() {
    return Consumer<TransferWarehouseProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingCompany) {
          return const Center(child: CircularProgressIndicator());
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

            context.read<StockAdjustmentProvider>().clear();

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
          return const Center(child: CircularProgressIndicator());
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
  // ITEM
  // ===============================
  Widget _buildItemSection() {
    if (selectedItems.isEmpty) {
      return Center(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.green),
            minimumSize: const Size(double.infinity, 48),
          ),
          onPressed: _navigateToSelectItem,
          child: const Text(
            "+ Add Item",
            style: TextStyle(color: Colors.green),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Item Terpilih",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton(
              onPressed: _navigateToSelectItem,
              child: const Text("+ Add Item"),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...selectedItems.map(
          (item) => Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                item['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(item['code']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (item['qty'] > 1) {
                        setState(() => item['qty']--);
                      }
                    },
                  ),
                  Text(item['qty'].toString()),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => item['qty']++),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===============================
  // SAVE
  // ===============================
  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Row(
        children: [
          /// SAVE STOCK ADJUSTMENT (DRAFT)
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
                  await _submitAdjustment(sendApproval: false);
                },
                child: const Text(
                  "Save Stock Adjustment",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// SEND APPROVAL
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
                  await _submitAdjustment(sendApproval: true);
                },
                child: const Text(
                  "Send Approval",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAdjustment({required bool sendApproval}) async {
    if (selectedCompanyId == null) {
      _showError("Company belum dipilih");
      return;
    }
    if (selectedWarehouseId == null) {
      _showError("Gudang belum dipilih");
      return;
    }
    if (selectedOpnameId == null) {
      _showError("Referensi opname belum dipilih");
      return;
    }
    if (selectedItems.isEmpty) {
      _showError("Item belum ditambahkan");
      return;
    }

    final auth = context.read<AuthProvider>();
    final provider = context.read<StockAdjustmentProvider>();

    /// hanya cek approval kalau user klik SEND APPROVAL
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
      "approval_id": sendApproval ? provider.approvalId : null,
      "status": sendApproval ? "SUBMITTED" : "DRAFT",
    };

    await provider.createAdjustment(token: auth.token!, payload: payload);

    provider.reset();
    selectedItems.clear();

    Navigator.pop(context, true);
  }

  // ===============================
  // UI HELPER
  // ===============================
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
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
