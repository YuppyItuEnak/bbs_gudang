import 'package:flutter/material.dart';

class ItemSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final bool isSelected;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ItemSelectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.count,
    this.isSelected = false,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.green : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.green : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Text("PCS", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(width: 10),
          // Tombol Kurang
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: count > 0 ? Colors.green : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.remove, color: count > 0 ? Colors.white : Colors.blue.shade300, size: 18),
            ),
          ),
          // Angka Counter
          Container(
            width: 50,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "$count",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Tombol Tambah
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}