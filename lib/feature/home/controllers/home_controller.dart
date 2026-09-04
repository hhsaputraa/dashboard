import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../model/dashboard_data.dart';
import '../model/executive_analytics_helper.dart';
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
    if (selectedProduct.value == null) {
      return data.monthlyTrend;
    }

    final selectedLower = selectedProduct.value!.trim().toLowerCase();

    if (data.records.isNotEmpty) {
      final monthlySums = List<double>.filled(12, 0.0);
      bool hasMatch = false;

      for (final r in data.records) {
        if (r.jenisPinjaman.trim().toLowerCase() == selectedLower) {
          hasMatch = true;
          for (int i = 0; i < 12 && i < r.bulanan.length; i++) {
            monthlySums[i] += r.bulanan[i];
          }
        }
      }

      if (hasMatch) {
        return List.generate(12, (i) {
          return MonthlyTrendItem(
            month: monthNames[i],
            total: monthlySums[i],
          );
        });
      }
    }

    for (final p in data.productBreakdown) {
      if (p.name.trim().toLowerCase() == selectedLower) {
        if (p.monthlyTrend != null && p.monthlyTrend!.isNotEmpty) {
          return p.monthlyTrend!;
        }
        if (data.summary.totalYTD > 0) {
          final ratio = p.total / data.summary.totalYTD;
          return data.monthlyTrend
              .map((m) => MonthlyTrendItem(month: m.month, total: m.total * ratio))
              .toList();
        }
        break;
      }
    }

    return data.monthlyTrend;
  }
}
