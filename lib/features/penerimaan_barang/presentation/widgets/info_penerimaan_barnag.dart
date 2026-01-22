import 'package:flutter/material.dart';

class InfoPenerimaanBarang extends StatelessWidget {
  const InfoPenerimaanBarang({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Date & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                  SizedBox(width: 8),
                  Text("06 Agustus 2025", style: TextStyle(fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("Draft", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildLabel("Tipe Barang"),
          _buildDropdown("Finish Good"),

          _buildLabel("Supplier"),
          _buildDropdown("Supplier A"),

          _buildLabel("No. PO"),
          _buildDropdown("PO-01N-2304-0001"),

          _buildLabel("Tgl Invoice Supplier"),
          _buildTextField("DD/MM/YYYY", suffixIcon: Icons.calendar_month),

          _buildLabel("No. SJ Supplier"),
          _buildTextField("SJ-001"),

          _buildLabel("No. Invoice Supplier"),
          _buildTextField("SIS-001"),

          _buildLabel("Nomor Polisi"),
          _buildTextField("W 9028 Y"),

          _buildLabel("Nama Supir"),
          _buildTextField("Yatno"),

          _buildLabel("Catatan Header"),
          _buildTextField("Catatan", maxLines: 3),
          
          const SizedBox(height: 100), // Space for bottom button
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 15),
      child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14)),
    );
  }

  Widget _buildTextField(String hint, {IconData? suffixIcon, int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.black87) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  Widget _buildDropdown(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}