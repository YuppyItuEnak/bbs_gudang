import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/providers/transfer_warehouse_provider.dart';

class ListItemTerpilihPage extends StatelessWidget {
  const ListItemTerpilihPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<TransferWarehouseProvider>().items;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "List Item Terpilih",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: items.isEmpty
          ? const Center(child: Text("Belum ada item terpilih"))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _ItemCard(item: item);
              },
            ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
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
      ),
      child: Column(
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                // Tambahkan expanded agar text tidak overflow
                child: Text(
                  item['name'] ?? item['item_name'], // UBAH KE 'item_name'
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                    fontSize: 15,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.read<TransferWarehouseProvider>().removeItem(
                    item['id'],
                  );
                },
                child: const Text(
                  "Hapus",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // BODY
          Row(
            children: [
              Expanded(
                child: Text(
                  item['item_code'] ?? item['code'], // UBAH KE 'item_code'
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ),
              Text(item['uom_name'] ?? 'PCS'), // UBAH KE 'uom_name'
              const SizedBox(width: 10),

              Row(
                children: [
                  _qtyBtn(
                    icon: Icons.remove,
                    onTap: () {
                      if ((item['qty'] ?? 0) > 1) {
                        context.read<TransferWarehouseProvider>().updateQty(
                          item['id'],
                          (item['qty'] ?? 1) - 1,
                        );
                      }
                    },
                  ),
                  Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: Text(
                      item['qty'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _qtyBtn(
                    icon: Icons.add,
                    onTap: () {
                      context.read<TransferWarehouseProvider>().updateQty(
                        item['id'],
                        (item['qty'] ?? 0) + 1,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
