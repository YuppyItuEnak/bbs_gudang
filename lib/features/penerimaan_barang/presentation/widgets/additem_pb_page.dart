import 'dart:async';

import 'package:bbs_gudang/features/penerimaan_barang/presentation/providers/penerimaan_barang_provider.dart'
    show PenerimaanBarangProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bbs_gudang/features/transfer_warehouse/presentation/widgets/item_card.dart';

class AddItemPBPage extends StatefulWidget {
  final String token;
  final String poId;

  const AddItemPBPage({super.key, required this.token, required this.poId});

  @override
  State<AddItemPBPage> createState() => _AddItemPBPageState();
}

class _AddItemPBPageState extends State<AddItemPBPage> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, int> _qtyMap = {};
  final Set<String> _checkedIds = {};

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PenerimaanBarangProvider>().loadAvailablePbDetails(
        token: widget.token,
        poId: widget.poId,
        refresh: true,
      );
    });

    _scrollController.addListener(_onScroll);
  }

  /// Isi _qtyMap dan _checkedIds dengan qty_outstanding untuk item baru.
  void _initOutstandingQty(List<Map<String, dynamic>> details) {
    if (!mounted) return;
    bool changed = false;
    for (final item in details) {
      final String id = item['id'] as String;
      if (!_qtyMap.containsKey(id)) {
        final int outstanding =
            ((item['qty_outstanding'] ?? 0) as num).toInt();
        _qtyMap[id] = outstanding;
        if (outstanding > 0) _checkedIds.add(id);
        changed = true;
      }
    }
    if (changed) setState(() {});
  }

  bool get hasSelectedItem =>
      _checkedIds.any((id) => (_qtyMap[id] ?? 0) > 0);

  void _onScroll() {
    final provider = context.read<PenerimaanBarangProvider>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 150) {
      if (!provider.isLoadingPbDetail && provider.hasMore) {
        provider.loadAvailablePbDetails(token: widget.token, poId: widget.poId);
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _qtyMap.clear();
      _checkedIds.clear();
    });
    await context.read<PenerimaanBarangProvider>().loadAvailablePbDetails(
      token: widget.token,
      poId: widget.poId,
      refresh: true,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "List Item PB",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PenerimaanBarangProvider>(
        builder: (context, provider, _) {
          // Inisialisasi qty_outstanding ke _qtyMap & _checkedIds saat data baru tiba
          if (provider.pbDetails.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _initOutstandingQty(provider.pbDetails),
            );
          }

          final bool allChecked = provider.pbDetails.isNotEmpty &&
              provider.pbDetails.every(
                (item) => _checkedIds.contains(item['id'] as String),
              );
          final bool someChecked = !allChecked &&
              provider.pbDetails.any(
                (item) => _checkedIds.contains(item['id'] as String),
              );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER: "Pilih Item" + "Pilih Semua"
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
                child: Row(
                  children: [
                    const Text(
                      "Pilih Item",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    if (provider.pbDetails.isNotEmpty) ...[
                      const Text(
                        "Pilih Semua",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      Checkbox(
                        activeColor: Colors.green,
                        tristate: true,
                        value: allChecked
                            ? true
                            : someChecked
                                ? null
                                : false,
                        onChanged: (_) {
                          setState(() {
                            if (allChecked) {
                              _checkedIds.clear();
                            } else {
                              for (final item in provider.pbDetails) {
                                _checkedIds.add(item['id'] as String);
                              }
                            }
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),

              /// LIST ITEM
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: Builder(
                    builder: (_) {
                      if (provider.isLoadingPbDetail &&
                          provider.pbDetails.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.errorMessage != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(provider.errorMessage!),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _onRefresh,
                                child: const Text("Coba Lagi"),
                              ),
                            ],
                          ),
                        );
                      }

                      if (provider.pbDetails.isEmpty) {
                        return const Center(child: Text("Data PB kosong"));
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(8, 0, 20, 0),
                        itemCount: provider.pbDetails.length +
                            (provider.hasMore && provider.isLoadingPbDetail
                                ? 1
                                : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.pbDetails.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final item = provider.pbDetails[index];
                          final String itemId = item['id'] as String;
                          final String itemName = item['item_name'] ?? '-';
                          final String itemCode = item['item_code'] ?? '-';
                          final int currentQty = _qtyMap[itemId] ?? 0;
                          final double stockValue = ((item['qty_outstanding'] ??
                                      item['qty'] ??
                                      0) as num)
                                  .toDouble();
                          final bool isChecked = _checkedIds.contains(itemId);

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                activeColor: Colors.green,
                                value: isChecked,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _checkedIds.add(itemId);
                                    } else {
                                      _checkedIds.remove(itemId);
                                    }
                                  });
                                },
                              ),
                              Expanded(
                                child: Opacity(
                                  opacity: isChecked ? 1.0 : 0.45,
                                  child: ItemCard(
                                    nama: itemName,
                                    kode: itemCode,
                                    stock: stockValue,
                                    stockLabel: 'Qty Outstanding',
                                    initialQty: currentQty,
                                    onQtyChanged: (newQty) {
                                      setState(() {
                                        _qtyMap[itemId] = newQty;
                                        // auto-check saat qty diubah > 0
                                        if (newQty > 0) {
                                          _checkedIds.add(itemId);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              /// BOTTOM BUTTON
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: hasSelectedItem
                        ? () {
                            final selectedItems = _checkedIds
                                .where((id) => (_qtyMap[id] ?? 0) > 0)
                                .map((id) {
                                  final item = context
                                      .read<PenerimaanBarangProvider>()
                                      .pbDetails
                                      .firstWhere((i) => i['id'] == id);

                                  return {
                                    "purchase_order_d_id": item["id"],
                                    "item_id": item["item_id"],
                                    "code": item["item_code"],
                                    "name": item["item_name"],
                                    "qty_order": item["qty"],
                                    "qty_outstanding": item["qty_outstanding"],
                                    "qty_receipt": _qtyMap[id] ?? 1,
                                  };
                                })
                                .toList();

                            Navigator.pop(context, selectedItems);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Tambahkan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
