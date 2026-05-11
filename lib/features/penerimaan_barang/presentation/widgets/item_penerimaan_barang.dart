import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/providers/penerimaan_barang_provider.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/widgets/additem_pb_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ItemPenerimaanBarang extends StatelessWidget {
  final bool isEdit;
  final bool allowAdd;

  const ItemPenerimaanBarang({
    super.key,
    this.isEdit = false,
    this.allowAdd = true,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PenerimaanBarangProvider>();

    return Column(
      children: [
        /// HEADER
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
          child: Row(
            children: [
              const Text(
                "Daftar Item",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              if (provider.selectedItems.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${provider.selectedItems.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (allowAdd)
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
                        builder: (_) =>
                            AddItemPBPage(token: token, poId: poId),
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
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        "Belum ada item dipilih",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: provider.selectedItems.length,
                  itemBuilder: (_, index) {
                    return _ItemCardPB(
                      key: ValueKey(
                        provider.selectedItems[index]["item_id"] ?? index,
                      ),
                      item: provider.selectedItems[index],
                      index: index,
                      isEdit: isEdit,
                      provider: provider,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ItemCardPB extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;
  final bool isEdit;
  final PenerimaanBarangProvider provider;

  const _ItemCardPB({
    super.key,
    required this.item,
    required this.index,
    required this.isEdit,
    required this.provider,
  });

  @override
  State<_ItemCardPB> createState() => _ItemCardPBState();
}

class _ItemCardPBState extends State<_ItemCardPB> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: "${widget.item['qty_receipt'] ?? 1}",
    );
  }

  @override
  void didUpdateWidget(_ItemCardPB old) {
    super.didUpdateWidget(old);
    final newQty = "${widget.item['qty_receipt'] ?? 1}";
    if (_controller.text != newQty) {
      _controller.text = newQty;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyQty(String val) {
    final parsed = int.tryParse(val);
    if (parsed == null || parsed < 1) {
      _controller.text = "${widget.item['qty_receipt'] ?? 1}";
      return;
    }
    final outstanding = (widget.item['qty_outstanding'] as num?)?.toInt();
    final clamped =
        outstanding != null && parsed > outstanding ? outstanding : parsed;
    widget.provider.updateQtyReceipt(widget.index, clamped);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final String name = item["item_name"] ?? "-";
    final String code = item["item_code"] ?? "-";
    final int qtyOrder = (item["qty_order"] as num?)?.toInt() ?? 0;
    final int qtyOutstanding = (item["qty_outstanding"] as num?)?.toInt() ?? 0;
    final int qtyReceipt = (item["qty_receipt"] as num?)?.toInt() ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// NAMA + HAPUS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (!widget.isEdit)
                GestureDetector(
                  onTap: () => widget.provider.removeItem(widget.index),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Hapus",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            code,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),

          const SizedBox(height: 10),

          /// INFO BADGES
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _infoBadge(
                label: "Qty Order",
                value: "$qtyOrder",
                color: Colors.blue,
              ),
              _infoBadge(
                label: "Outstanding",
                value: "$qtyOutstanding",
                color: Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          /// QTY RECEIPT COUNTER
          Row(
            children: [
              const Text(
                "Qty Terima:",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              _buildCounter(qtyReceipt, qtyOutstanding),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBadge({
    required String label,
    required String value,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 12, color: color.shade700),
          children: [
            TextSpan(text: "$label: "),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(int qty, int maxQty) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// MINUS
        _counterBtn(
          icon: Icons.remove,
          color: qty > 1 ? Colors.green : Colors.grey.shade300,
          onTap: qty > 1
              ? () => widget.provider.decreaseQty(widget.index)
              : null,
        ),

        /// INPUT
        Container(
          width: 62,
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: _applyQty,
            onTapOutside: (_) => _applyQty(_controller.text),
          ),
        ),

        /// PLUS
        _counterBtn(
          icon: Icons.add,
          color: maxQty == 0 || qty < maxQty ? Colors.green : Colors.grey.shade300,
          onTap: maxQty == 0 || qty < maxQty
              ? () => widget.provider.increaseQty(widget.index)
              : null,
        ),
      ],
    );
  }

  Widget _counterBtn({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
