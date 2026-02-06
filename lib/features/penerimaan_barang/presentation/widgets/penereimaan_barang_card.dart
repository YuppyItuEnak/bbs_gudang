import 'package:flutter/material.dart';

class PenerimaanBarangCard extends StatelessWidget {
  final Map<String, String> data;
  final VoidCallback? onTap;

  const PenerimaanBarangCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
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
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Nomor PO & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['po_no'] ?? '-',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
                // Flag Status ditambahkan di sini
                _buildStatusBadge(data['status'] ?? 'Draft'),
              ],
            ),
            const SizedBox(height: 4),

            // Nomor SI (Sub-header)
            Text(
              "SI: ${data['si_no'] ?? '-'}",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
            ),
            const SizedBox(height: 8),

            // Row 2: Nama Vendor
            Text(
              data['vendor'] ?? '-',
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            // Row 3: Nopol, Driver, dan Tanggal
            Row(
              children: [
                _buildInfoBadge(data['nopol'] ?? '-'),
                const SizedBox(width: 8),
                _buildInfoBadge(data['driver'] ?? '-'),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    height: 1,
                    color: Colors.grey.shade100,
                  ),
                ),
                Text(
                  data['date'] ?? '-',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper untuk membuat Badge Info (Nopol/Driver)
  Widget _buildInfoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Helper untuk membuat Flag Status dengan warna dinamis
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    // Logika penentuan warna berdasarkan teks status
    switch (status.toLowerCase()) {
      case 'posted':
      case 'approved':
      case 'received':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'proses':
      case 'pending':
      case 'otw':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case 'draft':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20), // Membuat bentuk pill
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
