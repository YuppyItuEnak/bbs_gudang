import 'package:bbs_gudang/features/transfer_warehouse/presentation/pages/detail_transfer_warehouse_page.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/pages/tambah_transfer_page.dart';
import 'package:flutter/material.dart';

class TransferWarehousePage extends StatefulWidget {
  const TransferWarehousePage({super.key});

  @override
  State<TransferWarehousePage> createState() => _TransferWarehousePageState();
}

class _TransferWarehousePageState extends State<TransferWarehousePage> {
  // Contoh data dummy untuk list
  final List<Map<String, dynamic>> transferData = [
    {
      "date": "02 Agustus 2025",
      "items": [
        {"from": "Gudang Utama", "to": "Gudang Retur"},
        {"from": "Gudang Utama", "to": "Gudang Konsinyasi"},
      ],
    },
    {
      "date": "01 Agustus 2025",
      "items": [
        {"from": "Gudang Utama", "to": "Gudang Retur"},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Transfer Warehouse",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- SEARCH BAR SECTION ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Cari",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune, color: Colors.black87),
                ),
              ],
            ),
          ),

          // --- LIST SECTION ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: transferData.length,
              itemBuilder: (context, index) {
                final group = transferData[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      group['date'],
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(
                      group['items'].length,
                      (i) => _buildTransferCard(
                        group['items'][i]['from'],
                        group['items'][i]['to'],
                        () {
                          // Aksi ketika kartu ditekan
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DetailTransferWarehousePage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi tambah transfer
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahTransferPage()),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  // Widget Helper untuk Card Transfer
  // Update parameter untuk menerima fungsi navigasi
  Widget _buildTransferCard(String from, String to, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, // Aksi ketika kartu ditekan
      borderRadius: BorderRadius.circular(
        15,
      ), // Agar efek riak air (splash) mengikuti bentuk kartu
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Gudang Awal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.red, size: 10),
                      const SizedBox(width: 5),
                      Text(
                        "Gudang Awal",
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    from,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Divider Dots (Visual Alur)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  ...List.generate(3, (index) => _buildDot()),
                  Icon(Icons.circle, size: 8, color: Colors.blue[600]),
                  ...List.generate(3, (index) => _buildDot()),
                ],
              ),
            ),

            // Gudang Tujuan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Gudang Tujuan",
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.circle, color: Colors.green, size: 10),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    to,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper kecil untuk titik-titik alur
  Widget _buildDot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: Colors.blue[200],
        shape: BoxShape.circle,
      ),
    );
  }
}
