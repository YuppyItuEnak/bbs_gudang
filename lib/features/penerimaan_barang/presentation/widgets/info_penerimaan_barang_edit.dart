import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/providers/transfer_warehouse_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/penerimaan_barang_provider.dart';

class InfoPenerimaanBarangEdit extends StatefulWidget {
  const InfoPenerimaanBarangEdit({super.key});

  @override
  State<InfoPenerimaanBarangEdit> createState() =>
      _InfoPenerimaanBarangEditState();
}

class _InfoPenerimaanBarangEditState extends State<InfoPenerimaanBarangEdit> {
  // Controller untuk menjaga teks tetap tampil dan bisa diedit
  late TextEditingController _sjController;
  late TextEditingController _invoiceController;
  late TextEditingController _policeController;
  late TextEditingController _driverController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final p = context.read<PenerimaanBarangProvider>();

    // Inisialisasi controller dengan data yang sudah ada di Provider (dari fetchDetail)
    _sjController = TextEditingController(text: p.supplierSjNo);
    _invoiceController = TextEditingController(text: p.supplierInvoiceNo);
    _policeController = TextEditingController(text: p.policeNo);
    _driverController = TextEditingController(text: p.driverName);
    _noteController = TextEditingController(text: p.headerNote);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final tw = context.read<TransferWarehouseProvider>();

      // 1. Load Master Data (PO & Companies)
      await p.fetchListPO(token: auth.token!);

      String? responsibilityId;
      if (auth.user!.userDetails.isNotEmpty) {
        final primary = auth.user!.userDetails.firstWhere(
          (d) => d.isPrimary == true,
          orElse: () => auth.user!.userDetails.first,
        );
        responsibilityId = primary.fResponsibility;
      }

      await tw.loadUserCompanies(
        token: auth.token!,
        userId: auth.user!.id,
        responsibilityId: responsibilityId!,
      );

      // 2. Sinkronisasi Data PO agar Label No. PO muncul
      if (p.purchaseOrderId != null) {
        p.syncSelectedPo(p.purchaseOrderId);
        if (p.unitBusinessId != null) {
          await tw.loadWarehouseCompany(
            token: auth.token!,
            unitBusinessId: p.unitBusinessId!,
          );
        }

        await p.loadPoDetail(token: auth.token!, poId: p.purchaseOrderId!, isEdit: true);
      }

      // 3. Load Master Warehouse berdasarkan Company yang sudah terpilih
    });
  }

  @override
  void dispose() {
    _sjController.dispose();
    _invoiceController.dispose();
    _policeController.dispose();
    _driverController.dispose();
    _noteController.dispose();
    super.dispose();
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
          _readOnlyField(
            context.select<PenerimaanBarangProvider, String>(
              (p) => p.selectedPO?.code ?? p.data?.purchaseOrder?.code ?? "-",
            ),
          ),

          _label("Company"),
          _readOnlyField(
            context.select<PenerimaanBarangProvider, String>(
              (p) => p.unitBusinessName ?? "-",
            ),
          ),

          _label("No. PB"),
          _readOnlyField(
            context.select<PenerimaanBarangProvider, String>(
              (p) => p.pbCode ?? "-",
            ),
          ),

          _label("Warehouse"),
          _buildWarehouseDropdown(),

          _label("Supplier"),
          _readOnlyField(
            context.select<PenerimaanBarangProvider, String>(
              (p) => p.supplierName ?? "-",
            ),
          ),

          _label("No. PR"),
          _readOnlyField(
            context.select<PenerimaanBarangProvider, String>(
              (p) => p.prCode ?? "-",
            ),
          ),

          _label("Grup Item"),
          _readOnlyField(
            context.select<PenerimaanBarangProvider, String>(
              (p) => p.itemGroup ?? "-",
            ),
          ),

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

  // ================= KOMPONEN UI =================

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
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "Edit Mode",
            style: TextStyle(color: Colors.orange),
          ),
        ),
      ],
    );
  }

  Widget _readOnlyField(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildWarehouseDropdown() {
    return Consumer2<TransferWarehouseProvider, PenerimaanBarangProvider>(
      builder: (_, tw, pb, __) {
        if (tw.isLoadingWarehouse) return const LinearProgressIndicator();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: tw.warehouses.any((w) => w.id == pb.warehouseId)
                  ? pb.warehouseId
                  : null,
              hint: const Text("Pilih Warehouse"),
              isExpanded: true,
              items: tw.warehouses
                  .map(
                    (w) => DropdownMenuItem(value: w.id, child: Text(w.name)),
                  )
                  .toList(),
              onChanged: (val) {
                pb.setWarehouseId(val);
                pb.setWarehouseName(
                  tw.warehouses.firstWhere((e) => e.id == val).name,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _invoiceDatePicker() {
    return Consumer<PenerimaanBarangProvider>(
      builder: (_, p, __) => GestureDetector(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: p.invoiceDate ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (date != null) p.setInvoiceDate(date);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                p.invoiceDate == null
                    ? "Pilih tanggal"
                    : DateFormat('dd/MM/yyyy').format(p.invoiceDate!),
              ),
              const Icon(Icons.calendar_month, color: Colors.grey),
            ],
          ),
        ),
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

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(text, style: const TextStyle(color: Colors.grey)),
  );
}
