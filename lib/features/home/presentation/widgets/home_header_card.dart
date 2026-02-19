import 'package:bbs_gudang/features/notification/presentation/providers/notification_provider.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/pages/penerimaan_barang_page.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/pages/kartu_stock_page.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/pages/pengeluaran_barang_page.dart';
import 'package:bbs_gudang/features/stock_adjustment/presentation/pages/stk_adjustment_page.dart';
import 'package:bbs_gudang/features/stock_adjustment/presentation/providers/stock_adjustment_provider.dart';
import 'package:bbs_gudang/features/stock_opname/presentation/pages/stock_opname_page.dart';
import 'package:bbs_gudang/features/stock_opname/presentation/providers/stock_opname_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'home_menu_card.dart';
import 'home_stock_info.dart';

class HomeHeaderCard extends StatelessWidget {
  final AuthProvider auth;

  const HomeHeaderCard({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, ${auth.user?.name ?? 'Dinda'}!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Text(
                    "Surabaya",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const Spacer(),
              Consumer<NotificationProvider>(
                builder: (context, provider, child) {
                  // Ambil jumlah notifikasi
                  int count = provider.listNotifications.length;

                  return Badge(
                    isLabelVisible:
                        count > 0, // Sembunyikan jika tidak ada notifikasi
                    label: Text(
                      count.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        // Navigasi ke halaman notifikasi atau buka menu
                        _showNotificationPanel(context, provider);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              HomeMenuCard(
                title: "Penerimaan",
                icon: Icons.grid_view_rounded,
                bgColor: Color(0xFFE8F5E9),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PenerimaanBarangPage(),
                    ),
                  );
                },
              ),
              SizedBox(width: 16),
              HomeMenuCard(
                title: "Kartu Stock",
                icon: Icons.description_outlined,
                bgColor: Color(0xFFE3F2FD),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KartuStockPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                /// OVERSTOCK → STOCK OPNAME
                Consumer<StockOpnameProvider>(
                  builder: (context, opnameProvider, _) {
                    return HomeStockInfo(
                      count: "${opnameProvider.reports.length} Items",
                      label: "Overstock",
                      icon: Icons.inventory_2,
                      iconColor: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StockOpnamePage(),
                          ),
                        );
                      },
                    );
                  },
                ),

                Container(
                  height: 30,
                  width: 1,
                  color: Colors.white.withOpacity(0.2),
                ),

                /// UNDERSTOCK → STOCK ADJUSTMENT
                Consumer<StockAdjustmentProvider>(
                  builder: (context, adjustmentProvider, _) {
                    return HomeStockInfo(
                      count: "${adjustmentProvider.data.length} Items",
                      label: "Understock",
                      icon: Icons.mail_outline,
                      iconColor: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StkAdjustmentPage(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationPanel(
    BuildContext context,
    NotificationProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Notifikasi Terbaru",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Divider(),
              if (provider.listNotifications.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Tidak ada notifikasi baru"),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.listNotifications.length,
                    itemBuilder: (context, index) {
                      final item = provider.listNotifications[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.action == 'approval'
                              ? Colors.orange.shade100
                              : Colors.blue.shade100,
                          child: Icon(
                            item.action == 'approval'
                                ? Icons.assignment
                                : Icons.info,
                            color: item.action == 'approval'
                                ? Colors.orange
                                : Colors.blue,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(item.message),
                        onTap: () {
                          // Logika untuk navigasi berdasarkan entity_type atau entity_id
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
