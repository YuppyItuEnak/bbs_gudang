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

  @override
  void initState() {
    super.initState();

    /// LOAD AWAL
    Future.microtask(() {
      context.read<PenerimaanBarangProvider>().loadAvailablePbDetails(
        token: widget.token,
        poId: widget.poId,
        refresh: true,
      );
    });

    /// PAGINATION
    _scrollController.addListener(_onScroll);
  }

  bool get hasSelectedItem => _qtyMap.values.any((qty) => qty > 0);

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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  "Pilih Item",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),

              /// LIST ITEM
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: Builder(
                    builder: (_) {
                      /// LOADING AWAL
                      if (provider.isLoadingPbDetail &&
                          provider.pbDetails.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      /// ERROR
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

                      /// EMPTY
                      if (provider.pbDetails.isEmpty) {
                        return const Center(child: Text("Data PB kosong"));
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        // MODIFIKASI 1: Tambahkan loading ke hitungan hanya jika sedang loading data tambahan
                        itemCount:
                            provider.pbDetails.length +
                            (provider.hasMore && provider.isLoadingPbDetail
                                ? 1
                                : 0),
                        itemBuilder: (context, index) {
                          // MODIFIKASI 2: Cek apakah index ini adalah slot untuk loading tambahan
                          if (index == provider.pbDetails.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final item = provider.pbDetails[index];
                          final String itemId = item['id'];
                          final String itemName = item['item_name'];
                          final String itemCode = item['item_code'];
                          final int currentQty = _qtyMap[itemId] ?? 0;
                          final double stockValue = ((item['qty'] ?? 0) as num).toDouble();

                          return ItemCard(
                            nama: itemName,
                            kode: itemCode,
                            stock: stockValue,
                            initialQty: currentQty,
                            onQtyChanged: (newQty) {
                              setState(() {
                                _qtyMap[itemId] = newQty;
                              });
                            },
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
                            final selectedItems = _qtyMap.entries
                                .where((e) => e.value > 0)
                                .map((e) {
                                  final item = context
                                      .read<PenerimaanBarangProvider>()
                                      .pbDetails
                                      .firstWhere((i) => i['id'] == e.key);

                                  return {
                                    "purchase_order_d_id":
                                        item["id"], // PO DETAIL ID
                                    "item_id": item["item_id"],
                                    "code": item["item_code"],
                                    "name": item["item_name"],

                                    "qty_order": item["qty"],
                                    "qty_receipt":
                                        item['qty_receipt'], // default awal
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
