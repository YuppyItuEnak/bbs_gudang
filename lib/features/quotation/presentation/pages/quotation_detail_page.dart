import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/quotation_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../data/models/quotation/quotation_detail_model.dart';

class QuotationDetailPage extends StatefulWidget {
  final String quotationId;
  const QuotationDetailPage({super.key, required this.quotationId});

  @override
  State<QuotationDetailPage> createState() => _QuotationDetailPageState();
}

class _QuotationDetailPageState extends State<QuotationDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<QuotationProvider>(
        context,
        listen: false,
      ).fetchQuotationDetail(widget.quotationId, auth.token!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Quotation',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<QuotationProvider>(
        builder: (context, provider, child) {
          if (provider.isDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.detailError != null) {
            return Center(child: Text('Error: ${provider.detailError}'));
          }

          final detail = provider.selectedQuotation;
          if (detail == null) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerSection(detail),
                const SizedBox(height: 16),
                _customerSection(detail),
                const SizedBox(height: 16),
                _topSection(detail),
                const SizedBox(height: 16),
                _detailOrderSection(detail),
                const SizedBox(height: 16),
                _summarySection(detail),
                const SizedBox(height: 24),
                _backButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= HEADER =================
  Widget _headerSection(QuotationDetail detail) {
    String dateFormatted = '-';
    try {
      if (detail.date.isNotEmpty) {
        dateFormatted = DateFormat(
          'dd MMM yyyy',
        ).format(DateTime.parse(detail.date));
      }
    } catch (_) {
      dateFormatted = detail.date;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFF5F6BF7),
          child: Icon(Icons.hourglass_bottom, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.code,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(dateFormatted, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _statusColor(detail.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(detail.status),
            style: TextStyle(color: _statusColor(detail.status)),
          ),
        ),
      ],
    );
  }

  // ================= CUSTOMER =================
  Widget _customerSection(QuotationDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CUSTOMER',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.local_shipping_outlined, color: Color(0xFF5F6BF7)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                detail.customerName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5F6BF7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          detail.shipToAddress ?? '-',
          style: const TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 8),
        if (detail.notes != null)
          Text(
            'Catatan: ${detail.notes}',
            style: const TextStyle(color: Colors.grey),
          ),
      ],
    );
  }

  // ================= TOP =================
  Widget _topSection(QuotationDetail detail) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0)),
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('ToP'),
          Text(
            detail.top ?? '-',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ================= DETAIL ORDER =================
  Widget _detailOrderSection(QuotationDetail detail) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DETAIL ORDER',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Text(
          'Detail Item (${detail.items.length})',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...detail.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _itemCard(item, currency),
          ),
        ),
      ],
    );
  }

  Widget _itemCard(QuotationDetailItem item, NumberFormat currency) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.itemCode,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.itemName, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text(
            '@ ${currency.format(item.price)} x ${item.qty}',
            style: const TextStyle(fontSize: 12),
          ),
          if (item.notes != null) ...[
            const SizedBox(height: 8),
            Text(
              'Catatan: ${item.notes}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sub Total'),
              Text(
                currency.format(item.subtotal),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _summarySection(QuotationDetail detail) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5F6BF7)),
      ),
      child: Column(
        children: [
          _summaryRow('DPP', currency.format(detail.dpp)),
          _summaryRow('Total Diskon', currency.format(detail.totalDiscount)),
          _summaryRow('PPN', currency.format(detail.ppn)),
          const Divider(),
          _summaryRow(
            'Total',
            currency.format(detail.grandTotal),
            isBold: true,
          ),
        ],
      ),
    );
  }

  // ================= BUTTON =================
  Widget _backButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFF5F6BF7)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text(
          'Kembali',
          style: TextStyle(color: Color(0xFF5F6BF7), fontSize: 16),
        ),
      ),
    );
  }

  Color _statusColor(int status) {
    switch (status) {
      case 1:
        return Colors.grey;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.green;
      case 9:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Draft';
      case 2:
        return 'In Approval';
      case 3:
        return 'Revision';
      case 4:
        return 'Approved';
      case 9:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }
}

// ================= REUSABLE =================
class _summaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _summaryRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: const Color(0xFF5F6BF7),
            ),
          ),
        ],
      ),
    );
  }
}
