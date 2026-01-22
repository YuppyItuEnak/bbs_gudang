import 'package:flutter/material.dart';

class QuotationItemCard extends StatelessWidget {
  final String code;
  final String name;
  final String subtotal;
  final int quantity;

  const QuotationItemCard({
    super.key,
    required this.code,
    required this.name,
    required this.subtotal,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(code, style: const TextStyle(fontSize: 12)),
              const Text(
                'Hapus',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Qty: '),
              Text(
                quantity.toString(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              const Text('Sub Total'),
              const SizedBox(width: 8),
              Text(
                subtotal,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
