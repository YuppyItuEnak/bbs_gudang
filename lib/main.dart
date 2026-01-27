import 'package:bbs_gudang/features/home/presentation/pages/home_page.dart';
import 'package:bbs_gudang/features/home/presentation/providers/history_gudang_provider.dart';
import 'package:bbs_gudang/features/penerimaan_barang/presentation/providers/penerimaan_barang_provider.dart';
import 'package:bbs_gudang/features/pengeluaran_barang/presentation/providers/pengeluaran_barang_provider.dart';
import 'package:bbs_gudang/features/quotation/presentation/providers/product_group_provider.dart';
import 'package:bbs_gudang/features/quotation/presentation/providers/product_provider.dart';
import 'package:bbs_gudang/features/quotation/presentation/providers/quotation_provider.dart';
import 'package:bbs_gudang/features/quotation/presentation/providers/top_provider.dart';
import 'package:bbs_gudang/features/stock_adjustment/presentation/providers/stock_adjustment_provider.dart';
import 'package:bbs_gudang/features/stock_opname/presentation/providers/stock_opname_provider.dart';
import 'package:bbs_gudang/features/transfer_warehouse/presentation/providers/transfer_warehouse_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'core/widgets/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuotationProvider()),
        ChangeNotifierProvider(create: (_) => TopProvider()),
        ChangeNotifierProvider(create: (_) => ProductGroupProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => HistoryGudangProvider()),
        ChangeNotifierProvider(create: (_) => TransferWarehouseProvider()),
        ChangeNotifierProvider(create: (_) => PenerimaanBarangProvider()),
        ChangeNotifierProvider(create: (_) => StockOpnameProvider()),
        ChangeNotifierProvider(create: (_) => StockAdjustmentProvider()),
        ChangeNotifierProvider(create: (_) => PengeluaranBarangProvider()),
      ],
      child: MaterialApp(
        title: 'MBG QL App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const _RootPage(),
      ),
    );
  }
}

class _RootPage extends StatefulWidget {
  const _RootPage();

  @override
  State<_RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<_RootPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SplashScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return authProvider.isAuthenticated
            ? const HomePage()
            : const LoginPage();
      },
    );
  }
}
