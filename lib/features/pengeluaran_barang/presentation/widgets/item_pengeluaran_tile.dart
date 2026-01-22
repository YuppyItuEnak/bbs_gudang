import 'package:flutter/material.dart';

class ItemPengeluaranTile extends StatelessWidget {
  final String noSo;
  final String namaBarang;
  final String qty;
  final String qtySo;
  final String qtyDikirim;
  final String sisa;
  final bool isSwiped;
  final VoidCallback? onEditTap; // Tambahkan ini

  const ItemPengeluaranTile({
    super.key,
    required this.noSo,
    required this.namaBarang,
    required this.qty,
    required this.qtySo,
    required this.qtyDikirim,
    required this.sisa,
    this.isSwiped = false,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSwiped ? const Color(0xFFF3F6FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        noSo,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        noSo,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        namaBarang,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        qty,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Qty SO : $qtySo",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Qty Dikirim : $qtyDikirim",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "Sisa Qty SO : $sisa",
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Deskripsi : Lorem Ipsum",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const Text(
                    "Catatan : -",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          if (isSwiped) ...[
            // Bungkus Ikon Edit dengan GestureDetector
            GestureDetector(
              onTap: onEditTap, // Panggil fungsi saat diklik
              child: Container(
                width: 50,
                height: 120, // Pastikan tinggi sesuai dengan kartu
                color: const Color(0xFFF3F6FF),
                child: const Icon(Icons.edit_outlined, color: Colors.black54),
              ),
            ),
            Container(
              width: 50,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
