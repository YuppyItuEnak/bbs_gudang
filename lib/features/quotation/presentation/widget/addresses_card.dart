import 'package:bbs_gudang/data/models/customer/customer_address_model.dart';
import 'package:flutter/material.dart';

class AddressCard extends StatelessWidget {
  final CustomerAddressModel address;
  final bool active;
  final VoidCallback? onTap;

  const AddressCard({
    super.key,
    required this.address,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: active ? const Color(0xFF5F6BF7) : Colors.transparent,
          ),
          color: const Color(0xFFF7F8FC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  address.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                // This seems to be missing from the model, so I'll leave it hardcoded for now
                const Text(
                  'Delivery Area A',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              address.address,
              style: const TextStyle(fontSize: 13),
            ),
            if (address.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                address.notes,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (address.isActive)
                  _Tag(label: 'Aktif', color: Colors.green),
                const SizedBox(width: 8),
                if (address.isDefault)
                  _Tag(label: 'Default', color: const Color(0xFF5F6BF7)),
                const Spacer(),
                const Text(
                  'Edit',
                  style: TextStyle(color: Color(0xFF5F6BF7)),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }
}
