import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/stock_adjustment/presentation/pages/detail_stck_adjustment_page.dart';
import 'package:bbs_gudang/features/stock_adjustment/presentation/pages/tambah_stk_adjust_page.dart';
import 'package:bbs_gudang/data/models/stock_adjustment/stock_adjustment_model.dart';
import 'package:bbs_gudang/features/stock_adjustment/presentation/providers/stock_adjustment_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StkAdjustmentPage extends StatefulWidget {
  const StkAdjustmentPage({super.key});

  @override
  State<StkAdjustmentPage> createState() => _StkAdjustmentPageState();
}

class _StkAdjustmentPageState extends State<StkAdjustmentPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final token = context.read<AuthProvider>().token;

    /// Fetch pertama
    Future.microtask(() {
      context.read<StockAdjustmentProvider>().fetchStockAdjustments(
        token: token!,
        loadMore: true,
      );
    });

    /// Infinite scroll
    _scrollController.addListener(() {
      final provider = context.read<StockAdjustmentProvider>();

      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          provider.hasMore &&
          !provider.isLoading) {
        provider.fetchStockAdjustments(token: token!, loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Stock Adjustment",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// SEARCH BAR (belum difungsikan)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Cari",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: Icon(Icons.tune, color: Colors.black87),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          /// LIST DATA DARI PROVIDER
          Expanded(
            child: Consumer<StockAdjustmentProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.data.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(child: Text(provider.error!));
                }

                if (provider.data.isEmpty) {
                  return const Center(child: Text("Data kosong"));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    final token = context.read<AuthProvider>().token!;
                    await provider.fetchStockAdjustments(
                      token: token,
                      loadMore: true,
                    );
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount:
                        provider.data.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.data.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final item = provider.data[index];
                      return _buildAdjustmentCard(item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      /// FAB TAMBAH
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahStkAdjustPage(),
            ),
          );

          /// ✅ Refresh setelah tambah
          if (result == true) {
            final token = context.read<AuthProvider>().token!;
            await context.read<StockAdjustmentProvider>().fetchStockAdjustments(
              token: token,
              loadMore: false,
            );
          }
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  /// CARD ITEM
  Widget _buildAdjustmentCard(StockAdjustmentModel item) {
    Color statusColor;
    String statusText = item.status ?? "-";

    switch (statusText.toUpperCase()) {
      case "APPROVED":
        statusColor = Colors.green;
        break;
      case "REJECTED":
        statusColor = Colors.red;
        break;
      case "DRAFT":
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailStckAdjustmentPage(adjustmentId: item.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER: CODE + STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                /// STATUS BADGE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                /// GUDANG
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F3FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warehouse_outlined,
                        size: 14,
                        color: Color(0xFF5C6BC0),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.warehouse?.name ?? "-",
                        style: const TextStyle(
                          color: Color(0xFF5C6BC0),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    height: 1,
                    color: Colors.grey.shade100,
                  ),
                ),

                /// TANGGAL
                Text(
                  item.date.substring(0, 10),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
