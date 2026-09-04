import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dashboard/feature/home/controllers/home_controller.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  test('HomeController initializes with default filter states', () {
    final controller = HomeController();
    Get.put(controller);

    expect(controller.selectedKantor.value, equals(0));
    expect(controller.selectedProduct.value, isNull);
    expect(controller.activeTrend, isEmpty);
  });

  test('HomeController setSelectedProduct updates filter and recomputes trend', () {
    final controller = HomeController();
    Get.put(controller);

    controller.dashboardData.value = const DashboardData(
      summary: DashboardSummary(
        totalYTD: 1000000,
        monthlyAverage: 100000,
        totalAccounts: 10,
        topProduct: 'Kredit Modal Kerja',
      ),
      records: [],
      productBreakdown: [
        ProductBreakdown(
          name: 'Kredit Modal Kerja',
          total: 600000,
          percentage: 60.0,
        ),
      ],
      monthlyTrend: [
        MonthlyTrendItem(month: 'Jan', total: 50000),
        MonthlyTrendItem(month: 'Feb', total: 50000),
      ],
    );

    controller.setSelectedProduct('Kredit Modal Kerja');
    expect(controller.selectedProduct.value, equals('Kredit Modal Kerja'));

    controller.setSelectedProduct(null);
    expect(controller.selectedProduct.value, isNull);
  });
}
