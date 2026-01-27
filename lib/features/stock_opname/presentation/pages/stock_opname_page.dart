import 'package:bbs_gudang/data/models/stock_opname/stock_opname_model.dart';
import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/stock_opname/presentation/pages/detail_stock_opname_page.dart';
import 'package:bbs_gudang/features/stock_opname/presentation/pages/tambah_stck_opname_page.dart';
import 'package:bbs_gudang/features/stock_opname/presentation/providers/stock_opname_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StockOpnamePage extends StatefulWidget {
  const StockOpnamePage({super.key});

  @override
  State<StockOpnamePage> createState() => _StockOpnamePageState();
}

class _StockOpnamePageState extends State<StockOpnamePage> {
  @override
  void initState() {
    super.initState();

    /// Fetch data pertama kali
    Future.microtask(() {
      final token = context.read<AuthProvider>().token;
      if (token == null) return;

      context.read<StockOpnameProvider>().fetchStockOpnameReport(
        token: token,
        startDate: '',
        endDate: '',
      );
    });
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
          "Stock Opname",
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
          /// SEARCH BAR
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

          /// LIST DATA
          Expanded(
            child: Consumer<StockOpnameProvider>(
              builder: (context, provider, _) {
                /// Loading awal
                if (provider.isLoading && provider.reports.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                /// Error
                if (provider.errorMessage != null) {
                  return Center(
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                /// Empty
                if (provider.reports.isEmpty) {
                  return const Center(child: Text("Data stock opname kosong"));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    final token = context.read<AuthProvider>().token;
                    await provider.fetchStockOpnameReport(
                      token: token!,
                      startDate: '',
                      endDate: '',
                      loadMore: false,
                    );
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: provider.reports.length,
                    itemBuilder: (context, index) {
                      final item = provider.reports[index];
                      return _buildStockCard(context, item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      /// FLOATING BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahStckOpnamePage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// CARD ITEM
  Widget _buildStockCard(BuildContext context, StockOpnameModel item) {
    final token = context.read<AuthProvider>().token;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailStockOpnamePage(
              opnameId: item.id, // 🔥 WAJIB ID, bukan code
              token: token!,
            ),
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
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// CODE
            Text(
              item.code,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                /// WAREHOUSE
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
                        item.warehouse?.name ?? '-',
                        style: const TextStyle(
                          color: Color(0xFF5C6BC0),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                /// DATE
                Text(
                  DateFormat('dd MMM yyyy').format(item.date),
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
