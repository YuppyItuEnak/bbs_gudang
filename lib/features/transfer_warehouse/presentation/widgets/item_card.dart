import 'package:flutter/material.dart';

class ItemCard extends StatefulWidget {
  final String nama;
  final String kode;
  final double stock;
  final int initialQty;
  final Function(int) onQtyChanged;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final String stockLabel;
  final double? receivedQty;
  final int? maxQty;
  final double? excessTolerance;
  final bool showQtyCounter;

  const ItemCard({
    super.key,
    required this.nama,
    required this.kode,
    this.stock = 0.0,
    required this.initialQty,
    required this.onQtyChanged,
    this.isSelectionMode = false,
    this.onTap,
    this.stockLabel = 'Total Stock',
    this.receivedQty,
    this.maxQty,
    this.excessTolerance,
    this.showQtyCounter = true,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  late int qty;

  @override
  void initState() {
    super.initState();
    qty = widget.initialQty;
  }

  @override
  void didUpdateWidget(ItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQty != oldWidget.initialQty) {
      qty = widget.initialQty;
    }
  }

  void _updateQty(int newQty) {
    if (newQty < 0) return;
    if (widget.maxQty != null && newQty > widget.maxQty!) return;
    setState(() => qty = newQty);
    widget.onQtyChanged(qty);
  }

  @override
  Widget build(BuildContext context) {
    bool isSelected = qty > 0;

    return GestureDetector(
      // Aktifkan onTap hanya jika dalam mode seleksi
      onTap: widget.isSelectionMode ? widget.onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.green.shade300 : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.kode,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${widget.stockLabel}: ${widget.stock.toStringAsFixed(widget.stock.truncateToDouble() == widget.stock ? 0 : 2)}",
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.receivedQty != null && widget.receivedQty! > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Sudah Diterima: ${widget.receivedQty!.toStringAsFixed(widget.receivedQty!.truncateToDouble() == widget.receivedQty! ? 0 : 2)}",
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (widget.excessTolerance != null &&
                          widget.excessTolerance! > 0 &&
                          widget.maxQty != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.green.shade200,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            "Toleransi ${widget.excessTolerance!.toStringAsFixed(widget.excessTolerance! == widget.excessTolerance!.floorToDouble() ? 0 : 1)}% · Maks ${widget.maxQty}",
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // --- Logika Kondisional ---
            if (widget.isSelectionMode)
              const Icon(Icons.chevron_right, color: Colors.grey)
            else if (!widget.showQtyCounter)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  qty.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              )
            else ...[
              const Text(
                "PCS",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(width: 10),
              _buildQtySelector(isSelected),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQtySelector(bool isSelected) {
    final bool atMax = widget.maxQty != null && qty >= widget.maxQty!;
    return Row(
      children: [
        _buildQtyBtn(
          icon: Icons.remove,
          color: isSelected ? Colors.green : Colors.blue.shade100,
          onTap: () {
            if (qty > 0) _updateQty(qty - 1);
          },
        ),
        Container(
          width: 60,
          height: 35,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            qty.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        _buildQtyBtn(
          icon: Icons.add,
          color: atMax ? Colors.grey.shade400 : Colors.green,
          onTap: () => _updateQty(qty + 1),
        ),
      ],
    );
  }

  Widget _buildQtyBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
