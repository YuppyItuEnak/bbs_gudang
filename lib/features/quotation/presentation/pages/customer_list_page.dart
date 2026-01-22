import 'package:bbs_gudang/core/constants/app_colors.dart';
import 'package:bbs_gudang/data/models/customer/customer_address_model.dart';
import 'package:bbs_gudang/features/quotation/presentation/pages/customer_address_page.dart';
import 'package:bbs_gudang/data/models/customer/customer_name_model.dart';
import 'package:bbs_gudang/data/services/customer/customer_repository.dart';
import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:bbs_gudang/features/quotation/presentation/widget/customer_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final CustomerRepository _customerRepository = CustomerRepository();
  List<CustomerSimpleModel> _customers = [];
  CustomerSimpleModel? _selectedCustomer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    final salesId = authProvider.user?.userDetails.isNotEmpty == true
        ? authProvider.user!.userDetails.first.fResponsibility
        : null;

    final prefs = await SharedPreferences.getInstance();
    final unitBusinessId = prefs.getString('unit_bussiness_id');

    if (token == null || salesId == null || unitBusinessId == null) {
      setState(() {
        _isLoading = false;
        _error = 'User not authenticated or sales ID not found.';
      });
      return;
    }

    try {
      final customers = await _customerRepository.fetchListCustomersName(
        token,
        salesId: salesId,
        search: '',
        unitBusinessId: unitBusinessId,
      );
      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to fetch customers: $e';
      });
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
            'Customer List',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        body: _buildBody(),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _selectedCustomer != null
                ? () async {
                    final selectedAddress =
                        await Navigator.push<CustomerAddressModel>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomerAddressPage(
                              customerId: _selectedCustomer!.id,
                            ),
                          ),
                        );
                    if (selectedAddress != null) {
                      Navigator.pop(context, {
                        'customer': _selectedCustomer,
                        'address': selectedAddress,
                      });
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5F6BF7),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Pilih', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_customers.isEmpty) {
      return const Center(child: Text('No customers found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _customers.length,
      itemBuilder: (context, index) {
        final customer = _customers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: CustomerCard(
            name: customer.name ?? 'No Name',
            type: customer.segment ?? 'No Type',
            selected: _selectedCustomer?.id == customer.id,
            onTap: () {
              setState(() {
                _selectedCustomer = customer;
              });
            },
          ),
        );
      },
    );
  }
}
