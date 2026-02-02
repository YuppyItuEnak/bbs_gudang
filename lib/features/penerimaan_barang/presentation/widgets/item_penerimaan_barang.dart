import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/providers/penerimaan_barang_provider.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/widgets/additem_pb_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemPenerimaanBarang extends StatefulWidget {
  const ItemPenerimaanBarang({super.key});

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

              /// ADD ITEM BUTTON
              TextButton.icon(
                onPressed: () async {
                  final token = context.read<AuthProvider>().token;
                  final poId = provider.selectedPO?.id;

                  if (token == null || poId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pilih PO terlebih dahulu")),
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

                    print("result: ${result}");
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

        /// LIST ITEM RESULT
        Expanded(
          child: provider.selectedItems.isEmpty
              ? const Center(child: Text("Belum ada item dipilih"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: provider.selectedItems.length,
                  itemBuilder: (context, index) {
                    final item = provider.selectedItems[index];
                    print("item: ${item}");

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

  /// ITEM CARD UI
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
              Text(
                name,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

          /// CODE + COUNTER
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

          const Divider(height: 20),

          /// NOTE PLACEHOLDER
          const Row(
            children: [
              Icon(Icons.edit, size: 14, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                "Catatan",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// COUNTER BUTTON
  Widget _buildCounter(PenerimaanBarangProvider provider, int index) {
    final qty = provider.selectedItems[index]["qty_receipt"] ?? 1;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove, color: Colors.blue),
          onPressed: () => provider.decreaseQty(index),
        ),
        Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.green),
          onPressed: () => provider.increaseQty(index),
        ),
      ],
    );
  }
}
