import 'package:bbs_gudang/core/constants/app_colors.dart';
import 'package:bbs_gudang/features/quotation/presentation/pages/quotation_form_page.dart';
import 'package:bbs_gudang/features/quotation/presentation/widget/quotation_card.dart';
import 'package:bbs_gudang/features/quotation/presentation/widget/quotation_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/quotation_provider.dart';

class QuotationListPage extends StatefulWidget {
  const QuotationListPage({super.key});

  @override
  State<QuotationListPage> createState() => _QuotationListPageState();
}

class _QuotationListPageState extends State<QuotationListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final quotationProvider = Provider.of<QuotationProvider>(
        context,
        listen: false,
      );

      if (authProvider.user?.userDetails.isNotEmpty == true) {
        final salesId = authProvider.user!.userDetails.first.fUserDefault;
        quotationProvider.fetchQuotations(salesId!, authProvider.token!);
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
            'Quotation',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        floatingActionButton: SizedBox(
          width: 64,
          height: 64,
          child: FloatingActionButton(
            elevation: 6,
            shape: const CircleBorder(),
            backgroundColor: const Color(0xFF5F6BF7),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuotationFormPage()),
              );
            },
            child: const Icon(Icons.add, size: 32, color: Colors.white),
          ),
        ),

        body: Consumer<QuotationProvider>(
          builder: (context, quotationProvider, child) {
            if (quotationProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (quotationProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(quotationProvider.error!),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        final salesId =
                            authProvider.user!.userDetails.first.fUserDefault;
                        quotationProvider.fetchQuotations(
                          salesId!,
                          authProvider.token!,
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final quotations = quotationProvider.quotations;

            return Column(
              children: [
                QuotationSearchBar(
                  onSubmitted: (value) {
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    final salesId =
                        authProvider.user!.userDetails.first.fUserDefault;
                    quotationProvider.setSearchKeyword(value);
                    quotationProvider.fetchQuotations(
                      salesId!,
                      authProvider.token!,
                      isRefresh: true,
                    );
                  },
                ),
                Expanded(
                  child: quotations.isEmpty
                      ? const Center(child: Text('No quotations found'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: quotations.length,
                          itemBuilder: (context, index) {
                            final quotation = quotations[index];
                            return QuotationCard(quotation: quotation);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
