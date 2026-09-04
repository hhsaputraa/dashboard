import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';
import 'package:dashboard/feature/home/services/dashboard_service.dart';
import '../model/analytics_helper.dart';

/// Controller untuk mengelola data pendapatan perbankan dan analitik portofolio secara reaktif.
class RevenueController extends GetxController {
  final DashboardService dashboardService = Get.isRegistered<DashboardService>()
      ? Get.find<DashboardService>()
      : DashboardService();

  static final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<DashboardData> dashboardData = Rxn<DashboardData>();
  final Rxn<AnalyticsResult> analyticsResult = Rxn<AnalyticsResult>();
  final Rx<DateTime> lastFetched = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final data = await dashboardService.fetchDashboardData(idKantor: 0);
      final analytics = AnalyticsHelper.computeAnalytics(data);

      dashboardData.value = data;
      analyticsResult.value = analytics;
      isLoading.value = false;
      lastFetched.value = DateTime.now();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      isLoading.value = false;
    }
  }
}
