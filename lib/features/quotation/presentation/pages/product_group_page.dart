import 'package:bbs_gudang/core/constants/app_colors.dart';
import 'package:bbs_gudang/data/models/item/item_model.dart';
import 'package:bbs_gudang/data/models/m_gen_model.dart';
import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/quotation/presentation/pages/product_list_page.dart';
import 'package:bbs_gudang/features/quotation/presentation/providers/product_group_provider.dart';
import 'package:bbs_gudang/features/quotation/presentation/widget/product_group_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductGroupPage extends StatefulWidget {
  const ProductGroupPage({super.key});

  @override
  State<ProductGroupPage> createState() => _ProductGroupPageState();
}

class _ProductGroupPageState extends State<ProductGroupPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        Provider.of<ProductGroupProvider>(
          context,
          listen: false,
        ).fetchProductGroups(authProvider.token!);
      }
    });
  }

  void _onGroupSelected(MGenModel group) async {
    final selectedItems = await Navigator.push<List<ItemModel>>(
      context,
      MaterialPageRoute(builder: (_) => ProductListPage(productGroup: group)),
    );

    if (selectedItems != null && selectedItems.isNotEmpty) {
      Navigator.pop(context, selectedItems);
    }
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
        body: Consumer<ProductGroupProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.productGroups.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final group = provider.productGroups[index];
                return ProductGroupCard(
                  name: group.value1 ?? '',
                  onTap: () => _onGroupSelected(group),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
