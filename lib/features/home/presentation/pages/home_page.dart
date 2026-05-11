import 'package:bbs_gudang/data/services/kartu_stock/kartu_stock_repository.dart';
import 'package:bbs_gudang/features/home/presentation/providers/history_gudang_provider.dart';
import 'package:bbs_gudang/features/home/presentation/widgets/home_header_card.dart';
import 'package:bbs_gudang/features/notification/presentation/providers/notification_provider.dart';
import 'package:bbs_gudang/features/profile/presentation/pages/profile_page.dart';
import 'package:bbs_gudang/features/stock_adjustment/presentation/providers/stock_adjustment_provider.dart';
import 'package:bbs_gudang/features/stock_opname/presentation/providers/stock_opname_provider.dart'
    show StockOpnameProvider;
import 'package:bbs_gudang/features/transfer_warehouse/presentation/pages/transfer_warehouse_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_history_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final provider = Provider.of<HistoryGudangProvider>(
        context,
        listen: false,
      );

      final token = context.read<AuthProvider>().token;
      final userId = context.read<AuthProvider>().user?.id ?? '';

      if (token != null) {
        // provider.fetchHistoryGudang(token: token);

        provider.fetchPengeluaranBarangHistory(token: token);
        provider.fetchPenerimaanBarangHistory(token: token);
        provider.fetchStkAdjustHistory(token: token);
        provider.fetchStkOpnameHistory(token: token);
        context.read<NotificationProvider>().fetchNotifications(
          token: token,
          userId: userId,
        );

        context.read<StockOpnameProvider>().fetchStockOpnameReport(
          token: token,
          startDate: '',
          endDate: '',
        );
        context.read<StockAdjustmentProvider>().fetchStockAdjustments(
          token: token,
        );
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      // const TransferWarehousePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: _selectedIndex == 0
          ? const Color(0xFF4CAF50)
          : Colors.white,
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: pages),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeContent() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Stack(
          children: [
            HomeHeaderCard(auth: auth),
            // DraggableScrollableSheet(
            //   initialChildSize: 0.55,
            //   minChildSize: 0.45,
            //   maxChildSize: 0.95,
            //   builder: (context, scrollController) {
            //     return HomeHistorySection(scrollController: scrollController);
            //   },
            // ),
          ],
        );
      },
    );
  }

  Widget _buildFAB() {
    // Set ini ke true untuk kondisi disable
    bool isDisabled = true;

    return SizedBox(
      width: 80,
      height: 80,
      child: AbsorbPointer(
        absorbing: isDisabled, // Mencegah interaksi jika true
        child: FloatingActionButton(
          // Menyetel onPressed ke null secara otomatis memberikan efek "disabled" pada beberapa style
          onPressed: isDisabled
              ? null
              : () {
                  // Navigator.push(...)
                },
          // Warna background saat disable biasanya menggunakan abu-abu yang lebih terang/soft
          backgroundColor: isDisabled
              ? Colors.grey.shade400
              : const Color.fromARGB(255, 145, 145, 145),
          elevation: isDisabled
              ? 0
              : 4, // Hilangkan bayangan saat disable agar terlihat "datar"
          shape: const CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: isDisabled ? Colors.white70 : Colors.white,
                size: 28,
              ),
              const SizedBox(height: 2),
              Text(
                "Transfer\nWarehouse",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: isDisabled ? Colors.white70 : Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
