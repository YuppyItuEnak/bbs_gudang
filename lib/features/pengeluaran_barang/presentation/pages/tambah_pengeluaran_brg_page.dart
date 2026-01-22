import 'package:bbs_gudang/features/pengeluaran_barang/presentation/pages/edit_pengeluaran_brg_form.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/pages/tambah_item_pengeluaran_page.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/widgets/tmbh_pengeluaran_input_field.dart';
import 'package:flutter/material.dart';
import '../widgets/item_pengeluaran_tile.dart';

class TambahPengeluaranBrgPage extends StatefulWidget {
  const TambahPengeluaranBrgPage({super.key});

  @override
  State<TambahPengeluaranBrgPage> createState() =>
      _TambahPengeluaranBrgPageState();
}

class _TambahPengeluaranBrgPageState extends State<TambahPengeluaranBrgPage> {
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
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TmbhPengeluaranInputField(
                    label: "No. Pengeluaran Barang",
                    hint: "PBO-001",
                    enabled: false,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                  const TmbhPengeluaranInputField(
                    label: "Tanggal",
                    hint: "DD/MM/YYYY",
                    suffixIcon: Icons.calendar_today_outlined,
                  ),
                  const TmbhPengeluaranInputField(
                    label: "Tipe Barang",
                    hint: "Finish Good",
                    isDropdown: true,
                  ),
                  const TmbhPengeluaranInputField(
                    label: "Customer",
                    hint: "Customer A",
                    isDropdown: true,
                  ),
                  const TmbhPengeluaranInputField(
                    label: "Tgl Invoice",
                    hint: "DD/MM/YYYY",
                    suffixIcon: Icons.calendar_today_outlined,
                  ),
                  const TmbhPengeluaranInputField(
                    label: "No. Surat Jalan",
                    hint: "SJ-001",
                  ),
                  const TmbhPengeluaranInputField(
                    label: "No. Invoice",
                    hint: "SIC-001",
                  ),
                  const TmbhPengeluaranInputField(
                    label: "Nomor Polisi",
                    hint: "W 9028 Y",
                  ),
                  const TmbhPengeluaranInputField(
                    label: "Nama Supir",
                    hint: "Yatno",
                  ),
                  const TmbhPengeluaranInputField(
                    label: "Catatan Header",
                    hint: "Catatan",
                    maxLines: 3,
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Detail Pengeluaran Barang",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Item",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 10),

                  const ItemPengeluaranTile(
                    noSo: "SO-001",
                    namaBarang: "Barang A",
                    qty: "2 roll",
                    qtySo: "100",
                    qtyDikirim: "80",
                    sisa: "20",
                  ),
                  ItemPengeluaranTile(
                    noSo: "SO-002",
                    namaBarang: "Barang B",
                    qty: "2 roll",
                    qtySo: "100",
                    qtyDikirim: "20",
                    sisa: "80",
                    isSwiped: true,
                    onEditTap: () {
                      // Navigasi ke halaman edit
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditPengeluaranBrgForm(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TambahItemPengeluaranPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Add Item"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
