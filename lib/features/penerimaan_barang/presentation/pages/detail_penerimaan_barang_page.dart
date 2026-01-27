import 'package:bbs_gudang/data/models/penerimaan_barang/penerimaan_barang_model.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/providers/penerimaan_barang_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';

class DetailPenerimaanBarangPage extends StatefulWidget {
  final String id;
  const DetailPenerimaanBarangPage({super.key, required this.id});

  @override
  State<DetailPenerimaanBarangPage> createState() =>
      _DetailPenerimaanBarangPageState();
}

class _DetailPenerimaanBarangPageState
    extends State<DetailPenerimaanBarangPage> {
  @override
  void initState() {
    super.initState();

    final token = context.read<AuthProvider>().token;

    Future.microtask(() {
      context.read<PenerimaanBarangProvider>().fetchDetail(
        token: token!,
        id: widget.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
          "Penerimaan Barang Detail",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PenerimaanBarangProvider>(
        builder: (context, provider, _) {
          // LOADING
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ERROR
          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          // DATA KOSONG
          if (provider.data == null) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final header = provider.data!;
          final details = header.details ?? [];

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== HEADER INFO =====
                      _buildHeaderSection(header),

                      const SizedBox(height: 30),
                      const Divider(thickness: 1, color: Color(0xFFF5F5F5)),
                      const SizedBox(height: 10),

                      const Text(
                        "Detail Penerimaan Barang",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // ===== LIST DETAIL BARANG =====
                      if (details.isEmpty)
                        const Center(child: Text("Tidak ada detail barang"))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: details.length,
                          itemBuilder: (context, index) {
                            final d = details[index];

                            return _buildDetailItemCard(
                              po: d.poDetail!.itemCode ?? '-',
                              pp: d.prDetail!.itemCode ?? '-',
                              namaBarang: d.itemName ?? '-',
                              qtyUnit: d.itemUom ?? '-',
                              qtyPo: d.qtyReceipt?.toString() ?? '0',
                              qtyDiterima: d.qtyReceived.toString(),
                              sisaQty: d.prDetail!.qty.toString() ?? '0',
                              harga: d.itemPrice ?? '0',
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              // ===== TOMBOL KEMBALI =====
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4CAF50)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Kembali",
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================
  // HEADER SECTION
  // ============================

  Widget _buildHeaderSection(PenerimaanBarangModel item) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoText("No. PB", item.code ?? '-')),
            Expanded(
              child: _buildInfoText(
                "Tanggal",
                item.date != null
                    ? DateFormat('dd MMM yyyy').format(item.date!)
                    : '-',
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildInfoText("Supplier", item.supplierName ?? '-'),
            ),
            Expanded(child: _buildInfoText("Status", item.status ?? '-')),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildInfoText(
                "Tgl SJ Supplier",
                item.dateSjSupplier != null
                    ? DateFormat('dd MMM yyyy').format(item.dateSjSupplier!)
                    : '-',
              ),
            ),
            Expanded(
              child: _buildInfoText("No SJ Supplier", item.noSjSupplier ?? '-'),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildInfoText("Nomor Polisi", item.policeNumber ?? '-'),
            ),
            Expanded(
              child: _buildInfoText("Nama Supir", item.driverName ?? '-'),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildInfoText("Gudang", item.warehouseId ?? '-')),
            Expanded(child: _buildInfoText("Catatan", item.notes ?? '-')),
          ],
        ),
      ],
    );
  }

  // ============================
  // HELPER INFO TEXT
  // ============================

  Widget _buildInfoText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF424242),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ============================
  // CARD DETAIL BARANG
  // ============================

  Widget _buildDetailItemCard({
    required String po,
    required String pp,
    required String namaBarang,
    required String qtyUnit,
    required String qtyPo,
    required String qtyDiterima,
    required String sisaQty,
    required String harga,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PO & PR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                po,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                pp,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Nama & UOM
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  namaBarang,
                  maxLines: 2, // maksimal 2 baris
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                qtyUnit,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Qty
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Qty PO : $qtyPo",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                "Qty Terima : $qtyDiterima",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Text(
            "Sisa Qty : $sisaQty",
            style: const TextStyle(
              color: Color(0xFF4CAF50),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            "Harga : $harga",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
