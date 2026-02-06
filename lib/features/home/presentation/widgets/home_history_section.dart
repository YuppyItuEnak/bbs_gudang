import 'package:bbs_gudang/data/models/home/history_gudang_model.dart';
import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bbs_gudang/features/home/presentation/providers/history_gudang_provider.dart';

class HomeHistorySection extends StatelessWidget {
  final ScrollController scrollController;

  const HomeHistorySection({super.key, required this.scrollController});

  String formatTanggalIndo(String rawDate) {
    try {
      // Support beberapa format backend
      DateTime date;

      if (rawDate.contains('/')) {
        // contoh: 22/9/2025
        final parts = rawDate.split('/');
        date = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        // contoh: 2026-01-06 atau ISO
        date = DateTime.parse(rawDate);
      }

      final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      // fallback kalau parsing gagal
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
      child: Column(
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
                          // TODO: arahkan ke halaman full history
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // ================= LIST DATA FROM PROVIDER =================
          Expanded(
            child: Consumer<HistoryGudangProvider>(
              builder: (context, provider, _) {
                // --- LOADING ---
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // --- ERROR ---
                // --- ERROR ---
                if (provider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Gagal memuat histori (Error 500)",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Panggil kembali fungsi fetch dari provider
                            // Anda mungkin butuh token dari AuthProvider di sini
                            final token = context.read<AuthProvider>().token;
                            provider.fetchHistoryGudang(token: token!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            "Coba Lagi",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // --- EMPTY ---
                if (provider.listHistory.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada histori gudang",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // --- DATA LIST ---
                return ListView.builder(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: provider.listHistory.length,
                  itemBuilder: (context, index) {
                    final HistoryGudangModel item = provider.listHistory[index];

                    // Tentukan warna icon berdasarkan transaction type
                    Color iconColor;
                    if (item.transactionType.contains("PURCHASE")) {
                      iconColor = Colors.green;
                    } else if (item.transactionType.contains("SALES")) {
                      iconColor = Colors.redAccent;
                    } else {
                      iconColor = Colors.blue;
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: iconColor.withOpacity(0.1),
                        child: Icon(
                          Icons.assignment_outlined,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item.transactionCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        formatTanggalIndo(item.date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            ".",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // TODO: buka detail transaksi jika diperlukan
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
