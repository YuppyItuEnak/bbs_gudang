import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/pages/detail_penerimaan_barang_page.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/pages/tambah_penerimaan_barang_page.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/providers/penerimaan_barang_provider.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/widgets/penereimaan_barang_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PenerimaanBarangPage extends StatefulWidget {
  const PenerimaanBarangPage({super.key});

  @override
  State<PenerimaanBarangPage> createState() => _PenerimaanBarangPageState();
}

class _PenerimaanBarangPageState extends State<PenerimaanBarangPage> {
  final ScrollController _scrollController = ScrollController();
  String? _token;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Cek apakah widget masih ada di layar
      _init();
    });
    // Listener untuk infinite scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<PenerimaanBarangProvider>();

        if (_token != null && provider.hasMore && !provider.isLoading) {
          provider.fetchPenerimaanBarang(token: _token!, loadMore: true);
        }
      }
    });
  }

  Future<void> _init() async {
    final token = context.read<AuthProvider>().token;

    if (!mounted) return;

    setState(() {
      _token = token;
    });

    Provider.of<PenerimaanBarangProvider>(
      context,
      listen: false,
    ).fetchPenerimaanBarang(token: token!, isRefresh: true);
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
          "Penerimaan Barang",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PenerimaanBarangProvider>(
        builder: (context, provider, _) {
          // LOADING AWAL
          if (provider.isLoading && provider.listPenerimaanBarang.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null &&
              provider.listPenerimaanBarang.isEmpty) {
            return Center(child: Text(provider.errorMessage!));
          }

          // Ambil list yang sudah difilter
          final displayList = provider.filterPenerimaanBarang;

          return Column(
            children: [
              // 🔥 PINDAHKAN KE SINI dan masukkan argumen 'provider'
              _buildSearchBar(provider),

              Expanded(
                child: provider.listPenerimaanBarang.isEmpty
                    ? const Center(child: Text("Data penerimaan barang kosong"))
                    : RefreshIndicator(
                        onRefresh: () async {
                          await provider.fetchPenerimaanBarang(
                            token: _token!,
                            isRefresh: true,
                          );
                        },
                        child: displayList.isEmpty
                            ? const Center(
                                child: Text(
                                  "Data tidak ditemukan",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                itemCount:
                                    displayList.length +
                                    (provider.hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= displayList.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  final item = displayList[index];

                                  return PenerimaanBarangCard(
                                    data: {
                                      "po_no": item.code.toString(),
                                      "si_no": item.noSjSupplier ?? '-',
                                      "vendor": item.supplierName.toString(),
                                      "nopol": item.policeNumber ?? '-',
                                      "driver": item.driverName ?? '-',
                                      "date": item.date != null
                                          ? DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(item.date!)
                                          : '-',
                                      "status": item.status ?? 'Unknown',
                                    },
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              DetailPenerimaanBarangPage(
                                                id: item.id,
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                // Provider ini baru tercipta saat tombol diklik
                create: (_) => PenerimaanBarangProvider(),
                child: const TambahPenerimaanBarangPage(),
              ),
            ),
          );

          // 2. Jika result == true, berarti ada data baru yang berhasil di-submit
          if (result == true) {
            _refreshData();
          }
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Future<void> _refreshData() async {
    final provider = context.read<PenerimaanBarangProvider>();
    final token = context.read<AuthProvider>().token;

    if (token != null) {
      _showLoadingDialog(context);

      await provider.fetchPenerimaanBarang(token: token, isRefresh: true);

      if (mounted) {
        Navigator.pop(context);
        // Paksa ListView scroll ke paling atas agar data terbaru kelihatan
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.green)),
    );
  }

  Widget _buildSearchBar(PenerimaanBarangProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              onChanged: (value) {
                provider.searchPenerimaanBarang(value);
              },
              decoration: const InputDecoration(
                hintText: "Cari nomor Penerimaan Barang atau supplier...",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _statusChip(provider, null, 'Semua'),
              const SizedBox(width: 8),
              _statusChip(provider, 'Draft', 'Draft'),
              const SizedBox(width: 8),
              _statusChip(provider, 'Posted', 'Posted'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(
    PenerimaanBarangProvider provider,
    String? status,
    String label,
  ) {
    final isSelected = provider.selectedStatusFilter == status;
    return GestureDetector(
      onTap: () => provider.setStatusFilter(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
