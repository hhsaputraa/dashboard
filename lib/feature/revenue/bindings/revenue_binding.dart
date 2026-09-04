import 'package:get/get.dart';
import '../controllers/branch_product_comparison_controller.dart';
import '../controllers/revenue_controller.dart';

/// Binding untuk modul Pendapatan & Analitik Portofolio.
class RevenueBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RevenueController>(() => RevenueController());
    Get.lazyPut<BranchProductComparisonController>(() => BranchProductComparisonController());
  }
}
