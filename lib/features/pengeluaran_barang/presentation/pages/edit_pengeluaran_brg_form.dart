import 'package:bbs_gudang/features/pengeluaran_barang/presentation/widgets/tmbh_pengeluaran_input_field.dart';
import 'package:flutter/material.dart';

class EditPengeluaranBrgForm extends StatefulWidget {
  const EditPengeluaranBrgForm({super.key});

  @override
  State<EditPengeluaranBrgForm> createState() => _EditPengeluaranBrgFormState();
}

class _EditPengeluaranBrgFormState extends State<EditPengeluaranBrgForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
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
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Field Kode - Read Only
                  const TmbhPengeluaranInputField(
                    label: "Kode",
                    hint: "KODE0002",
                    enabled: false,
                    fillColor: Color(0xFFF3F6F9),
                  ),

                  // Field No. SO - Read Only
                  const TmbhPengeluaranInputField(
                    label: "No. SO",
                    hint: "SO-001",
                    enabled: false,
                    fillColor: Color(0xFFF3F6F9),
                  ),

                  // Field No. SQ - Read Only
                  const TmbhPengeluaranInputField(
                    label: "No. SQ",
                    hint: "SQ-001",
                    enabled: false,
                    fillColor: Color(0xFFF3F6F9),
                  ),

                  // Field Item - Read Only
                  const TmbhPengeluaranInputField(
                    label: "Item",
                    hint: "Barang A",
                    enabled: false,
                    fillColor: Color(0xFFF3F6F9),
                  ),

                  // Field Deskripsi - Read Only
                  const TmbhPengeluaranInputField(
                    label: "Deskripsi",
                    hint: "Lorem Ipsum",
                    enabled: false,
                    fillColor: Color(0xFFF3F6F9),
                  ),

                  // Row untuk Qty SO dan Satuan
                  _buildRowInput("Qty SO", "100", "PCS"),

                  // Row untuk Qty Dikirim (Editable)
                  _buildRowInput("Qty Dikirim", "80", "PCS", isReadOnly: false),

                  // Row untuk Sisa Qty SO
                  _buildRowInput("Sisa Qty SO", "20", "PCS"),

                  // Field Catatan Header
                  const TmbhPengeluaranInputField(
                    label: "Catatan Header",
                    hint: "Catatan",
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Tombol Simpan
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(
                    color: Colors.white,
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

  // Helper untuk membuat input baris (Field + Dropdown Satuan)
  Widget _buildRowInput(
    String label,
    String value,
    String unit, {
    bool isReadOnly = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        Row(
          children: [
            // Input Nilai
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isReadOnly ? const Color(0xFFF3F6F9) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Dropdown Satuan
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(unit, style: const TextStyle(fontSize: 14)),
                    const Icon(Icons.arrow_drop_down, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
