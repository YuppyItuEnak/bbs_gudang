import 'package:bbs_gudang/data/models/home/history_gudang_model.dart';
import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/home/presentation/pages/history_gudang_page.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/pages/detail_penerimaan_barang_page.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/pages/detail_pengeluaran_brg_page.dart';
import 'package:bbs_gudang/features/stock_adjustment/presentation/pages/detail_stck_adjustment_page.dart';
import 'package:bbs_gudang/features/stock_opname/presentation/pages/detail_stock_opname_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bbs_gudang/features/home/presentation/providers/history_gudang_provider.dart';

class HomeHistorySection extends StatelessWidget {
  final ScrollController scrollController;

  const HomeHistorySection({super.key, required this.scrollController});

  String formatTanggalIndo(String rawDate) {
    try {
      DateTime date;
      if (rawDate.contains('/')) {
        final parts = rawDate.split('/');
        date = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        date = DateTime.parse(rawDate);
      }
      final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
        ],
      ),
      // 🔥 Consumer diletakkan di sini agar SearchBar & List bisa akses 'provider'
      child: Consumer<HistoryGudangProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // ================= HEADER + HANDLE =================
              SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Histori Gudang",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HistoryGudangPage(),
                                ),
                              );
                            },
                            child: Text(
                              "Lihat Semua",
                              style: TextStyle(
                                color: Colors.blue[400],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ================= SEARCH BAR =================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          // Sekarang 'provider' sudah terdefinisi
                          onChanged: (value) {
                            provider.searchHistoryGudang(value);
                          },
                          decoration: const InputDecoration(
                            hintText: "Cari nomor transaksi...",
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(Icons.tune, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),

              
              Expanded(child: _buildListContent(context, provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListContent(
    BuildContext context,
    HistoryGudangProvider provider,
  ) {
    // 1. Ambil list gabungan (Inilah kunci menampilkan semua data fetching)
    final displayList = provider.filteredTransactions;

    // 2. Loading State (Jika salah satu fetch sedang jalan dan list masih kosong)
    if (provider.isLoading && displayList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 3. Empty State
    if (displayList.isEmpty) {
      return const Center(
        child: Text(
          "Tidak ada histori transaksi",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // 4. Render List Gabungan
    return ListView.builder(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final dynamic item = displayList[index];

        // LOGIKA PENENTUAN ICON & WARNA BERDASARKAN TIPE MODEL
        Color iconColor = Colors.blue;
        String typeLabel = "";

        // Deteksi runtimeType untuk membedakan kategori di UI
        final String modelType = item.runtimeType.toString();

        if (modelType.contains('Penerimaan')) {
          iconColor = Colors.green;
          typeLabel = "Penerimaan";
        } else if (modelType.contains('Pengeluaran')) {
          iconColor = Colors.redAccent;
          typeLabel = "Pengeluaran";
        } else if (modelType.contains('Adjust')) {
          iconColor = Colors.orange;
          typeLabel = "Adjustment";
        } else if (modelType.contains('Opname')) {
          iconColor = Colors.purple;
          typeLabel = "Opname";
        }

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(Icons.assignment_outlined, color: iconColor, size: 20),
          ),
          title: Text(
            item.code ?? "-", // Mengakses .code dari dynamic model
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formatTanggalIndo(item.date.toString())),
              Text(
                typeLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          trailing: const Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.grey,
          ),
          onTap: () => _navigateToDetail(context, typeLabel, item),
        );
      },
    );
  }

  void _navigateToDetail(BuildContext context, String type, dynamic item) {
    Widget? detailPage;

    switch (type) {
      case "Pengeluaran":
        detailPage = DetailPengeluaranBrgPage(id: item.id);
        break; // Menghentikan switch, lalu lanjut ke baris Navigator
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
        return; // Tetap pakai return di sini jika tipe tidak dikenal (aman)
    }

    // Sekarang baris ini bisa dijangkau (Reachable)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => detailPage!),
    );
    }
}
