import 'package:bbs_gudang/features/transfer_warehouse/presentation/pages/list_item_terpilih_page.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/pages/tambah_item_page.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/widgets/detail_item_terpilih.dart';
import 'package:flutter/material.dart';

class TambahTransferPage extends StatefulWidget {
  const TambahTransferPage({super.key});

  @override
  State<TambahTransferPage> createState() => _TambahTransferPageState();
}

class _TambahTransferPageState extends State<TambahTransferPage> {
  // Variabel untuk menyimpan nilai input
  String? selectedGudangAwal;
  String? selectedGudangTujuan;
  final TextEditingController _catatanController = TextEditingController();

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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER DATE & STATUS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "02 Agustus 2025",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Draft",
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // --- INPUT GUDANG AWAL ---
                  _buildLabel("Gudang Awal"),
                  _buildDropdownField(
                    hint: "Pilih Gudang Awal",
                    value: selectedGudangAwal,
                    items: ["Gudang Utama", "Gudang Pembantu"],
                    onChanged: (val) =>
                        setState(() => selectedGudangAwal = val),
                  ),
                  const SizedBox(height: 20),

                  // --- INPUT GUDANG TUJUAN ---
                  _buildLabel("Gudang Tujuan"),
                  _buildDropdownField(
                    hint: "Pilih Gudang Tujuan",
                    value: selectedGudangTujuan,
                    items: ["Gudang Retur", "Gudang Konsinyasi"],
                    onChanged: (val) =>
                        setState(() => selectedGudangTujuan = val),
                  ),
                  const SizedBox(height: 20),

                  // --- INPUT CATATAN ---
                  _buildLabel("Catatan Header"),
                  TextField(
                    controller: _catatanController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Catatan",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- WIDGET DETAIL ITEM TERPILIH ---
                  DetailItemTerpilih(
                    count: 2, // Angka ini bisa dinamis dari variabel state
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ListItemTerpilihPage()));
                    },
                  ),
                  const SizedBox(height: 25),

                  // --- BUTTON ADD ITEM ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder:  (_) => const TambahItem()));
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "+ Add Item",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- BOTTOM BUTTON ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Aksi lanjut
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Lanjut",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Widget Helper untuk Dropdown Kustom
  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey[400])),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
          items: items.map((String item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
