import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/pages/detail_transfer_warehouse_page.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/pages/tambah_transfer_page.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/providers/transfer_warehouse_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransferWarehousePage extends StatefulWidget {
  const TransferWarehousePage({super.key});

  @override
  State<TransferWarehousePage> createState() => _TransferWarehousePageState();
}

class _TransferWarehousePageState extends State<TransferWarehousePage> {
  @override
  void initState() {
    super.initState();

    // Panggil API setelah widget siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TransferWarehouseProvider>(
        context,
        listen: false,
      );

      final token = context.read<AuthProvider>().token;
      if (token != null) {
        provider.fetchListTransferWarehouse(token: token, refresh: true);
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Transfer Warehouse",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- SEARCH BAR SECTION ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      // Hapus 'const' karena kita akan menambahkan properti
                      onChanged: (value) {
                        // Panggil fungsi search dari provider
                        context
                            .read<TransferWarehouseProvider>()
                            .searchTransferWarehouse(value);
                      },
                      decoration: const InputDecoration(
                        hintText: "Cari nomor transfer atau gudang...",
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
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune, color: Colors.black87),
                ),
              ],
            ),
          ),

          // --- LIST SECTION (FROM PROVIDER) ---
          Expanded(
            child: Consumer<TransferWarehouseProvider>(
              builder: (context, provider, _) {
                // Loading State
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Empty State
                if (provider.listTransferWarehouse.isEmpty) {
                  return const Center(
                    child: Text("Data transfer warehouse kosong"),
                  );
                }

                // Data State
                final data = provider.filteredTransferWarehouse;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // DATE HEADER
                        Text(
                          _formatDate(item.date),
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 10),

                        _buildTransferCard(
                          item.sourceWarehouse.name,
                          item.destinationWarehouse.name,
                          item.status,
                          () {
                            final token = context.read<AuthProvider>().token;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailTransferWarehousePage(
                                  id: item.id, // ← ID transfer warehouse
                                  token: token!, // ← token login
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahTransferPage()),
          );

          if (result == true) {
            final token = context.read<AuthProvider>().token;
            context
                .read<TransferWarehouseProvider>()
                .fetchListTransferWarehouse(token: token!, refresh: true);
          }
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  // -----------------------------
  // FORMAT DATE
  // -----------------------------
  String _formatDate(DateTime date) {
    // Contoh output: 24 Januari 2026
    return "${date.day} ${_monthName(date.month)} ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    return months[month - 1];
  }

  // -----------------------------
  // CARD UI (TIDAK BERUBAH)
  // -----------------------------
  Widget _buildTransferCard(
    String from,
    String to,
    String status,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // -------------------
            // HEADER ROW (STATUS)
            // -------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transfer",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),

                // STATUS BADGE
                _buildStatusBadge(status),
              ],
            ),

            const SizedBox(height: 12),

            // -------------------
            // MAIN CONTENT
            // -------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Gudang Awal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle, color: Colors.red, size: 10),
                          const SizedBox(width: 5),
                          Text(
                            "Gudang Awal",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        from,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider Dots
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      ...List.generate(3, (index) => _buildDot()),
                      Icon(Icons.circle, size: 8, color: Colors.blue[600]),
                      ...List.generate(3, (index) => _buildDot()),
                    ],
                  ),
                ),

                // Gudang Tujuan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Gudang Tujuan",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 10,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        to,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor = Colors.white;

    switch (status.toUpperCase()) {
      case "DRAFT":
        bgColor = Colors.grey;
        break;
      case "POSTED":
        bgColor = Colors.green;
        break;
      case "SUBMITTED":
        bgColor = Colors.blue;
        break;
      case "REJECTED":
        bgColor = Colors.red;
        break;
      default:
        bgColor = Colors.black54;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: bgColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: Colors.blue[200],
        shape: BoxShape.circle,
      ),
    );
  }
}
