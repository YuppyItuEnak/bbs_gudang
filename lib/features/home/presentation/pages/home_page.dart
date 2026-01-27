import 'package:bbs_gudang/data/services/home/history_gudang_repository.dart';
import 'package:bbs_gudang/data/services/penerimaan_barang/penerimaan_barang_repository.dart';
import 'package:bbs_gudang/data/services/pengeluaran_barang/pengeluaran_barang_repository.dart';
import 'package:bbs_gudang/data/services/stock_adjustment/stock_adjustment_repository.dart';
import 'package:bbs_gudang/data/services/stock_opname/stock_opname_repository.dart';
import 'package:bbs_gudang/data/services/transfer_warehouse/transfer_warehouse_repository.dart';
import 'package:bbs_gudang/features/home/presentation/providers/history_gudang_provider.dart';
import 'package:bbs_gudang/features/home/presentation/widgets/home_header_card.dart';
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

      if (token != null) {
        provider.fetchHistoryGudang(token: token);

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
      const TransferWarehousePage(),
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
            DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.45,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return HomeHistorySection(scrollController: scrollController);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFAB() {
    return SizedBox(
      width: 80,
      height: 80,
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransferWarehousePage()),
          );
          // final cobaRepo = PengeluaranBarangRepository();
          // final token = context.read<AuthProvider>().token;
          // final data = cobaRepo.fetchListPengeluaranBrg(token: token!);
          // print("Data Fetching Repo: $data");
        },
        backgroundColor: const Color(0xFFFFC107),
        elevation: 4,
        shape: const CircleBorder(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
            SizedBox(height: 2),
            Text(
              "Transfer\nWarehouse",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
