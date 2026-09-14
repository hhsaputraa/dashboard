import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:firebase_core/firebase_core.dart';
import 'core/bindings/initial_binding.dart';
import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/routes/app_pages.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'feature/auth/services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options != null) {
      await Firebase.initializeApp(options: options);
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('[Firebase] Init error in main: $e');
  }
  await ApiClient().init();
  await AuthService().initSession();
  await NotificationService().init();
  runApp(const BankDashboardApp());
}

class BankDashboardApp extends StatelessWidget {
  final Widget? home;
  final String? initialRoute;

  const BankDashboardApp({super.key, this.home, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: InitialBinding(),
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: child,
        );
      },
      initialRoute: home == null ? (initialRoute ?? AppPages.initial) : null,
      getPages: AppPages.routes,
      home: home,
    );
  }
}
