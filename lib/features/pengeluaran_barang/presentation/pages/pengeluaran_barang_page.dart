import 'package:bbs_gudang/features/pengeluaran_barang/presentation/pages/detail_pengeluaran_brg_page.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/pages/tambah_pengeluaran_brg_page.dart';
import 'package:flutter/material.dart';
import '../widgets/pengeluaran_barang_card.dart';

class PengeluaranBarangPage extends StatefulWidget {
  const PengeluaranBarangPage({super.key});

  @override
  State<PengeluaranBarangPage> createState() => _PengeluaranBarangPageState();
}

class _PengeluaranBarangPageState extends State<PengeluaranBarangPage> {
  // Data dummy sesuai gambar
  final List<Map<String, String>> listPengeluaran = [
    {
      "id": "PB-001",
      "customer": "Customer A",
      "nopol": "W 9028 Y",
      "date": "06 Desember 2024",
      "sic_no": "SIC-001",
      "driver": "Yanto",
    },
    {
      "id": "PB-002",
      "customer": "Customer B",
      "nopol": "W 9028 Y",
      "date": "06 Desember 2024",
      "sic_no": "SIC-002",
      "driver": "Yanto",
    },
    {
      "id": "PB-003",
      "customer": "Customer C",
      "nopol": "W 9028 Y",
      "date": "06 Desember 2024",
      "sic_no": "SIC-003",
      "driver": "Yanto",
    },
    {
      "id": "PB-004",
      "customer": "Customer D",
      "nopol": "W 9028 Y",
      "date": "06 Desember 2024",
      "sic_no": "SIC-004",
      "driver": "Yanto",
    },
    {
      "id": "PB-005",
      "customer": "Customer E",
      "nopol": "W 9028 Y",
      "date": "06 Desember 2024",
      "sic_no": "SIC-005",
      "driver": "Yanto",
    },
  ];

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
      body: Column(
        children: [
          // Search Bar Section
          Padding(
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

          // List Content
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: listPengeluaran.length,
              itemBuilder: (context, index) {
                return PengeluaranBarangCard(
                  data: listPengeluaran[index],
                  onTap: () {
                    // Navigasi ke detail
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => const DetailPengeluaranBrgPage(),
                    ));
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahPengeluaranBrgPage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
