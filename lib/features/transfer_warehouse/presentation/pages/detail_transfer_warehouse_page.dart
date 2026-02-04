import 'package:bbs_gudang/data/models/transfer_warehouse/transfer_warehouse_detail.dart';
import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/pages/edit_transfer_warehouse.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/providers/transfer_warehouse_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailTransferWarehousePage extends StatefulWidget {
  final String id;
  final String token;

  const DetailTransferWarehousePage({
    super.key,
    required this.id,
    required this.token,
  });

  @override
  State<DetailTransferWarehousePage> createState() =>
      _DetailTransferWarehousePageState();
}

class _DetailTransferWarehousePageState
    extends State<DetailTransferWarehousePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<TransferWarehouseProvider>().fetchDetailTransferWarehouse(
        token: widget.token,
        id: widget.id,
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
          "Transfer Warehouse Detail",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<TransferWarehouseProvider>(
        builder: (context, provider, _) {
          // 🔄 LOADING
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final header = provider.detailTransferWarehouse!;

          // ❌ ERROR
          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final data = provider.detailTransferWarehouse;

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
                      // --- HEADER: DATE & STATUS ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: Colors.grey[400],
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(data.date),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          _buildStatusBadge(data.status),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // --- TRANS TRANSACTION NUMBER ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "No. Transfer Warehouse",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            data.code,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // --- WAREHOUSE PATH CARD ---
                      _buildWarehousePathCard(
                        data.sourceWarehouse.name,
                        data.destinationWarehouse.name,
                      ),
                      const SizedBox(height: 20),

                      // --- NOTES ---
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note,
                            color: Colors.grey[400],
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Catatan",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data.notes ?? "-",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 25),

                      // --- ITEM LIST SECTION ---
                      const Text(
                        "Item Terpilih",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.details.length,
                        itemBuilder: (context, index) {
                          final item = data.details[index];
                          return _buildItemDetailCard(item);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // --- BOTTOM BUTTON ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    /// ✏️ EDIT — HANYA JIKA DRAFT
                    if (header.status == "DRAFT")
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // TODO: arahkan ke halaman edit PB
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditTransferWarehousePage(
                                  transferId: header.id!,
                                ),
                              ),
                            );

                            // Jika result adalah true, artinya ada perubahan data (submit berhasil)
                            if (result == true) {
                              if (mounted) {
                                final auth = context.read<AuthProvider>();
                                final provider = context
                                    .read<TransferWarehouseProvider>();

                                // 🔥 KUNCI: Refresh Detail agar UI di halaman ini langsung berubah
                                await provider.fetchDetailTransferWarehouse(
                                  token: auth.token!,
                                  id: widget.id,
                                );

                                // Refresh juga list di halaman utama (opsional tapi disarankan)
                                provider.fetchListTransferWarehouse(
                                  token: auth.token!,
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Edit",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                    if (header.status == "DRAFT") const SizedBox(width: 12),

                    /// 🔙 KEMBALI — SELALU ADA
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF4CAF50)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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

  // ================= HELPER UI =================

  Widget _buildStatusBadge(String status) {
    Color color;

    switch (status.toLowerCase()) {
      case 'posted':
        color = const Color(0xFFFFB300);
        break;
      case 'draft':
        color = Colors.grey;
        break;
      case 'approved':
        color = Colors.green;
        break;
      default:
        color = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWarehousePathCard(String source, String destination) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FDF3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildWarehouseLabel("Gudang Awal", source, Colors.red),
          _buildPathDivider(),
          _buildWarehouseLabel("Gudang Tujuan", destination, Colors.green),
        ],
      ),
    );
  }

  Widget _buildWarehouseLabel(String label, String name, Color dotColor) {
    return Column(
      crossAxisAlignment: (dotColor == Colors.red)
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor == Colors.red)
              Icon(Icons.circle, size: 8, color: dotColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                label,
                style: const TextStyle(color: Colors.green, fontSize: 12),
              ),
            ),
            if (dotColor == Colors.green)
              Icon(Icons.circle, size: 8, color: dotColor),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 120, // batas lebar supaya tidak nabrak divider
          child: Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: (dotColor == Colors.red)
                ? TextAlign.left
                : TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPathDivider() {
    return Row(
      children: [
        Text("· · · ", style: TextStyle(color: Colors.blue[300])),
        Icon(Icons.circle, size: 10, color: Colors.blue[600]),
        Text(" · · ·", style: TextStyle(color: Colors.blue[300])),
      ],
    );
  }

  Widget _buildItemDetailCard(TransferWarehouseDetail item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // KIRI
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.itemCode,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // KANAN (QTY)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FDF3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "${item.qty} ${item.uom}",
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} "
        "${_monthName(date.month)} "
        "${date.year}";
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
}
