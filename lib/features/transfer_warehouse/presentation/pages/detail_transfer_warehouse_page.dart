import 'package:flutter/material.dart';

class DetailTransferWarehousePage extends StatefulWidget {
  const DetailTransferWarehousePage({super.key});

  @override
  State<DetailTransferWarehousePage> createState() =>
      _DetailTransferWarehousePageState();
}

class _DetailTransferWarehousePageState
    extends State<DetailTransferWarehousePage> {
  // Data Dummy untuk Item
  final List<Map<String, String>> items = [
    {"nama": "Barang A", "kode": "Kode0001", "qty": "12 PCS"},
    {"nama": "Barang B", "kode": "Kode0002", "qty": "5 PCS"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Transfer Warehouse Detail",
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
                  // --- HEADER: DATE & STATUS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.grey[400],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "02 Agustus 2025",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300), // Warna Amber/Orange
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Posted",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // --- TRANS TRANSACTION NUMBER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "No. Transfer Warehouse",
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                      const Text(
                        "TW-2501-0001",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- WAREHOUSE PATH CARD ---
                  _buildWarehousePathCard(),
                  const SizedBox(height: 20),

                  // --- NOTES ---
                  Row(
                    children: [
                      Icon(Icons.edit_note, color: Colors.grey[400], size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "Catatan",
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // --- ITEM LIST SECTION ---
                  const Text(
                    "Item Terpilih",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildItemDetailCard(items[index]);
                    },
                  ),
                ],
              ),
            ),
          ),

          // --- BOTTOM BUTTON ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
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
                    fontSize: 16,
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

  // Widget untuk alur Gudang Awal ke Tujuan
  Widget _buildWarehousePathCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FDF3), // Hijau sangat muda
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildWarehouseLabel("Gudang Awal", "Gudang Utama", Colors.red),
          _buildPathDivider(),
          _buildWarehouseLabel("Gudang Tujuan", "Gudang Retur", Colors.green),
        ],
      ),
    );
  }

  Widget _buildWarehouseLabel(String label, String name, Color dotColor) {
    return Column(
      crossAxisAlignment: (dotColor == Colors.red)
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor == Colors.red)
              Icon(Icons.circle, size: 8, color: dotColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                label,
                style: const TextStyle(color: Colors.green, fontSize: 12),
              ),
            ),
            if (dotColor == Colors.green)
              Icon(Icons.circle, size: 8, color: dotColor),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPathDivider() {
    return Row(
      children: [
        Text("· · · ", style: TextStyle(color: Colors.blue[300])),
        Icon(Icons.circle, size: 10, color: Colors.blue[600]),
        Text(" · · ·", style: TextStyle(color: Colors.blue[300])),
      ],
    );
  }

  // Widget untuk Kartu Detail Item
  Widget _buildItemDetailCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['kode']!,
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FDF3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item['qty']!,
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
