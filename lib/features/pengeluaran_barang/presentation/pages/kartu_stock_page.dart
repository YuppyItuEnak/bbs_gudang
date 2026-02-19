import 'package:bbs_gudang/data/models/kartu_stock/kartu_stock_model.dart';
import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/pages/filter_kartu_stock.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/providers/kartu_stock_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KartuStockPage extends StatefulWidget {
  const KartuStockPage({super.key});

  @override
  State<KartuStockPage> createState() => _KartuStockPageState();
}

class _KartuStockPageState extends State<KartuStockPage> {
  final TextEditingController _searchController = TextEditingController();
  // Simpan range tanggal di state agar bisa dipanggil ulang saat refresh
  String _currentStartDate = "2026-01-31";
  String _currentEndDate = "2026-02-27";

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchData());
  }

  // Fungsi fetch data awal/default
  void _fetchData() {
    final auth = context.read<AuthProvider>();
    if (auth.token != null) {
      context.read<KartuStockProvider>().fetchRecapStock(
        token: auth.token!,
        startDate: _currentStartDate,
        endDate: _currentEndDate,
      );
    }
  }

  // Fungsi untuk memproses data dari halaman filter
  void _fetchDataFiltered(Map<String, dynamic> filters) {
    final auth = context.read<AuthProvider>();
    if (auth.token != null) {
      setState(() {
        _currentStartDate = filters['startDate'];
        _currentEndDate = filters['endDate'];
      });

      context.read<KartuStockProvider>().fetchRecapStock(
        token: auth.token!,
        startDate: _currentStartDate,
        endDate: _currentEndDate,
      );
    }
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
          "Rekap Stok",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<KartuStockProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildSearchBar(provider),
              _buildTotalWeightHeader(provider.totalWeight),
              Expanded(child: _buildBodyContent(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBodyContent(KartuStockProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // PENTING: Gunakan filteredKartuStock, bukan listKartuStock asli
    final dataList = provider.filteredKartuStock;

    if (dataList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "Data tidak ditemukan",
              style: TextStyle(color: Colors.grey),
            ),
            TextButton(
              onPressed: () {
                _searchController.clear();
                _fetchData();
              },
              child: const Text("Refresh"),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        final item = dataList[index];
        final bool isOut = (item.qtyOut ?? 0) > 0;

        return InkWell(
          onTap: () => _showDetailDialog(context, item),
          borderRadius: BorderRadius.circular(12),
          child: _buildStockCard(
            itemCode: item.itemCode ?? "-",
            itemName: item.itemName ?? "Tanpa Nama",
            weight:
                "${item.weightOut != "0" ? item.weightOut : item.weightIn} KG",
            transactionCode: item.transactionCode ?? "-",
            date: item.date ?? "-",
            isOut: isOut,
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(KartuStockProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                controller: _searchController,
                onChanged: (value) {
                  provider.searchKartuStock(value);
                },
                decoration: InputDecoration(
                  hintText: "Cari Kode atau Nama",
                  prefixIcon: const Icon(Icons.search, color: Colors.black87),
                  // Tambahkan tombol clear jika teks tidak kosong
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            provider.searchKartuStock("");
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FilterKartuStockPage(),
                ),
              );

              if (result != null && result is Map<String, dynamic>) {
                _fetchDataFiltered(result);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.tune, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalWeightHeader(double totalWeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Total Weight",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            Text(
              "${totalWeight.toStringAsFixed(0)} KG",
              style: const TextStyle(
                color: Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard({
    required String itemCode,
    required String itemName,
    required String weight,
    required String transactionCode,
    required String date,
    required bool isOut,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                itemCode,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Icon(
                isOut ? Icons.wifi_tethering_off : Icons.get_app,
                color: isOut ? Colors.red.shade400 : Colors.green.shade400,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            itemName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                weight,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text("|", style: TextStyle(color: Colors.grey)),
              ),
              Expanded(
                child: Text(
                  transactionCode,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              Text(
                date,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context, KartuStockModel item) {
    final bool isOut = (item.qtyOut ?? 0) > 0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isOut ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        isOut ? Icons.wifi_tethering_off : Icons.get_app,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item.date ?? "-",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "No. Reference",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            item.transactionCode ?? "-",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isOut ? "Qty Out" : "Qty In",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "${isOut ? item.weightOut : item.weightIn} KG",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  "Customer/Supplier/Other",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  item.customerSupplier ?? "N/A",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Balance",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      Text(
                        "${item.qtyBalance} KG",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
