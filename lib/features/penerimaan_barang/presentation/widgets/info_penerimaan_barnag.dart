import 'package:bbs_gudang/data/models/penerimaan_barang/available_po_model.dart';
import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/providers/transfer_warehouse_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/penerimaan_barang_provider.dart';

class InfoPenerimaanBarang extends StatefulWidget {
  final bool readOnlyPo;
  final bool readOnlySupplier;
  final bool readOnlyPr;
  final bool readOnlyItemGroup;

  const InfoPenerimaanBarang({
    super.key,
    this.readOnlyPo = false,
    this.readOnlySupplier = false,
    this.readOnlyPr = false,
    this.readOnlyItemGroup = false,
  });

  @override
  State<InfoPenerimaanBarang> createState() => InfoPenerimaanBarangState();
}

class InfoPenerimaanBarangState extends State<InfoPenerimaanBarang> {
  late TextEditingController _sjController;
  late TextEditingController _invoiceController;
  late TextEditingController _policeController;
  late TextEditingController _driverController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();

    final p = context.read<PenerimaanBarangProvider>();
    _sjController = TextEditingController(text: p.supplierSjNo);
    _invoiceController = TextEditingController(text: p.supplierInvoiceNo);
    _policeController = TextEditingController(text: p.policeNo);
    _driverController = TextEditingController(text: p.driverName);
    _noteController = TextEditingController(text: p.headerNote);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final tw = context.read<TransferWarehouseProvider>();

      context.read<PenerimaanBarangProvider>().fetchListPO(token: auth.token!);

      String? responsibilityId;
      if (auth.user!.userDetails.isNotEmpty) {
        final primary = auth.user!.userDetails.firstWhere(
          (d) => d.isPrimary == true,
          orElse: () => auth.user!.userDetails.first,
        );
        responsibilityId = primary.fResponsibility;
      }

