import 'package:bbs_gudang/features/penerimaan_barang/presentation/pages/penerimaan_barang_page.dart';
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
              const Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 28,
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
                title: "Pengeluaran",
                icon: Icons.description_outlined,
                bgColor: Color(0xFFE3F2FD),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PengeluaranBarangPage(),
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
}
