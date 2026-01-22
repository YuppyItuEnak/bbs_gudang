import 'package:bbs_gudang/features/penerimaan_barang/presentation/widgets/info_penerimaan_barnag.dart';
import 'package:flutter/material.dart';
import '../widgets/item_penerimaan_barang.dart';

class TambahPenerimaanBarangPage extends StatefulWidget {
  const TambahPenerimaanBarangPage({super.key});

  @override
  State<TambahPenerimaanBarangPage> createState() => _TambahPenerimaanBarangPageState();
}

class _TambahPenerimaanBarangPageState extends State<TambahPenerimaanBarangPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: "Info"),
              Tab(text: "Item"),
            ],
          ),
        ),
        body:  Stack(
          children: [
            TabBarView(
              children: [
                InfoPenerimaanBarang(), // Widget dari file terpisah
                ItemPenerimaanBarang(), // Widget dari file terpisah
              ],
            ),
            
            // Floating Simpan Button di bagian bawah
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: null, // Ganti dengan fungsi simpan
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.green.withOpacity(0.7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}