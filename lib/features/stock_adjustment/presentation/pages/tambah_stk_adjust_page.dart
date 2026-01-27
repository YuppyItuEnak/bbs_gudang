import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/list_item/presentation/pages/tambah_item_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Pastikan path import ini benar sesuai struktur project Anda
// import 'package:bbs_gudang/features/transfer_warehouse/presentation/pages/tambah_item_page.dart';

class TambahStkAdjustPage extends StatefulWidget {
  const TambahStkAdjustPage({super.key});

  @override
  State<TambahStkAdjustPage> createState() => _TambahStkAdjustPageState();
}

class _TambahStkAdjustPageState extends State<TambahStkAdjustPage> {
  String? selectedGudang;
  final TextEditingController _referensiController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  // List untuk menampung item yang sudah dipilih
  List<Map<String, dynamic>> selectedItems = [];

  // Fungsi navigasi ke pilih item (Logika sama dengan Stock Opname)
  // Fungsi untuk navigasi ke halaman pilih item
  void _navigateToSelectItem() async {
    // 1. Berpindah ke halaman List Item dan menunggu hasil (result)
    // Pastikan class 'TambahItem' sudah di-import di bagian atas
    final token = context.read<AuthProvider>().token;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  TambahItem(token: token!,)),
    );

    // 2. Logika setelah kembali dari halaman TambahItem
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        // Cek apakah item sudah ada di list berdasarkan kode barang
        int existingIndex = selectedItems.indexWhere(
          (item) => item['kode'] == result['kode'],
        );

        if (existingIndex != -1) {
          // Jika sudah ada, cukup tambahkan quantity-nya
          selectedItems[existingIndex]['qty'] += (result['qty'] ?? 1);
        } else {
          // Jika belum ada, masukkan sebagai item baru
          // Pastikan data result memiliki key: nama, kode, dan qty
          selectedItems.add({
            "nama": result['nama'],
            "kode": result['kode'],
            "qty": result['qty'] ?? 1,
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Stock Adjustment",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
                  _buildHeaderInfo(),
                  const SizedBox(height: 20),

                  // Field Gudang
                  const Text(
                    "Gudang",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  _buildGudangSelector(),
                  const SizedBox(height: 15),

                  // Field Referensi (Sesuai gambar image_80d7ac.png)
                  const Text(
                    "Referensi",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  _buildReferensiInput(),
                  const SizedBox(height: 15),

                  // Field Catatan
                  _buildCatatanInput(),
                  const SizedBox(height: 25),

                  // LOGIKA DINAMIS:
                  if (selectedItems.isEmpty)
                    _buildInitialAddButton() // Tampilan awal (Kosong)
                  else
                    _buildItemListSection(), // Tampilan setelah ada item
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildHeaderInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18, color: Colors.blue),
            SizedBox(width: 10),
            Text("06 Desember 2025"),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F3FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "Draft",
            style: TextStyle(
              color: Color(0xFF5C6BC0),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGudangSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGudang,
          hint: const Text("Pilih Gudang"),
          isExpanded: true,
          items: [
            "Gudang Utama",
            "Gudang B",
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => selectedGudang = val),
        ),
      ),
    );
  }

  Widget _buildReferensiInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _referensiController,
        decoration: const InputDecoration(
          hintText: "Tuliskan nomer referensi",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCatatanInput() {
    return Row(
      children: [
        const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _catatanController,
            decoration: const InputDecoration(
              hintText: "Catatan",
              hintStyle: TextStyle(color: Colors.black54),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialAddButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _navigateToSelectItem,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF4CAF50)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          "+ Add Item",
          style: TextStyle(
            color: Color(0xFF4CAF50),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildItemListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Item Terpilih",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            GestureDetector(
              onTap: _navigateToSelectItem,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      "Add Item",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: selectedItems.length,
          itemBuilder: (context, index) {
            final item = selectedItems[index];
            return _buildItemCard(item, index);
          },
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['nama'],
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          setState(() => selectedItems.removeAt(index)),
                      child: const Text(
                        "Hapus",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Text(
                  item['kode'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Text("PCS", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(width: 8),
          _buildQtyControl(index),
        ],
      ),
    );
  }

  Widget _buildQtyControl(int index) {
    return Row(
      children: [
        _qtyBtn(Icons.remove, () {
          if (selectedItems[index]['qty'] > 1) {
            setState(() => selectedItems[index]['qty']--);
          }
        }),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "${selectedItems[index]['qty']}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        _qtyBtn(Icons.add, () {
          setState(() => selectedItems[index]['qty']++);
        }),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          selectedItems.isEmpty ? "Lanjut" : "Simpan",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
