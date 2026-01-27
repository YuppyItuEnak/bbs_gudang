import 'package:bbs_gudang/data/models/pengeluaran_barang/pengeluaran_barang_model.dart';
import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/providers/pengeluaran_barang_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailPengeluaranBrgPage extends StatefulWidget {
  final String id; // 🔥 id surat jalan

  const DetailPengeluaranBrgPage({super.key, required this.id});

  @override
  State<DetailPengeluaranBrgPage> createState() =>
      _DetailPengeluaranBrgPageState();
}

class _DetailPengeluaranBrgPageState extends State<DetailPengeluaranBrgPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final provider = Provider.of<PengeluaranBarangProvider>(
        context,
        listen: false,
      );

      final token = context.read<AuthProvider>().token; // ganti token asli
      if (token != null) {
        provider.fetchDetailPengeluaranBrg(token: token, id: widget.id);
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
          "Pengeluaran Barang Detail",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
                child: Text(
                  provider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final model = provider.detailPengeluaranBarang;

          if (model == null) {
            return const Center(child: Text("Data detail tidak ditemukan"));
          }

          // ✅ DATA ADA
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      _buildHeaderGrid(model),

                      const SizedBox(height: 20),
                      const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 15),

                      const Text(
                        "Detail Pengeluaran Barang",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // 🔥 LIST DETAIL DARI API
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: model.pengeluaranBrgDetail.length,
                        itemBuilder: (context, index) {
                          final item = model.pengeluaranBrgDetail[index];

                          return _buildDetailItemCard(
                            noSo: model.salesOrder?.code ?? "-",
                            noSq: model.code,
                            namaBarang: item.item?.name ?? "-",
                            qty: "${item.qty} ${item.uomUnit}",
                            qtySo: item.qtySnapshot.toString(),
                            qtyDiterima: item.qty.toString(),
                            sisa: (item.qtySnapshot - item.qty).toString(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // BUTTON BAWAH
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Kembali",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderGrid(PengeluaranBarangModel model) {
  return GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    childAspectRatio: 2.5,
    children: [
      _buildInfoTile("No. Pengeluaran", model.code),
      _buildInfoTile("Tanggal", model.date),
      _buildInfoTile("Customer", model.customerModel?.name ?? "-"),
      _buildInfoTile("Ship To", model.shipTo),
      _buildInfoTile("Status", model.status.toString()),
      _buildInfoTile("Unit Bisnis", model.unitBussinessModel?.name ?? "-"),
      _buildInfoTile("SO", model.salesOrder?.code ?? "-"),
      _buildInfoTile("NPWP", model.npwp),
      _buildInfoTile("Diambil", model.isTaken ? "Ya" : "Belum"),
      _buildInfoTile("Catatan", model.notes ?? "-"),
    ],
  );
}


  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItemCard({
    required String noSo,
    required String noSq,
    required String namaBarang,
    required String qty,
    required String qtySo,
    required String qtyDiterima,
    required String sisa,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                noSo,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                noSq,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                namaBarang,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                qty,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Qty SO : $qtySo",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                "Qty Diterima : $qtyDiterima",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "Sisa Qty SO : $sisa",
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Deskripsi : Lorem Ipsum",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const Text(
            "Catatan : -",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
