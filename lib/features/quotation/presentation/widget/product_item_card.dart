import 'package:bbs_gudang/core/constants/api_constants.dart';
import 'package:bbs_gudang/data/models/item/item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductItemCard extends StatefulWidget {
  final ItemModel product;
  final bool isSelected;
  final VoidCallback? onTap;
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final ValueChanged<int>? onQuantityChanged;

  const ProductItemCard({
    super.key,
    required this.product,
    this.isSelected = false,
    this.onTap,
    this.quantity = 1,
    this.onIncrement,
    this.onDecrement,
    this.onQuantityChanged,
  });

  @override
  State<ProductItemCard> createState() => _ProductItemCardState();
}

class _ProductItemCardState extends State<ProductItemCard> {
  late TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: widget.quantity.toString());
  }

  @override
  void didUpdateWidget(covariant ProductItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentVal = int.tryParse(_qtyController.text);
    if (currentVal != widget.quantity) {
      if (_qtyController.text.isNotEmpty) {
        _qtyController.text = widget.quantity.toString();
        _qtyController.selection = TextSelection.fromPosition(
          TextPosition(offset: _qtyController.text.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isSelected
                ? const Color(0xFF5F6BF7)
                : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: widget.isSelected,
                  onChanged: (value) {
                    if (widget.onTap != null) {
                      widget.onTap!();
                    }
                  },
                  activeColor: const Color(0xFF5F6BF7),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        widget.product.code,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.product.photo != null &&
                    widget.product.photo!.isNotEmpty)
                  Image.network(
                    '${ApiConstants.baseUrl2}${widget.product.photo!}',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.error),
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            if (widget.isSelected) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          _buildQtyButton(Icons.remove, widget.onDecrement),
                          SizedBox(
                            width: 50,
                            child: TextField(
                              controller: _qtyController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                // contentPadding: EdgeInsets.symmetric(vertical: 8),
                              ),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              onChanged: (value) {
                                if (widget.onQuantityChanged != null) {
                                  final val = int.tryParse(value);
                                  if (val != null) {
                                    widget.onQuantityChanged!(val);
                                  }
                                }
                              },
                            ),
                          ),
                          _buildQtyButton(Icons.add, widget.onIncrement),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.product.uom ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback? onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFF5F6BF7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
