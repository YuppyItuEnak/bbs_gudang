import 'package:bbs_gudang/core/constants/app_colors.dart';
import 'package:bbs_gudang/data/models/item/item_model.dart';
import 'package:bbs_gudang/data/models/item/selected_item_model.dart';
import 'package:bbs_gudang/data/models/m_gen_model.dart';
import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/quotation/presentation/providers/product_provider.dart';
import 'package:bbs_gudang/features/quotation/presentation/widget/product_item_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductListPage extends StatefulWidget {
  final MGenModel productGroup;

  const ProductListPage({super.key, required this.productGroup});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final List<SelectedItem> _selectedItems = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    if (authProvider.token != null) {
      productProvider.fetchProducts(
        token: authProvider.token!,
        itemDivisionId: widget.productGroup.id,
        isRefresh: true,
      );
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (authProvider.token != null) {
          productProvider.fetchProducts(
            token: authProvider.token!,
            itemDivisionId: widget.productGroup.id,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onItemTapped(ItemModel item) {
    setState(() {
      final index =
          _selectedItems.indexWhere((selected) => selected.item.id == item.id);
      if (index != -1) {
        _selectedItems.removeAt(index);
      } else {
        _selectedItems.add(SelectedItem(item: item));
      }
    });
  }

  void _incrementQuantity(SelectedItem selectedItem) {
    setState(() {
      selectedItem.quantity++;
    });
  }

  void _decrementQuantity(SelectedItem selectedItem) {
    setState(() {
      if (selectedItem.quantity > 1) {
        selectedItem.quantity--;
      }
    });
  }

  void _updateQuantity(SelectedItem selectedItem, int val) {
    setState(() {
      if (val > 0) {
        selectedItem.quantity = val;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Barang',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        body: Consumer<ProductProvider>(
          builder: (context, provider, _) {
            return ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                /// ===============================
                /// GROUP HEADER + HARGA
                /// ===============================
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5F6BF7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.productGroup.value1 ?? '-',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Text(
                        'Harga',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            hintText: 'Rp 0',
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// ===============================
                /// SEARCH BAR
                /// ===============================
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Cari',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (value) {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            if (authProvider.token != null) {
                              provider.fetchProducts(
                                token: authProvider.token!,
                                itemDivisionId: widget.productGroup.id,
                                search: value,
                                isRefresh: true,
                              );
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// ===============================
                /// PRODUCT LIST
                /// ===============================
                if (provider.products.isEmpty && provider.isLoading)
                  const Center(child: CircularProgressIndicator()),

                if (provider.error != null && provider.products.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(child: Text(provider.error!)),
                  ),

                ...List.generate(provider.products.length, (index) {
                  final item = provider.products[index];
                  final selectedItemIndex = _selectedItems
                      .indexWhere((selected) => selected.item.id == item.id);
                  final isSelected = selectedItemIndex != -1;
                  final selectedItem =
                      isSelected ? _selectedItems[selectedItemIndex] : null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProductItemCard(
                      product: item,
                      isSelected: isSelected,
                      onTap: () => _onItemTapped(item),
                      quantity: selectedItem?.quantity ?? 1,
                      onIncrement: isSelected
                          ? () => _incrementQuantity(selectedItem!)
                          : null,
                      onDecrement: isSelected
                          ? () => _decrementQuantity(selectedItem!)
                          : null,
                      onQuantityChanged: isSelected
                          ? (val) => _updateQuantity(selectedItem!, val)
                          : null,
                    ),
                  );
                }),

                if (provider.hasMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _selectedItems.isNotEmpty
                ? () {
                    Navigator.pop(context, _selectedItems);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5F6BF7),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Tambah ${_selectedItems.length} Barang'),
          ),
        ),
      ),
    );
  }
}
