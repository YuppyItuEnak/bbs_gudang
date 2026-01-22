import 'package:bbs_gudang/features/penerimaan_barang/presentation/pages/detail_penerimaan_barang_page.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/pages/tambah_penerimaan_barang_page.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/widgets/penereimaan_barang_card.dart';
import 'package:flutter/material.dart';

class PenerimaanBarangPage extends StatefulWidget {
  const PenerimaanBarangPage({super.key});

  @override
  State<PenerimaanBarangPage> createState() => _PenerimaanBarangPageState();
}

class _PenerimaanBarangPageState extends State<PenerimaanBarangPage> {
  final List<Map<String, String>> penerimaanData = [
    {
      "po_no": "PB-2501-0003",
      "si_no": "SI-2501-0003",
      "vendor": "PT. Ekaprima",
      "nopol": "W 8190 LO",
      "driver": "Dwi",
      "date": "08/12/2025",
    },
    {
      "po_no": "PB-2501-0002",
      "si_no": "SI-2501-0002",
      "vendor": "PT. Abadi Jaya",
      "nopol": "W 0910 HI",
      "driver": "Eka",
      "date": "07/12/2025",
    },
    {
      "po_no": "PB-2501-0001",
      "si_no": "SI-2501-0001",
      "vendor": "PT. Jaya Abadi Sentosa",
      "nopol": "W 9028 YA",
      "driver": "Adi",
      "date": "06/12/2025",
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
          "Penerimaan Barang",
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
          _buildSearchBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: penerimaanData.length,
              itemBuilder: (context, index) {
                // Menggunakan widget yang sudah dipisah
                return PenerimaanBarangCard(
                  data: penerimaanData[index],
                  onTap: () {
                    // Logika navigasi ke detail jika ada
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPenerimaanBarangPage()));
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahPenerimaanBarangPage()));
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
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
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Icon(Icons.tune, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
