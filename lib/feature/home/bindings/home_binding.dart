import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/navigation_controller.dart';
import 'package:dashboard/feature/profile/controllers/profile_controller.dart';
import 'package:dashboard/feature/report/controllers/report_controller.dart';

/// Binding untuk Home & MainNavigationScreen.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<ReportController>(() => ReportController());
  }
}
