import 'package:flutter/material.dart';

class ItemCard extends StatefulWidget {
  final String nama;
  final String kode;
  final int initialQty;
  final Function(int) onQtyChanged;

  const ItemCard({
    super.key,
    required this.nama,
    required this.kode,
    required this.initialQty,
    required this.onQtyChanged,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  late int qty;

  @override
  void initState() {
    super.initState();
    qty = widget.initialQty;
  }

  void _updateQty(int newQty) {
    if (newQty < 0) return;

    setState(() {
      qty = newQty;
    });

    widget.onQtyChanged(qty); // 🔥 update ke parent
  }

  @override
  Widget build(BuildContext context) {
    bool isSelected = qty > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected ? Colors.green.shade300 : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.kode,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ],
            ),
          ),
          const Text("PCS", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 10),

          // --- Qty Selector ---
          Row(
            children: [
              _buildQtyBtn(
                icon: Icons.remove,
                color: isSelected ? Colors.green : Colors.blue.shade100,
                onTap: () {
                  if (qty > 0) _updateQty(qty - 1);
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
                  qty.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              _buildQtyBtn(
                icon: Icons.add,
                color: Colors.green,
                onTap: () => _updateQty(qty + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
