import 'dart:async';

import 'package:bbs_gudang/features/list_item/presentation/providers/item_provider.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TambahItem extends StatefulWidget {
  final String token;
  final bool isOpnameMode;

  const TambahItem({super.key, required this.token, this.isOpnameMode = false});

  @override
  State<TambahItem> createState() => _TambahItemState();
}

class _TambahItemState extends State<TambahItem> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, int> _qtyMap = {};
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce; // untuk debounce search

  @override
  void initState() {
    super.initState();

    // LOAD AWAL
    Future.microtask(() {
      context.read<ItemBarangProvider>().fetchItems(
        token: widget.token,
        refresh: true,
      );
    });

    // PAGINATION SCROLL
    _scrollController.addListener(_onScroll);
  }

  bool get hasSelectedItem => _qtyMap.values.any((qty) => qty > 0);

  void _onScroll() {
    final provider = context.read<ItemBarangProvider>();

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 150) {
      if (!provider.isLoading && provider.hasMore) {
        provider.fetchItems(token: widget.token, nextPage: true);
      }
    }
  }

  void _onSearchChanged(String value) {
    // DEBOUNCE 500ms
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ItemBarangProvider>().fetchItems(
        token: widget.token,
        refresh: true,
        name: value,
      );
    });
  }

  Future<void> _onRefresh() async {
    await context.read<ItemBarangProvider>().fetchItems(
      token: widget.token,
      refresh: true,
      name: _searchController.text,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
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
          "List Item",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ItemBarangProvider>(
        builder: (context, provider, _) {
          final filteredItems = widget.isOpnameMode
              ? provider.items
                    .where((item) => item.itemTypeName?.toUpperCase() != "JASA")
                    .toList()
              : provider.items;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEARCH BAR ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: "Cari nama barang",
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Pilih Item",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // --- LIST ITEMS ---
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: Builder(
                    builder: (_) {
                      // LOADING AWAL
                      if (provider.isLoading && filteredItems.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (filteredItems.isEmpty) {
                        return const Center(
                          child: Text("Tidak ada item yang dapat diopname"),
                        );
                      }

                      // ERROR
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

                      // EMPTY
                      if (provider.items.isEmpty) {
                        return const Center(child: Text("Data item kosong"));
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount:
                            filteredItems.length + (provider.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          // LOADING BAWAH (NEXT PAGE)
                          if (index == filteredItems.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final item = filteredItems[index];
                          final currentQty = _qtyMap[item.id] ?? 0;

                          return ItemCard(
                            nama: item.name,
                            kode: item.code,
                            initialQty: currentQty,
                            isSelectionMode: widget
                                .isOpnameMode, // Menyembunyikan selector +/- di Card
                            onQtyChanged: (newQty) {
                              setState(() {
                                _qtyMap[item.id] = newQty;
                              });
                            },
                            // --- IMPLEMENTASI DI SINI ---
                            onTap: () {
                              if (widget.isOpnameMode) {
                                // Langsung kembalikan item yang dipilih ke halaman sebelumnya
                                Navigator.pop(context, [
                                  {
                                    "id": item.id,
                                    "code": item.code,
                                    "name": item.name,
                                    "item_uom_id": item.itemUomId,
                                    "item_group_coa_id": item.itemGroupCoaId,
                                    "qty":
                                        0, // Berikan qty default 1, nanti diedit di halaman Opname
                                  },
                                ]);
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // --- BOTTOM BUTTON ---
              Padding(
                padding: const EdgeInsets.all(20.0),
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
                                      .read<ItemBarangProvider>()
                                      .items
                                      .firstWhere((i) => i.id == e.key);

                                  return {
                                    "id": item.id,
                                    "code": item.code,
                                    "name": item.name,
                                    "item_uom_id":
                                        item.itemUomId, // DIAMBIL DARI MODEL
                                    "item_group_coa_id": item
                                        .itemGroupCoaId, // DIAMBIL DARI MODEL
                                    "qty": e.value,
                                  };
                                })
                                .toList();

                            Navigator.pop(context, selectedItems);
                          }
                        : null, // ⬅️ disable
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
