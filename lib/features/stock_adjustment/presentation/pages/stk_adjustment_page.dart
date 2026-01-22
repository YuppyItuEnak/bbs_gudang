import 'package:bbs_gudang/features/stock_adjustment/presentation/pages/detail_stck_adjustment_page.dart';
import 'package:bbs_gudang/features/stock_adjustment/presentation/pages/tambah_stk_adjust_page.dart';
import 'package:flutter/material.dart';

class StkAdjustmentPage extends StatefulWidget {
  const StkAdjustmentPage({super.key});

  @override
  State<StkAdjustmentPage> createState() => _StkAdjustmentPageState();
}

class _StkAdjustmentPageState extends State<StkAdjustmentPage> {
  // Data dummy untuk daftar Stock Adjustment sesuai gambar image_80df51.png
  final List<Map<String, String>> _adjustmentData = [
    {"id": "ADJ-2512-0001", "gudang": "Gudang Utama", "tanggal": "07/12/2025"},
    {"id": "ADJ-2512-0002", "gudang": "Gudang Utama", "tanggal": "06/12/2025"},
    {"id": "ADJ-2512-0001", "gudang": "Gudang Utama", "tanggal": "05/12/2025"},
  ];

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
          "Stock Adjustment",
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
          // Search Bar sesuai gambar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Cari",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: Icon(Icons.tune, color: Colors.black87),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // List Stock Adjustment
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _adjustmentData.length,
              itemBuilder: (context, index) {
                final item = _adjustmentData[index];
                return _buildAdjustmentCard(item);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi tambah data baru
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahStkAdjustPage()));
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildAdjustmentCard(Map<String, String> item) {
    return InkWell(
      onTap: () {
        // Navigasi ke detail adjustment jika ada
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailStckAdjustmentPage()));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['id']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Badge Gudang
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F3FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warehouse_outlined,
                        size: 14,
                        color: Color(0xFF5C6BC0),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['gudang']!,
                        style: const TextStyle(
                          color: Color(0xFF5C6BC0),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Garis Penghubung (Spacer Line)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    height: 1,
                    color: Colors.grey.shade100,
                  ),
                ),
                // Tanggal
                Text(
                  item['tanggal']!,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
