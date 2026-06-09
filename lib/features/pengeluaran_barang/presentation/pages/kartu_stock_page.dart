import 'package:bbs_gudang/data/models/kartu_stock/stock_warehouse_model.dart';
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
  List<String> _currentWarehouseIds = [];
  List<String> _currentWarehouseNames = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchWarehouses());
  }

  void _fetchWarehouses() {
    final auth = context.read<AuthProvider>();
    if (auth.token != null) {
      context.read<KartuStockProvider>().fetchWarehouses(token: auth.token!);
    }
  }

  // Hitung periode bulan berjalan secara otomatis
  String get _startDate {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-01";
  }

  String get _endDate {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  void _fetchData() {
    final auth = context.read<AuthProvider>();
    if (auth.token != null && _currentWarehouseIds.isNotEmpty) {
      context.read<KartuStockProvider>().fetchStockWarehouseReport(
        token: auth.token!,
        startDate: _startDate,
        endDate: _endDate,
        warehouseIds: _currentWarehouseIds,
      );
    }
  }

  void _fetchDataFiltered(Map<String, dynamic> filters) {
    final auth = context.read<AuthProvider>();
    if (auth.token != null) {
      final ids = List<String>.from(filters['warehouseIds'] ?? []);
      final provider = context.read<KartuStockProvider>();
      setState(() {
        _currentWarehouseIds = ids;
        _currentWarehouseNames = ids.map((id) {
          return provider.warehouses
                  .where((w) => w.id == id)
                  .firstOrNull
                  ?.name ??
              id;
        }).toList();
      });

      provider.fetchStockWarehouseReport(
        token: auth.token!,
        startDate: _startDate,
        endDate: _endDate,
        warehouseIds: ids,
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
              if (_currentWarehouseIds.isNotEmpty)
                _buildActiveFilterChips(provider),
              Expanded(child: _buildBodyContent(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveFilterChips(KartuStockProvider provider) {
    final warehouseNames = _currentWarehouseNames;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: warehouseNames.length,
          separatorBuilder: (context, index) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                warehouseNames[index],
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBodyContent(KartuStockProvider provider) {
    if (_currentWarehouseIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warehouse_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "Pilih warehouse terlebih dahulu",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 8),
            const Text(
              "Gunakan tombol filter untuk memilih\nwarehouse dan periode",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final dataList = provider.filteredStockWarehouse;

    if (dataList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
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
        return _buildStockCard(item);
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
                  provider.searchStockWarehouse(value);
                },
                decoration: InputDecoration(
                  hintText: "Cari Kode, Nama, atau Warehouse",
                  prefixIcon: const Icon(Icons.search, color: Colors.black87),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            provider.searchStockWarehouse("");
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
                  builder: (context) => FilterKartuStockPage(
                    warehouses: provider.warehouses,
                  ),
                ),
              );

              if (result != null && result is Map<String, dynamic>) {
                _fetchDataFiltered(result);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _currentWarehouseIds.isNotEmpty
                    ? Colors.green.shade50
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _currentWarehouseIds.isNotEmpty
                      ? Colors.green.shade300
                      : Colors.grey.shade200,
                ),
              ),
              child: Icon(
                Icons.tune,
                color: _currentWarehouseIds.isNotEmpty
                    ? Colors.green
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(StockWarehouseModel item) {
    final qty = item.netQty ?? 0;
    final qtyColor = qty > 0 ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.07),
            spreadRadius: 2,
            blurRadius: 6,
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
                item.itemCode ?? "-",
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.warehouse_outlined,
                    size: 13,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.warehouseName ?? "-",
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.itemName ?? "Tanpa Nama",
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Satuan: ${item.uom ?? '-'}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: qtyColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Stok: $qty",
                  style: TextStyle(
                    color: qtyColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
