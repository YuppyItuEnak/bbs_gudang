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

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Stock Opname",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),

      /// ================= BODY =================
      body: Consumer<StockOpnameProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.reports.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.reports.isEmpty) {
            return const Center(child: Text("Data stock opname kosong"));
          }

          return Column(
            children: [
              /// 🔍 SEARCH BAR
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            icon: Icon(Icons.search),
                            hintText: "Cari",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune),
                    ),
                  ],
                ),
              ),

              /// 📄 LIST
              Expanded(
                child: RefreshIndicator(
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
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.reports.length,
                    itemBuilder: (context, index) {
                      return _buildStockCard(context, provider.reports[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),

      /// ➕ FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahStckOpnamePage()),
          );

          if (result == true) {
            final token = context.read<AuthProvider>().token;
            await context.read<StockOpnameProvider>().fetchStockOpnameReport(
              token: token!,
              startDate: '',
              endDate: '',
              loadMore: true,
            );
          }
        },
      ),
    );
  }

  /// ================= CARD ITEM =================
  Widget _buildStockCard(BuildContext context, StockOpnameModel item) {
    final token = context.read<AuthProvider>().token;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DetailStockOpnamePage(opnameId: item.id, token: token!),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// CODE + STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                _statusBadge(item.status),
              ],
            ),
            const SizedBox(height: 8),

            /// WAREHOUSE + DATE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warehouse, size: 16, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(
                      item.warehouse?.name ?? '-',
                      style: const TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ],
                ),
                Text(
                  item.date != null
                      ? DateFormat('dd/MM/yyyy').format(item.date!)
                      : '-',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ================= STATUS BADGE =================
  Widget _statusBadge(String status) {
    Color bg;
    Color text;

    switch (status) {
      case 'DRAFT':
        bg = Colors.orange.withOpacity(0.15);
        text = Colors.orange;
        break;
      case 'SUBMITTED':
        bg = Colors.blue.withOpacity(0.15);
        text = Colors.blue;
        break;
      case 'POSTED':
        bg = Colors.green.withOpacity(0.15);
        text = Colors.green;
        break;
      default:
        bg = Colors.grey.withOpacity(0.15);
        text = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
