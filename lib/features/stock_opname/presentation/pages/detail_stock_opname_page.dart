import 'package:flutter/material.dart';

class DetailStockOpnamePage extends StatefulWidget {
  const DetailStockOpnamePage({super.key});

  @override
  State<DetailStockOpnamePage> createState() => _DetailStockOpnamePageState();
}

class _DetailStockOpnamePageState extends State<DetailStockOpnamePage> {
  // Data dummy sesuai gambar
  final List<Map<String, String>> selectedItems = [
    {"nama": "Barang A", "kode": "Kode0001", "qty": "25"},
    {"nama": "Barang B", "kode": "Kode0002", "qty": "15"},
    {"nama": "Barang C", "kode": "Kode0003", "qty": "42"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FA,
      ), // Background sedikit keabuan agar card putih kontras
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Stock Opname",
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
                  // --- Section Header Info ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderIconText(
                        Icons.calendar_today_outlined,
                        "06 Desember 2025",
                      ),
                      _buildStatusBadge(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildHeaderIconText(
                    Icons.description_outlined,
                    "OPC-2501-0001",
                  ),
                  const SizedBox(height: 12),
                  _buildHeaderIconText(
                    Icons.warehouse_outlined,
                    "Gudang Utama",
                  ),
                  const SizedBox(height: 12),
                  _buildHeaderIconText(Icons.edit_outlined, "Catatan"),

                  const SizedBox(height: 30),

                  // --- Section Title ---
                  const Text(
                    "Item Terpilih",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- List of Items ---
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedItems.length,
                    itemBuilder: (context, index) {
                      final item = selectedItems[index];
                      return _buildReadOnlyItemCard(item);
                    },
                  ),
                ],
              ),
            ),
          ),

          // --- Bottom Button ---
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
                    borderRadius: BorderRadius.circular(10),
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

  // Widget Helper untuk Baris Info (Icon + Teks)
  Widget _buildHeaderIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade300),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Colors.black54, fontSize: 14)),
      ],
    );
  }

  // Badge Status Posted (Kuning)
  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107), // Warna Amber/Kuning sesuai Posted
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "Posted",
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Card Item Read Only (Mode Detail)
  Widget _buildReadOnlyItemCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['nama']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['kode']!,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9), // Hijau sangat muda
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "${item['qty']} PCS",
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
