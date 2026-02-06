import 'package:bbs_gudang/data/models/pengeluaran_barang/pengeluaran_barang_model.dart';
import 'package:flutter/material.dart';

class PengeluaranBarangCard extends StatelessWidget {
  final PengeluaranBarangModel data;
  final VoidCallback? onTap;

  const PengeluaranBarangCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Aksen garis biru kiri
              Container(width: 5, color: const Color(0xFF2196F3)),
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // 🔹 Baris Atas: ID & STATUS BADGE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data.code ?? "-", // ID PB
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            // --- FLAG STATUS ---
                            _buildStatusBadge(
                              data.status.toString() ?? "Draft",
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // 🔹 Baris Tengah: Customer & SIC
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // CUSTOMER (KIRI)
                            Expanded(
                              flex: 2,
                              child: Text(
                                data.customerModel?.name ?? "-",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF424242),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // SO / SIC (KANAN)
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  data.salesOrder?.code ?? "-",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 🔹 Baris Bawah: Nopol, Driver & Tanggal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Nopol & Driver Group
                            Row(
                              children: [
                                Text(
                                  data.deliveryPlan?.nopol ?? "-",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                                const Text(
                                  " • ",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  data.deliveryPlan?.driver ?? "-",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            // Tanggal
                            Text(
                              data.date ?? "-",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper untuk membuat Badge Status
  Widget _buildStatusBadge(dynamic statusValue) {
    String statusText = "";
    Color bgColor;
    Color textColor;

    // Konversi input ke String untuk keamanan pengecekan
    final status = statusValue?.toString() ?? "";

    switch (status) {
      case '1': // DRAFT
        statusText = "DRAFT";
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case '2': // POSTED
        statusText = "POSTED";
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case '3': // Contoh jika ada status CANCEL/VOID
        statusText = "CANCEL";
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      default:
        statusText = "UNKNOWN";
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
