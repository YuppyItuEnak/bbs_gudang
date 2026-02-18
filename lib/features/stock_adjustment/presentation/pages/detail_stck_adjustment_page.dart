import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/stock_adjustment/presentation/pages/edit_stck_adjust_page.dart';
import 'package:bbs_gudang/features/stock_adjustment/presentation/providers/stock_adjustment_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// Pastikan import provider dan model Anda di sini
// import 'package:your_project/providers/adjustment_provider.dart';

class DetailStckAdjustmentPage extends StatefulWidget {
  final String adjustmentId; // Tambahkan parameter ID

  const DetailStckAdjustmentPage({super.key, required this.adjustmentId});

  @override
  State<DetailStckAdjustmentPage> createState() =>
      _DetailStckAdjustmentPageState();
}

class _DetailStckAdjustmentPageState extends State<DetailStckAdjustmentPage> {
  @override
  void initState() {
    super.initState();
    // Panggil API saat halaman dibuka
    Future.microtask(() {
      final token = context.read<AuthProvider>().token;
      context.read<StockAdjustmentProvider>().fetchDetailAdjustment(
        token: token!, // Ambil dari AuthProvider atau Session
        id: widget.adjustmentId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Stock Adjustment",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<StockAdjustmentProvider>(
        builder: (context, provider, child) {
          // 1. Handle Loading
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 3. Handle Empty Data
          final data = provider.detailData;
          if (data == null) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Section Header Info ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHeaderIconText(
                            Icons.calendar_today_outlined,
                            // Format tanggal jika perlu (data.date)
                            DateFormat(
                              "dd/MM/yyyy",
                            ).format(DateTime.parse(data.date)),
                          ),
                          _buildStatusBadge(data.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildHeaderIconText(
                        Icons.description_outlined,
                        data.code,
                      ),
                      const SizedBox(height: 12),
                      _buildHeaderIconText(
                        Icons.warehouse_outlined,
                        data.warehouse?.name ?? "-",
                      ),
                      const SizedBox(height: 12),
                      _buildHeaderIconText(
                        Icons.edit_outlined,
                        data.notes ?? "Tidak ada catatan",
                      ),

                      const SizedBox(height: 30),

                      // --- Section Title ---
                      const Text(
                        "Item Terpilih",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // --- List of Items ---
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.details.length,
                        itemBuilder: (context, index) {
                          final itemDetail = data.details[index];
                          return _buildAdjustmentItemCard(itemDetail);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // --- Bottom Button ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 🔥 BUTTON EDIT — HANYA JIKA DRAFT
                    if (data.status == "DRAFT")
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Navigasi ke halaman edit
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditStkAdjustPage(id: data.id),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Edit Stock Adjustment",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                    if (data.status == "DRAFT") const SizedBox(height: 12),

                    // 🔙 BUTTON KEMBALI — SELALU ADA
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF4CAF50)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Kembali",
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderIconText(IconData icon, String text) {
    return Row(
      // Tambahkan mainAxisSize agar Row tidak mengambil ruang tak terhingga
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade300),
        const SizedBox(width: 12),
        // Gunakan Expanded namun pastikan Row memiliki konteks lebar
        // Atau paling aman untuk Header, gunakan Text biasa jika tidak dalam Row yang sangat penuh
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status == "APPROVED" ? Colors.green : const Color(0xFFFFC107),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Parameter diubah dari Map ke Model AdjustmentDetail
  Widget _buildAdjustmentItemCard(dynamic detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.item?.name ?? detail.itemCode,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail.itemCode,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // Badge Adjustment (+/-)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: detail.adjustment >= 0
                  ? const Color(0xFFE8F5E9)
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "${detail.adjustment >= 0 ? '+' : ''}${detail.adjustment}",
              style: TextStyle(
                color: detail.adjustment >= 0
                    ? const Color(0xFF4CAF50)
                    : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Total Setelah Adjustment
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "${detail.qtyAfter} UNIT", // Sesuaikan satuan jika ada di model
              style: const TextStyle(
                color: Color(0xFF5C6BC0),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
