import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tambahkan intl di pubspec.yaml untuk format tanggal

class FilterKartuStockPage extends StatefulWidget {
  const FilterKartuStockPage({super.key});

  @override
  State<FilterKartuStockPage> createState() => _FilterKartuStockPageState();
}

class _FilterKartuStockPageState extends State<FilterKartuStockPage> {
  // State untuk menyimpan rentang tanggal
  DateTimeRange? _selectedDateRange;

  // State untuk warehouse dan item
  List<String> _selectedWarehouses = ["Warehouse A", "Warehouse B"];
  String? _selectedItem;

  // Fungsi untuk memicu Date Range Picker
  Future<void> _selectDate() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange:
          _selectedDateRange ??
          DateTimeRange(start: DateTime.now(), end: DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green, // Warna header picker
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  // Helper untuk memformat tampilan tanggal di UI
  String _getFormattedDateRange() {
    if (_selectedDateRange == null) return "Pilih Periode";
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return "${formatter.format(_selectedDateRange!.start)} - ${formatter.format(_selectedDateRange!.end)}";
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
          "Filter",
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Section Periode ---
                  _buildLabel("Periode"),
                  const SizedBox(height: 8),
                  _buildDropdownField(
                    text: _getFormattedDateRange(),
                    icon: Icons.calendar_month_outlined,
                    isPlaceholder: _selectedDateRange == null,
                    onTap: _selectDate, // Panggil fungsi picker
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // --- Button Apply ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedDateRange == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Pilih periode terlebih dahulu"),
                      ),
                    );
                    return;
                  }

                  // Kirim data balik ke KartuStockPage
                  Navigator.pop(context, {
                    'startDate': DateFormat(
                      'yyyy-MM-dd',
                    ).format(_selectedDateRange!.start),
                    'endDate': DateFormat(
                      'yyyy-MM-dd',
                    ).format(_selectedDateRange!.end),
                    'warehouses': _selectedWarehouses,
                    'item': _selectedItem,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Apply",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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

  // Helper Widgets (Label, DropdownField, Chip) tetap sama seperti sebelumnya
  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDropdownField({
    required String text,
    required IconData icon,
    bool isPlaceholder = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isPlaceholder ? Colors.grey : Colors.black87,
                fontSize: 14,
              ),
            ),
            Icon(icon, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionChip(String label, VoidCallback onDelete) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.green, fontSize: 13),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, color: Colors.green, size: 14),
          ),
        ],
      ),
    );
  }
}
