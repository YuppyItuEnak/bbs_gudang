import 'dart:ffi';

import 'package:bbs_gudang/data/models/stock_opname/stock_opname_detail.dart';
import 'package:bbs_gudang/features/stock_opname/presentation/providers/stock_opname_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailStockOpnamePage extends StatefulWidget {
  final String opnameId;
  final String token;

  const DetailStockOpnamePage({
    super.key,
    required this.opnameId,
    required this.token,
  });

  @override
  State<DetailStockOpnamePage> createState() => _DetailStockOpnamePageState();
}

class _DetailStockOpnamePageState extends State<DetailStockOpnamePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<StockOpnameProvider>().fetchDetailOpnameReport(
        token: widget.token,
        opnameId: widget.opnameId,
      );
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockOpnameProvider>();

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
          "Stock Opname",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(StockOpnameProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Text(
          provider.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final header = provider.listDetail;
    if (header == null) {
      return const Center(child: Text("Data kosong"));
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER INFO
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeaderIconText(
                      Icons.calendar_today_outlined,
                      _formatDate(header.date),
                    ),
                    _buildStatusBadge(header.status),
                  ],
                ),
                const SizedBox(height: 12),

                _buildHeaderIconText(Icons.description_outlined, header.code),

                const SizedBox(height: 12),

                _buildHeaderIconText(
                  Icons.warehouse_outlined,
                  header.warehouse?.name ?? '-',
                ),

                const SizedBox(height: 12),

                _buildHeaderIconText(
                  Icons.edit_outlined,
                  header.notes.isEmpty ? '-' : header.notes,
                ),

                const SizedBox(height: 30),

                /// ITEM LIST
                const Text(
                  "Item Terpilih",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 15),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: header.details.length,
                  itemBuilder: (context, index) {
                    return _buildReadOnlyItemCard(header.details[index]);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ---------- UI HELPERS ----------

  Widget _buildHeaderIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade300),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Colors.black54, fontSize: 14)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = status == 'POSTED' ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReadOnlyItemCard(StockOpnameDetailModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Wrap your existing Column like this:
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.item?.name ?? '-',
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis, // This will now work correctly!
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.item?.code ?? '-',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "${item.opnameQty} ${item.item?.itemTypeName ?? '-'}",
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
