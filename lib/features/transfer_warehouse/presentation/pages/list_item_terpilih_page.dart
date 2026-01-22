import 'package:flutter/material.dart';

class ListItemTerpilihPage extends StatefulWidget {
  const ListItemTerpilihPage({super.key});

  @override
  State<ListItemTerpilihPage> createState() => _ListItemTerpilihPageState();
}

class _ListItemTerpilihPageState extends State<ListItemTerpilihPage> {
  // Data dummy item yang sudah terpilih
  final List<Map<String, dynamic>> selectedItems = [
    {"nama": "Barang A", "kode": "Kode0001", "qty": 12},
    {"nama": "Barang B", "kode": "Kode0002", "qty": 5},
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
          "List Item Terpilih",
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
          // --- SEARCH BAR SECTION ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // --- HEADER SECTION (Title & Add Button) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Item Terpilih",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigasi kembali ke halaman pilih item
                  },
                  child: const Text(
                    "+ Add Item",
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- LIST SECTION ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: selectedItems.length,
              itemBuilder: (context, index) {
                final item = selectedItems[index];
                return _buildSelectedItemCard(index, item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedItemCard(int index, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row atas: Nama Item & Tombol Hapus
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['nama'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                  fontSize: 15,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedItems.removeAt(index);
                  });
                },
                child: const Text(
                  "Hapus",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Row bawah: Kode & Qty Selector
          Row(
            children: [
              Expanded(
                child: Text(
                  item['kode'],
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ),
              const Text(
                "PCS",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(width: 10),
              // Qty Selector
              Row(
                children: [
                  _buildQtyBtn(
                    icon: Icons.remove,
                    onTap: () {
                      if (item['qty'] > 1) {
                        setState(() => item['qty']--);
                      }
                    },
                  ),
                  Container(
                    width: 60,
                    height: 35,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      item['qty'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildQtyBtn(
                    icon: Icons.add,
                    onTap: () {
                      setState(() => item['qty']++);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
