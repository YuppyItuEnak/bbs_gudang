import 'package:bbs_gudang/data/models/customer/customer_address_model.dart';
import 'package:bbs_gudang/data/models/customer/customer_name_model.dart';
import 'package:bbs_gudang/data/models/item/selected_item_model.dart';
import 'package:bbs_gudang/data/models/m_gen_model.dart';
import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/quotation/presentation/providers/top_provider.dart';
import 'package:bbs_gudang/features/quotation/presentation/widget/quotation_item_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'customer_list_page.dart';
import 'product_group_page.dart';

class QuotationFormPage extends StatefulWidget {
  const QuotationFormPage({super.key});

  @override
  State<QuotationFormPage> createState() => _QuotationFormPageState();
}

class _QuotationFormPageState extends State<QuotationFormPage> {
  CustomerSimpleModel? _selectedCustomer;
  CustomerAddressModel? _selectedAddress;
  MGenModel? _selectedTop;
  final List<SelectedItem> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        Provider.of<TopProvider>(context, listen: false)
            .fetchTopOptions(authProvider.token!);
      }
    });
  }

  void _navigateToCustomerList() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const CustomerListPage()),
    );

    if (result != null) {
      setState(() {
        _selectedCustomer = result['customer'] as CustomerSimpleModel?;
        _selectedAddress = result['address'] as CustomerAddressModel?;
      });
    }
  }

  void _showTopOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<TopProvider>(
          builder: (context, topProvider, child) {
            if (topProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (topProvider.error != null) {
              return Center(child: Text(topProvider.error!));
            }

            return ListView.builder(
              itemCount: topProvider.topOptions.length,
              itemBuilder: (context, index) {
                final top = topProvider.topOptions[index];
                return ListTile(
                  title: Text(top.value1 ?? ''),
                  onTap: () {
                    setState(() {
                      _selectedTop = top;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _navigateAndAddItems() async {
    final newItems = await Navigator.push<List<SelectedItem>>(
      context,
      MaterialPageRoute(builder: (_) => const ProductGroupPage()),
    );

    if (newItems != null) {
      setState(() {
        for (var newItem in newItems) {
          final index = _selectedItems
              .indexWhere((item) => item.item.id == newItem.item.id);
          if (index != -1) {
            _selectedItems[index].quantity += newItem.quantity;
          } else {
            _selectedItems.add(newItem);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotation'),
        leading: const BackButton(),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // CUSTOMER
            InkWell(
              onTap: _navigateToCustomerList,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NAME + UBAH
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedCustomer?.name ?? 'Pilih Customer',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _selectedCustomer != null
                                  ? const Color(0xFF5F6BF7)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _navigateToCustomerList,
                          child: const Text(
                            'Ubah',
                            style: TextStyle(
                              color: Color(0xFF5F6BF7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_selectedAddress != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _selectedAddress!.address,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ]
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // TOP
            GestureDetector(
              onTap: _showTopOptions,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ToP',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Row(children: [
                    Text(_selectedTop?.value1 ?? 'Pilih ToP'),
                    const Icon(Icons.chevron_right)
                  ]),
                ],
              ),
            ),

            const Divider(height: 32),

            // DETAIL ITEM
            Text(
              'Detail Item(${_selectedItems.length})',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            if (_selectedItems.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('Belum ada item yang ditambahkan.'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final selectedItem = _selectedItems[index];
                  final subtotal = (selectedItem.item.pricelist?.price ?? 0) *
                      selectedItem.quantity;
                  return QuotationItemCard(
                    code: selectedItem.item.code,
                    name: selectedItem.item.name,
                    quantity: selectedItem.quantity,
                    subtotal: 'Rp ${subtotal.toStringAsFixed(0)}',
                  );
                },
              ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: _navigateAndAddItems,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFF5F6BF7)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '+ Tambah Barang',
                style: TextStyle(color: Color(0xFF5F6BF7)),
              ),
            ),

            const SizedBox(height: 24),

            // SUMMARY
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  _SummaryRow(label: 'DPP', value: 'Rp 1.800.000'),
                  _SummaryRow(label: 'Total Diskon', value: 'Rp 0'),
                  _SummaryRow(label: 'PPN 11%', value: 'Rp 198.000'),
                  Divider(),
                  _SummaryRow(
                    label: 'Total',
                    value: 'Rp 1.998.000',
                    bold: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5F6BF7),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {},
          child: const Text('Submit'),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              color: bold ? const Color(0xFF5F6BF7) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}