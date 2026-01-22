import 'package:bbs_gudang/features/quotation/presentation/pages/quotation_detail_page.dart';
import 'package:flutter/material.dart';

class QuotationCard extends StatelessWidget {
  final dynamic quotation;

  const QuotationCard({super.key, required this.quotation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showActionModal(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT (Flexible)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quotation.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quotation.code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // RIGHT (Fixed)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _getStatusText(quotation.status),
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: _statusColor(quotation.status),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quotation.date,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // STATUS COLOR
  // =========================
  Color _statusColor(int status) {
    switch (status) {
      case 1: // Draft
        return Colors.grey;
      case 2: // In Approval
        return Colors.orange;
      case 3: // Revision
        return Colors.blue;
      case 4: // Approved
        return Colors.green;
      case 9: // Rejected
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

  void _showActionModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
                  leading: const Icon(Icons.visibility_outlined),
                  title: const Text('Lihat Detail'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuotationDetailPage(
                        quotationId: quotation.id,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.copy_outlined),
                  title: const Text('Copy Quotation'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
