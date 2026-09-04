import 'package:get/get.dart';
import 'package:dashboard/core/routes/app_routes.dart';
import 'package:dashboard/feature/auth/bindings/auth_binding.dart';
import 'package:dashboard/feature/auth/presentation/login_screen.dart';
import 'package:dashboard/feature/auth/presentation/splash_screen.dart';
import 'package:dashboard/feature/home/bindings/home_binding.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';
import 'package:dashboard/feature/home/presentation/home_screen.dart';
import 'package:dashboard/feature/home/presentation/main_navigation_screen.dart';
import 'package:dashboard/feature/profile/bindings/profile_binding.dart';
import 'package:dashboard/feature/profile/presentation/profile_screen.dart';
import 'package:dashboard/feature/report/bindings/report_binding.dart';
import 'package:dashboard/feature/report/presentation/report_screen.dart';
import 'package:dashboard/feature/revenue/bindings/revenue_binding.dart';
import 'package:dashboard/feature/revenue/presentation/all_loan_products_screen.dart';
import 'package:dashboard/feature/revenue/presentation/revenue_screen.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.mainNav,
      page: () => const MainNavigationScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.revenue,
      page: () => const RevenueScreen(),
      binding: RevenueBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.allLoanProducts,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final products = args?['products'] as List<ProductBreakdown>? ?? const [];
        final grandTotal = (args?['grandTotal'] as num?)?.toDouble() ?? 0.0;
        return AllLoanProductsScreen(
          products: products,
          grandTotal: grandTotal,
        );
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.report,
      page: () => const KodeKolScreen(),
      binding: ReportBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
