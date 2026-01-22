import 'package:bbs_gudang/core/constants/app_colors.dart';
import 'package:bbs_gudang/data/models/customer/customer_address_model.dart';
import 'package:bbs_gudang/data/services/customer/customer_repository.dart';
import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_gudang/features/quotation/presentation/widget/addresses_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerAddressPage extends StatefulWidget {
  final String customerId;

  const CustomerAddressPage({super.key, required this.customerId});

  @override
  State<CustomerAddressPage> createState() => _CustomerAddressPageState();
}

class _CustomerAddressPageState extends State<CustomerAddressPage> {
  final CustomerRepository _customerRepository = CustomerRepository();
  List<CustomerAddressModel> _addresses = [];
  CustomerAddressModel? _selectedAddress;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      setState(() {
        _isLoading = false;
        _error = 'User not authenticated.';
      });
      return;
    }

    try {
      final addresses = await _customerRepository.fetchCustomerAddresses(
        widget.customerId,
        token,
      );
      setState(() {
        _addresses = addresses;
        _isLoading = false;
        // Set default selection
        if (_addresses.isNotEmpty) {
          _selectedAddress = _addresses.firstWhere(
            (addr) => addr.isDefault,
            orElse: () => _addresses.first,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to fetch addresses: $e';
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Handle new address
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF5F6BF7)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('+ Alamat Baru'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedAddress != null
                      ? () {
                          Navigator.pop(context, _selectedAddress);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F6BF7),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Pilih',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
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

    if (_addresses.isEmpty) {
      return const Center(child: Text('No addresses found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        final address = _addresses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: AddressCard(
            address: address,
            active: _selectedAddress?.id == address.id,
            onTap: () {
              setState(() {
                _selectedAddress = address;
              });
            },
          ),
        );
      },
    );
  }
}
