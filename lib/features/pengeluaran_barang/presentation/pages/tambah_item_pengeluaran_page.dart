import 'package:flutter/material.dart';
import '../widgets/item_selection_card.dart';

class TambahItemPengeluaranPage extends StatefulWidget {
  const TambahItemPengeluaranPage({super.key});

  @override
  State<TambahItemPengeluaranPage> createState() =>
      _TambahItemPengeluaranPageState();
}

class _TambahItemPengeluaranPageState extends State<TambahItemPengeluaranPage> {
  // Data dummy item
  final List<Map<String, dynamic>> _items = [
    {"name": "Barang A", "code": "Kode0001", "qty": 12},
    {"name": "Barang B", "code": "Kode0002", "qty": 5},
    {"name": "Barang C", "code": "Kode0003", "qty": 0},
    {"name": "Barang D", "code": "Kode0004", "qty": 0},
    {"name": "Barang E", "code": "Kode0005", "qty": 0},
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
          "List Item",
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
          // Search Bar
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

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Pilih Item",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),

          // Daftar Item
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ItemSelectionCard(
                  title: item['name'],
                  subtitle: item['code'],
                  count: item['qty'],
                  isSelected: item['qty'] > 0,
                  onAdd: () {
                    setState(() => _items[index]['qty']++);
                  },
                  onRemove: () {
                    if (_items[index]['qty'] > 0) {
                      setState(() => _items[index]['qty']--);
                    }
                  },
                );
              },
            ),
          ),

          // Tombol Tambahkan
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Logika untuk menyimpan item terpilih
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Tambahkan",
                  style: TextStyle(
                    color: Colors.white,
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
}
