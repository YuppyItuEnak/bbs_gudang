import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/quotation_provider.dart';
import 'package:bbs_gudang/data/models/customer/customer_name_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class QuotationFilterModal extends StatefulWidget {
  // final ScrollController scrollController;
  const QuotationFilterModal({super.key});

  @override
  State<QuotationFilterModal> createState() => _QuotationFilterModalState();
}

class _QuotationFilterModalState extends State<QuotationFilterModal> {
  final Key _autocompleteKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final provider = Provider.of<QuotationProvider>(context, listen: false);

      if (auth.user?.userDetails.isNotEmpty == true) {
        final salesId = auth.user!.userDetails.first.fUserDefault;
        provider.searchCustomers(auth.token!, '', salesId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuotationProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Filter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// PERIODE
              _label('Periode'),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: provider.startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );

                        if (picked != null) {
                          provider.setDateRange(picked, provider.endDate);
                        }
                      },
                      child: _box(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              provider.startDate != null
                                  ? DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(provider.startDate!)
                                  : 'Tanggal awal',
                            ),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: provider.endDate ?? DateTime.now(),
                          firstDate: provider.startDate ?? DateTime(2020),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );

                        if (picked != null) {
                          provider.setDateRange(provider.startDate, picked);
                        }
                      },

                      child: _box(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              provider.endDate != null
                                  ? DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(provider.endDate!)
                                  : 'Tanggal akhir',
                            ),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// CUSTOMER
              _label('Customer'),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Autocomplete<CustomerSimpleModel>(
                    key: _autocompleteKey,
                    displayStringForOption: (o) => o.name,
                    optionsBuilder: (value) async {
                      final auth = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      await provider.searchCustomers(
                        auth.token!,
                        value.text,
                        auth.user!.userDetails.first.fUserDefault,
                      );
                      return provider.customerSearchResults;
                    },
                    onSelected: provider.setSelectedCustomer,
                    fieldViewBuilder: (context, controller, focusNode, _) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Pilih Customer',
                          suffixIcon: const Icon(Icons.keyboard_arrow_down),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              /// STATUS
              _label('Status'),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: provider.filterStatus,
                decoration: InputDecoration(
                  hintText: 'Semua',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Semua'),
                  ),
                  ...provider.statusList.asMap().entries.map(
                    (e) => DropdownMenuItem<String>(
                      value: (e.key + 1).toString(),
                      child: Text(e.value),
                    ),
                  ),
                ],
                onChanged: provider.setStatusFilter,
              ),
              const SizedBox(height: 30),

              /// BUTTON FILTER
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final auth = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    provider.fetchQuotations(
                      auth.user!.userDetails.first.fUserDefault!,
                      auth.token!,
                      isRefresh: true,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F6BF7),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Filter',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _label(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );
}

Widget _box({required Widget child}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
}
