import 'package:flutter/material.dart';

class DetailPenerimaanBarangPage extends StatefulWidget {
  const DetailPenerimaanBarangPage({super.key});

  @override
  State<DetailPenerimaanBarangPage> createState() =>
      _DetailPenerimaanBarangPageState();
}

class _DetailPenerimaanBarangPageState
    extends State<DetailPenerimaanBarangPage> {
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION HEADER INFO ---
                  _buildHeaderSection(),

                  const SizedBox(height: 30),
                  const Divider(thickness: 1, color: Color(0xFFF5F5F5)),
                  const SizedBox(height: 10),

                  // --- TITLE LIST ---
                  const Text(
                    "Detail Penerimaan Barang",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- LIST ITEM ---
                  _buildDetailItemCard(
                    po: "PO-001",
                    pp: "PP-001",
                    namaBarang: "Barang A",
                    qtyUnit: "2 roll",
                    qtyPo: "100",
                    qtyDiterima: "80",
                    sisaQty: "20",
                  ),
                  _buildDetailItemCard(
                    po: "PO-002",
                    pp: "PP-002",
                    namaBarang: "Barang B",
                    qtyUnit: "2 roll",
                    qtyPo: "100",
                    qtyDiterima: "20",
                    sisaQty: "80",
                  ),
                ],
              ),
            ),
          ),

          // --- TOMBOL KEMBALI ---
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
      ),
    );
  }

  // Widget untuk Header Info (Grid 2 Kolom)
  Widget _buildHeaderSection() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInfoText("No. Penerimaan Barang", "PBI-001")),
            Expanded(child: _buildInfoText("Tanggal", "06 Desember 2024")),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInfoText("Tipe Barang", "Finish Good")),
            Expanded(child: _buildInfoText("Supplier", "Supplier A")),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildInfoText("Tgl Inv. Supplier", "06 Desember 2024"),
            ),
            Expanded(child: _buildInfoText("No. SJ Supplier", "Supplier A")),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInfoText("No. Inv. Supplier", "SIS-001")),
            Expanded(child: _buildInfoText("Nomor Polisi", "W 9028 Y")),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInfoText("Nama Supir", "Yatno")),
            Expanded(child: _buildInfoText("Catatan", "-")),
          ],
        ),
      ],
    );
  }

  // Widget Helper untuk Teks Info Label & Value
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

  // Widget untuk Card Detail Barang di List
  Widget _buildDetailItemCard({
    required String po,
    required String pp,
    required String namaBarang,
    required String qtyUnit,
    required String qtyPo,
    required String qtyDiterima,
    required String sisaQty,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF), // Warna biru sangat muda sesuai gambar
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                namaBarang,
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Qty PO : $qtyPo",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                "Qty Diterima : $qtyDiterima",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Sisa Qty PO : $sisaQty",
            style: const TextStyle(
              color: Color(0xFF4CAF50),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Deskripsi : Lorem Ipsum",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const Text(
            "Catatan : -",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
