import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'core/bindings/initial_binding.dart';
import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/routes/app_pages.dart';
import 'core/services/fcm_service.dart'; // <- Import FcmService
import 'core/theme/app_theme.dart';
import 'feature/auth/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Setup Crashlytics (Error Reporting)
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 3. Daftarkan background handler FCM
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 4. Inisialisasi service internal aplikasi
  await ApiClient().init();
  await AuthService().initSession();

  // 5. Jalankan UI aplikasi TERLEBIH DAHULU agar layar langsung tampil (tidak blank hitam)
  runApp(const BankDashboardApp());

  // 6. Inisialisasi FCM secara non-blocking di background setelah UI ter-render
  FcmService.instance.init();
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
