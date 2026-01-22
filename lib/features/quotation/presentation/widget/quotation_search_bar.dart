import 'package:flutter/material.dart';
import 'quotation_filter_modal.dart';

class QuotationSearchBar extends StatefulWidget {
  final Function(String) onSubmitted;
  const QuotationSearchBar({super.key, required this.onSubmitted});

  @override
  State<QuotationSearchBar> createState() => _QuotationSearchBarState();
}

class _QuotationSearchBarState extends State<QuotationSearchBar> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: widget.onSubmitted,
                decoration: const InputDecoration(
                  hintText: 'Cari',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _showFilterModal(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7FB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          child: QuotationFilterModal(),
        );
      },
    );
  }
}
