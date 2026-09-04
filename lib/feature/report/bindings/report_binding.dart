import 'package:get/get.dart';
import '../controllers/report_controller.dart';

/// Binding untuk modul Laporan / Kode KOL.
class ReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportController>(() => ReportController());
  }
}
