import 'package:bbs_gudang/features/penerimaan_barang/presentation/pages/detail_penerimaan_barang_page.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/pages/detail_pengeluaran_brg_page.dart';
import 'package:bbs_gudang/features/stock_adjustment/presentation/pages/detail_stck_adjustment_page.dart';
import 'package:bbs_gudang/features/stock_opname/presentation/pages/detail_stock_opname_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/home/presentation/providers/history_gudang_provider.dart';

class HistoryGudangPage extends StatefulWidget {
  const HistoryGudangPage({super.key});

  @override
  State<HistoryGudangPage> createState() => _HistoryGudangPageState();
}

class _HistoryGudangPageState extends State<HistoryGudangPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllData();
    });
  }

  void _fetchAllData() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      final p = context.read<HistoryGudangProvider>();
      Future.wait([
        p.fetchPengeluaranBarangHistory(token: token),
        p.fetchPenerimaanBarangHistory(token: token),
        p.fetchStkAdjustHistory(token: token),
        p.fetchStkOpnameHistory(token: token),
      ]);
    }
  }

  String formatTanggalIndo(dynamic rawDate) {
    try {
      if (rawDate == null || rawDate == "") return "-";

      DateTime date;
      if (rawDate is DateTime) {
        date = rawDate;
      }
      else if (rawDate is String) {
        date = DateTime.parse(rawDate);
      } else {
        return rawDate.toString();
      }

      final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return rawDate.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            "Riwayat Transaksi",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Pengeluaran"),
              Tab(text: "Penerimaan"),
              Tab(text: "Adjustment"),
              Tab(text: "Opname"),
            ],
          ),
        ),
        body: Consumer<HistoryGudangProvider>(
          builder: (context, provider, _) {
            return TabBarView(
              children: [
                _buildTabContent(
                  provider: provider,
                  list: provider.listPengeluaranBarangHistory,
                  type: "Pengeluaran",
                  onRefresh: () => provider.fetchPengeluaranBarangHistory(
                    token: context.read<AuthProvider>().token!,
                  ),
                ),
                _buildTabContent(
                  provider: provider,
                  list: provider.listPenerimaanBarangHistory,
                  type: "Penerimaan",
                  onRefresh: () => provider.fetchPenerimaanBarangHistory(
                    token: context.read<AuthProvider>().token!,
                  ),
                ),
                _buildTabContent(
                  provider: provider,
                  list: provider.listStkAdjustHistory,
                  type: "Adjustment",
                  onRefresh: () => provider.fetchStkAdjustHistory(
                    token: context.read<AuthProvider>().token!,
                  ),
                ),
                _buildTabContent(
                  provider: provider,
                  list: provider.listStkOpnameHistory,
                  type: "Opname",
                  onRefresh: () => provider.fetchStkOpnameHistory(
                    token: context.read<AuthProvider>().token!,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabContent({
    required HistoryGudangProvider provider,
    required List<dynamic> list,
    required String type,
    required Future<void> Function() onRefresh,
  }) {
    if (provider.isLoading && list.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && list.isEmpty) {
      return _buildErrorState(provider);
    }

    if (list.isEmpty) {
      return Center(
        child: Text(
          "Tidak ada riwayat $type",
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = list[index];
          String displayCode = "-";
          dynamic displayDate = "-";

          if (type == "Pengeluaran" || type == "Adjustment") {
            displayCode = item.code ?? "-";
            displayDate = item.date; 
          } else {
            displayCode = item.code ?? "-";
            displayDate = item.date != null
                ? DateFormat('dd MMMM yyyy').format(item.date!)
                : '-'; 
          }

          return _buildCardItem(
            code: displayCode,
            date: displayDate, 
            typeName: type,
            onTap: () => _navigateToDetail(context, type, item),
          );
        },
      ),
    );
  }

  Widget _buildCardItem({
    required String code,
    required dynamic date, 
    required String typeName,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap:
            onTap, 
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.inventory_2_outlined, color: Colors.blue),
        ),
        title: Text(code, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(formatTanggalIndo(date)),
            Text(
              typeName,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String type, dynamic item) {
    Widget? detailPage;

    switch (type) {
      case "Pengeluaran":
        detailPage = DetailPengeluaranBrgPage(id: item.id);
        break;
      case "Penerimaan":
        detailPage = DetailPenerimaanBarangPage(id: item.id);
        break;
      case "Adjustment":
        detailPage = DetailStckAdjustmentPage(adjustmentId: item.id);
        break;
      case "Opname":
        detailPage = DetailStockOpnamePage(
          opnameId: item.id,
          token: context.read<AuthProvider>().token!,
        );
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => detailPage!),
    );
    }

  Widget _buildErrorState(HistoryGudangProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(provider.errorMessage ?? "Terjadi kesalahan"),
          TextButton(onPressed: _fetchAllData, child: const Text("Coba Lagi")),
        ],
      ),
    );
  }
}