      tw.loadUserCompanies(
        token: auth.token!,
        userId: auth.user!.id,
        responsibilityId: responsibilityId!,
      );
    });
  }

  @override
  void dispose() {
    // Jangan lupa dispose agar tidak memory leak
    _sjController.dispose();
    _invoiceController.dispose();
    _policeController.dispose();
    _driverController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool validateForm() {
    final p = context.read<PenerimaanBarangProvider>();

    if (p.selectedPO == null) {
      _showSnackBar("Nomor PO wajib dipilih");
      return false;
    }

    if (p.unitBusinessId == null) {
      _showSnackBar("Company wajib dipilih");
      return false;
    }

    if (p.warehouseId == null) {
      _showSnackBar("Warehouse wajib dipilih");
      return false;
    }

    if (_sjController.text.isEmpty) {
      _showSnackBar("Nomor SJ Supplier tidak boleh kosong");
      return false;
    }

    if (_invoiceController.text.isEmpty) {
      _showSnackBar("Nomor Invoice Supplier tidak boleh kosong");
      return false;
    }

    if (_policeController.text.isEmpty) {
      _showSnackBar("Nomor Police tidak boleh kosong");
      return false;
    }

    if (_driverController.text.isEmpty) {
      _showSnackBar("Driver tidak boleh kosong");
      return false;
    }


    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),

          _label("No. PO"),
          _poDropdown(),

          _label("Company"),
          _buildCompanyDropdown(),

          _label("No. PB"),
          _pbCode(),

          _label("Warehouse"),
          _buildWarehouseDropdown(),

          _label("Supplier"),
          _supplierField(),

          _label("No. PR"),
          _prField(),

          _label("Grup Item"),
          _itemGroupField(),

          _label("Tgl Invoice Supplier"),
          _invoiceDatePicker(),

          _label("No. SJ Supplier"),
          _textInput(
            _sjController,
            (v) => context.read<PenerimaanBarangProvider>().setSupplierSjNo(v),
            "Nomor SJ Supplier",
          ),

          _label("No. Invoice Supplier"),
          _textInput(
            _invoiceController,
            (v) => context
                .read<PenerimaanBarangProvider>()
                .setSupplierInvoiceNo(v),
            "Nomor Invoice Supplier",
          ),

          _label("Nomor Polisi"),
          _textInput(
            _policeController,
            (v) => context.read<PenerimaanBarangProvider>().setPoliceNo(v),
            "Nomor Polisi",
          ),

          _label("Nama Supir"),
          _textInput(
            _driverController,
            (v) => context.read<PenerimaanBarangProvider>().setDriverName(v),
            "Nama",
          ),

          _label("Catatan Header"),
          _textInput(
            _noteController,
            (v) => context.read<PenerimaanBarangProvider>().setHeaderNote(v),
            "Catatan",
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text("Draft", style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  // ================= PO =================

  Widget _poDropdown() {
    return Consumer<PenerimaanBarangProvider>(
      builder: (_, p, __) {
        if (p.isLoadingPO) return _loadingBox();
        if (p.listPO.isEmpty) return _emptyBox("Data PO kosong");

        if (widget.readOnlyPo) {
          return _customField(text: p.selectedPO?.code ?? "-");
        }

        return GestureDetector(
          onTap: () async {
            final po = await showModalBottomSheet<AvailablePoModel>(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (_) => _poBottomSheet(p.listPO),
            );

            if (po != null) {
              final auth = context.read<AuthProvider>();
              p.resetPoAutoFill();
              p.setSelectedPO(po);
              p.setPurchaseOrderId(po.id);
              p.setCodePenerimaanBarang(po.code);

              p.loadPoDetail(token: auth.token!, poId: po.id);
            }
          },
          child: _customField(
            text: p.selectedPO?.code ?? "Pilih No. PO",
            isPlaceholder: p.selectedPO == null,
          ),
        );
      },
    );
  }

  Widget _poBottomSheet(List<AvailablePoModel> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final po = list[i];
        return ListTile(
          title: Text(po.code ?? "-"),
          onTap: () => Navigator.pop(context, po),
        );
      },
    );
  }

  // ================= COMPANY =================

  Widget _buildCompanyDropdown() {
    return Consumer2<TransferWarehouseProvider, PenerimaanBarangProvider>(
      builder: (_, tw, pb, __) {
        if (tw.isLoadingCompany) return _loadingBox();
        if (tw.companies.isEmpty) return _emptyBox("Company kosong");

        return _dropdownContainer(
          DropdownButton<String>(
            value: pb.unitBusinessId,
            hint: const Text("Pilih Company"),
            isExpanded: true,
            items: tw.companies
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (val) async {
              if (val == null) return;

              final auth = context.read<AuthProvider>();
              pb.setUnitBusinessId(val);
              pb.setUnitBusinessName(
                tw.companies.firstWhere((e) => e.id == val).name,
              );

              pb.resetPbCode();
              pb.setWarehouseId(null);

              tw.loadWarehouseCompany(token: auth.token!, unitBusinessId: val);

              await pb.generateNoPB(token: auth.token!, unitBusinessId: val);
            },
          ),
        );
      },
    );
  }

  // ================= WAREHOUSE =================

  Widget _buildWarehouseDropdown() {
    return Consumer2<TransferWarehouseProvider, PenerimaanBarangProvider>(
      builder: (_, tw, pb, __) {
        if (pb.unitBusinessId == null) {
          return _customField(
            text: "Pilih Company terlebih dahulu",
            isPlaceholder: true,
          );
        }

        if (tw.isLoadingWarehouse) return _loadingBox();
        if (tw.warehouses.isEmpty) return _emptyBox("Warehouse kosong");

        return _dropdownContainer(
          DropdownButton<String>(
            value: pb.warehouseId,
            hint: const Text("Pilih Warehouse"),
            isExpanded: true,
            items: tw.warehouses
                .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                .toList(),
            onChanged: (val) {
              pb.setWarehouseId(val);
              pb.setWarehouseName(
                tw.warehouses.firstWhere((e) => e.id == val).name,
              );
            },
          ),
        );
      },
    );
  }

  // ================= READ ONLY FIELDS =================

  Widget _supplierField() {
    return Consumer<PenerimaanBarangProvider>(
      builder: (_, p, __) => _customField(text: p.supplierName ?? "-"),
    );
  }

  Widget _prField() {
    return Consumer<PenerimaanBarangProvider>(
      builder: (_, p, __) => _customField(text: p.prCode ?? "-"),
    );
  }

  Widget _itemGroupField() {
    return Consumer<PenerimaanBarangProvider>(
      builder: (_, p, __) => _customField(text: p.itemGroup ?? "-"),
    );
  }

  Widget _pbCode() {
    return Consumer<PenerimaanBarangProvider>(
      builder: (_, p, __) =>
          _customField(text: p.pbCode ?? "-", isPlaceholder: p.pbCode == null),
    );
  }

  Widget _invoiceDatePicker() {
    return Consumer<PenerimaanBarangProvider>(
      builder: (_, p, __) {
        return GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (date != null) p.setInvoiceDate(date);
          },
          child: _customField(
            text: p.invoiceDate == null
                ? "Pilih tanggal"
                : DateFormat('dd/MM/yyyy').format(p.invoiceDate!),
            isPlaceholder: p.invoiceDate == null,
            icon: Icons.calendar_month,
          ),
        );
      },
    );
  }

  // ================= UI HELPERS =================

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(text, style: const TextStyle(color: Colors.grey)),
  );

  Widget _customField({
    required String text,
    bool isPlaceholder = false,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isPlaceholder ? Colors.grey : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(icon ?? Icons.arrow_drop_down, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _textInput(
    TextEditingController controller,
    Function(String) onChanged,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _dropdownContainer(Widget child) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: DropdownButtonHideUnderline(child: child),
  );

  Widget _loadingBox() => const Padding(
    padding: EdgeInsets.all(12),
    child: Center(child: CircularProgressIndicator()),
  );

  Widget _emptyBox(String text) => Padding(
    padding: const EdgeInsets.all(12),
    child: Text(text, style: const TextStyle(color: Colors.grey)),
  );
}
