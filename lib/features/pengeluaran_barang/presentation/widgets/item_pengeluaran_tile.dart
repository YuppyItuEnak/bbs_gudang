import 'package:flutter/material.dart';

class ItemPengeluaranTile extends StatelessWidget {
  final String noSo;
  final String namaBarang;
  final String qty;
  final String qtySo;
  final String qtyDikirim;
  final String sisa;
  final bool isSwiped;
  final String noDO;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;

  const ItemPengeluaranTile({
    super.key,
    required this.noSo,
    required this.namaBarang,
    required this.qty,
    required this.qtySo,
    required this.qtyDikirim,
    required this.sisa,
    required this.noDO,
    this.isSwiped = false,
    this.onEditTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSwiped ? const Color(0xFFF3F6FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- PERBAIKAN DI SINI: SO & DO ATAS BAWAH ---
                    Text(
                      "SO: $noSo",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2), // Jarak tipis antara SO dan DO
                    Text(
                      "DO: $noDO",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),

                    // ---------------------------------------------
                    const SizedBox(height: 8),

                    // ROW 2: Nama Barang & Qty Utama
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            namaBarang,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          qty,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ROW 3: Qty SO & Qty Dikirim
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Qty SO : $qtySo",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "Qty Dikirim : $qtyDikirim",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Badge Sisa Qty
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
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
                    const SizedBox(height: 8),

                    // Deskripsi & Catatan
                    const Text(
                      "Deskripsi : Lorem Ipsum",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
              // TOMBOL EDIT
              GestureDetector(
                onTap: onEditTap,
                child: Container(
                  width: 50,
                  color: const Color(0xFFE8EEFF),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              // TOMBOL HAPUS
              GestureDetector(
                onTap: onDeleteTap,
                child: Container(
                  width: 50,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
