import 'package:flutter/material.dart';

class ItemPenerimaanBarang extends StatelessWidget {
  const ItemPenerimaanBarang({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Penerimaan Barang", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add Item"),
                style: TextButton.styleFrom(foregroundColor: Colors.green),
              )
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildItemCard("Barang E", "Kode0005", "5"),
              _buildItemCard("Barang A", "Kode0004", "5"),
              _buildItemCard("Barang B", "Kode0002", "5"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(String name, String code, String sisa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              const Text("Hapus", style: TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(code, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const Spacer(),
              Text("Sisa PO $sisa", style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(width: 10),
              _buildCounter(),
            ],
          ),
          const Divider(height: 25),
          const Row(
            children: [
              Icon(Icons.edit, size: 14, color: Colors.blue),
              SizedBox(width: 8),
              Text("Catatan", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCounter() {
    return Row(
      children: [
        _counterBtn(Icons.remove, Colors.blue.shade100, Colors.blue),
        Container(
          width: 40,
          alignment: Alignment.center,
          child: const Text("0", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        _counterBtn(Icons.add, Colors.green, Colors.white),
      ],
    );
  }

  Widget _counterBtn(IconData icon, Color bg, Color iconCol) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Icon(icon, size: 16, color: iconCol),
    );
  }
}