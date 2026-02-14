import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/providers/penerimaan_barang_provider.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/widgets/additem_pb_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemPenerimaanBarang extends StatefulWidget {
  final bool isEdit;
  final bool allowAdd;

  const ItemPenerimaanBarang({
    super.key,
    this.isEdit = false,
    this.allowAdd = true,
  });

  @override
  State<ItemPenerimaanBarang> createState() => _ItemPenerimaanBarangState();
}

class _ItemPenerimaanBarangState extends State<ItemPenerimaanBarang> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PenerimaanBarangProvider>();

    return Column(
      children: [
        /// HEADER
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Penerimaan Barang",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              
                TextButton.icon(
                  onPressed: () async {
                    final token = context.read<AuthProvider>().token;
                    final poId = provider.selectedPO?.id;

                    if (token == null || poId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Pilih PO terlebih dahulu"),
                        ),
                      );
                      return;
                    }

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddItemPBPage(token: token, poId: poId),
                      ),
                    );

                    if (result != null && result is List) {
                      provider.setSelectedItems(
                        result.cast<Map<String, dynamic>>(),
                      );
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Item"),
                  style: TextButton.styleFrom(foregroundColor: Colors.green),
                ),
            ],
          ),
        ),

        /// LIST ITEM
        Expanded(
          child: provider.selectedItems.isEmpty
              ? const Center(child: Text("Belum ada item dipilih"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: provider.selectedItems.length,
                  itemBuilder: (_, index) {
                    final item = provider.selectedItems[index];
                    return _buildItemCard(
                      provider: provider,
                      name: item["item_name"] ?? "-",
                      code: item["item_code"] ?? "-",
                      qty: item["qty_receipt"] ?? 0,
                      index: index,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildItemCard({
    required PenerimaanBarangProvider provider,
    required String name,
    required String code,
    required int qty,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          /// TITLE + DELETE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis, // Akan jadi "Nama Barang Yan..."
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (!widget.isEdit)
                GestureDetector(
                  onTap: () => provider.removeItem(index),
                  child: const Text(
                    "Hapus",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              Text(
                code,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const Spacer(),
              _buildCounter(provider, index),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(PenerimaanBarangProvider provider, int index) {
    // Ambil langsung dari list provider agar reaktif
    final qty = provider.selectedItems[index]["qty_receipt"];

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
          onPressed: () => provider.decreaseQty(index),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            "$qty",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
          onPressed: () => provider.increaseQty(index),
        ),
      ],
    );
  }
}
