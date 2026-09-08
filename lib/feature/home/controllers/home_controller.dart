import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../model/dashboard_data.dart';
import '../model/executive_analytics_helper.dart';
import '../model/home_product_trend_helper.dart';
import '../presentation/widgets/kantor_filter_chips.dart';
import '../services/dashboard_service.dart';

/// Controller untuk mengelola data dashboard eksekutif, filter kantor, cross-filtering produk,
/// dan agregasi tren bulanan secara reaktif.
class HomeController extends GetxController {
  final DashboardService dashboardService = Get.isRegistered<DashboardService>()
      ? Get.find<DashboardService>()
      : DashboardService();

  static final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  static const List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static const Color statusLoadingColor = Color(0xFFEAB308);
  static const Color statusErrorColor = Color(0xFFEF4444);
  static const Color statusSuccessColor = Color(0xFF22C55E);

  final RxInt selectedKantor = 0.obs;
  final RxList<OfficeOption> availableOffices = <OfficeOption>[
    const OfficeOption(0, 'Semua Kantor'),
  ].obs;
  final RxnString selectedProduct = RxnString();
  final RxList<MonthlyTrendItem> activeTrend = <MonthlyTrendItem>[].obs;

  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<DashboardData> dashboardData = Rxn<DashboardData>();
  final Rxn<ExecutiveAnalyticsResult> executiveResult = Rxn<ExecutiveAnalyticsResult>();
  final Rx<DateTime> lastFetched = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = null;
    selectedProduct.value = null;
    activeTrend.clear();

    try {
      final data = await dashboardService.fetchDashboardData(
        idKantor: selectedKantor.value,
      );
      final execResult = ExecutiveAnalyticsHelper.compute(data);

      dashboardData.value = data;
      executiveResult.value = execResult;

      // Update daftar kantor dinamis dari records yang ditemukan
      final currentKnownIds = availableOffices
          .where((o) => o.id > 0)
          .map((o) => o.id)
          .toSet();
      final newIds = data.records
          .map((r) => r.idKantor)
          .where((id) => id > 0)
          .toSet();
      final allIds = (currentKnownIds..addAll(newIds)).toList()..sort();
      if (allIds.isNotEmpty) {
        availableOffices.assignAll([
          const OfficeOption(0, 'Semua Kantor'),
          ...allIds.map((id) => OfficeOption(id, 'Kantor $id')),
        ]);
      }

      isLoading.value = false;
      lastFetched.value = DateTime.now();
      recomputeActiveTrend();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      isLoading.value = false;
    }
  }

  void changeKantor(int newKantor) {
    if (selectedKantor.value != newKantor) {
      selectedKantor.value = newKantor;
      loadData();
    }
  }

  void setSelectedProduct(String? product) {
    if (selectedProduct.value == product) return;
    selectedProduct.value = product;
    recomputeActiveTrend();
  }

  void recomputeActiveTrend() {
    final data = dashboardData.value;
    if (data == null) {
      activeTrend.clear();
      return;
    }
    activeTrend.assignAll(_calculateActiveTrend(data));
  }

  List<MonthlyTrendItem> _calculateActiveTrend(DashboardData data) {
    return HomeProductTrendHelper.calculateActiveTrend(
      data: data,
      selectedProduct: selectedProduct.value,
      monthNames: monthNames,
    );
  }
}
