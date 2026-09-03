import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'feature/auth/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient().init();
  runApp(const BankDashboardApp());
}

class BankDashboardApp extends StatelessWidget {
  final Widget? home;
  const BankDashboardApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: child,
        );
      },
      home: home ?? const SplashScreen(),
    );
  }
}
