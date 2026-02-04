import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/pages/detail_pengeluaran_brg_page.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/pages/tambah_pengeluaran_brg_page.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/widgets/pengeluaran_barang_card.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/providers/pengeluaran_barang_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PengeluaranBarangPage extends StatefulWidget {
  const PengeluaranBarangPage({super.key});

  @override
  State<PengeluaranBarangPage> createState() => _PengeluaranBarangPageState();
}

class _PengeluaranBarangPageState extends State<PengeluaranBarangPage> {
  @override
  void initState() {
    super.initState();

    // Delay sedikit supaya context aman
    Future.microtask(() {
      final provider = Provider.of<PengeluaranBarangProvider>(
        context,
        listen: false,
      );

      // GANTI DENGAN TOKEN ASLI DARI LOGIN / STORAGE
      final token = context.read<AuthProvider>().token;

      if (token != null) {
        provider.fetchListPengeluaranBrg(token: token);
      }
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
          "Pengeluaran Barang",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PengeluaranBarangProvider>(
        builder: (context, provider, _) {
          // 🔄 LOADING
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ ERROR
          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final token = context.read<AuthProvider>().token;
                        provider.fetchListPengeluaranBrg(token: token!);
                      },
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              ),
            );
          }

          // 📭 DATA KOSONG
          if (provider.listPengeluaranBarang.isEmpty) {
            return const Center(child: Text("Data pengeluaran barang kosong"));
          }

          // ✅ DATA ADA → TAMPILKAN LIST
          return Column(
            children: [
              // Search Bar
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
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: "Cari",
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
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

              // LIST DATA
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: provider.listPengeluaranBarang.length,
                  itemBuilder: (context, index) {
                    final item = provider.listPengeluaranBarang[index];

                    return PengeluaranBarangCard(
                      data: item, // 🔥 SEKARANG MODEL LANGSUNG
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailPengeluaranBrgPage(id: item.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
         final result = await  Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahPengeluaranBrgPage(),
            ),
          );

          if (result == true) {
            final token = context.read<AuthProvider>().token;
            if (token != null) {
              context.read<PengeluaranBarangProvider>().fetchListPengeluaranBrg(
                token: token,
              );
            }
          }
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
