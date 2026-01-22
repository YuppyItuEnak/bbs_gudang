import 'package:flutter/material.dart';

class DetailPengeluaranBrgPage extends StatefulWidget {
  const DetailPengeluaranBrgPage({super.key});

  @override
  State<DetailPengeluaranBrgPage> createState() =>
      _DetailPengeluaranBrgPageState();
}

class _DetailPengeluaranBrgPageState extends State<DetailPengeluaranBrgPage> {
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
          "Pengeluaran Barang Detail",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
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
                  // Section Header Info
                  _buildHeaderGrid(),
                  const SizedBox(height: 20),
                  const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 15),

                  // Title Detail
                  const Text(
                    "Detail Pengeluaran Barang",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 15),

                  // List Item Detail
                  _buildDetailItemCard(
                    noSo: "SO-001",
                    noSq: "SQ-001",
                    namaBarang: "Barang A",
                    qty: "2 roll",
                    qtySo: "100",
                    qtyDiterima: "80",
                    sisa: "20",
                  ),
                  _buildDetailItemCard(
                    noSo: "SO-002",
                    noSq: "SQ-002",
                    namaBarang: "Barang B",
                    qty: "2 roll",
                    qtySo: "100",
                    qtyDiterima: "20",
                    sisa: "80",
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Kembali",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      children: [
        _buildInfoTile("No. Pengeluaran Barang", "PBO-001"),
        _buildInfoTile("Tanggal", "06 Desember 2024"),
        _buildInfoTile("Tipe Barang", "Finish Good"),
        _buildInfoTile("Customer", "Customer A"),
        _buildInfoTile("Tgl Invoice", "06 Desember 2024"),
        _buildInfoTile("No. Surat Jalan", "SJ001"),
        _buildInfoTile("No. Invoice", "SIS-001"),
        _buildInfoTile("Nomor Polisi", "W 9028 Y"),
        _buildInfoTile("Nama Supir", "Yatno"),
        _buildInfoTile("Catatan", "-"),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItemCard({
    required String noSo,
    required String noSq,
    required String namaBarang,
    required String qty,
    required String qtySo,
    required String qtyDiterima,
    required String sisa,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                noSo,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                noSq,
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
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                qty,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Qty SO : $qtySo",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                "Qty Diterima : $qtyDiterima",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "Sisa Qty SO : $sisa",
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Deskripsi : Lorem Ipsum",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const Text(
            "Catatan : -",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
