import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

List<Provider> getAppProviders() {
  return [Provider(create: (context) => AuthProvider())];
}
