import 'package:bbs_gudang/data/models/transfer_warehouse/company_warehouse_model.dart';
import 'package:flutter/material.dart';

class FilterKartuStockPage extends StatefulWidget {
  final List<CompanyWarehouseModel> warehouses;

  const FilterKartuStockPage({super.key, required this.warehouses});

  @override
  State<FilterKartuStockPage> createState() => _FilterKartuStockPageState();
}

class _FilterKartuStockPageState extends State<FilterKartuStockPage> {
  final List<CompanyWarehouseModel> _selectedWarehouses = [];


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
          "Pilih Warehouse",
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
            child: widget.warehouses.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: widget.warehouses.length,
                    itemBuilder: (context, index) {
                      final wh = widget.warehouses[index];
                      final isSelected =
                          _selectedWarehouses.any((s) => s.id == wh.id);
                      return CheckboxListTile(
                        value: isSelected,
                        activeColor: Colors.green,
                        title: Text(
                          wh.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onChanged: (_) {
                          setState(() {
                            if (isSelected) {
                              _selectedWarehouses
                                  .removeWhere((s) => s.id == wh.id);
                            } else {
                              _selectedWarehouses.add(wh);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedWarehouses.isEmpty
                    ? null
                    : () {
                        Navigator.pop(context, {
                          'warehouseIds': _selectedWarehouses
                              .map((wh) => wh.id)
                              .toList(),
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  disabledBackgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Tampilkan Stok",
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
}
