import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dashboard/feature/home/model/interest_record.dart';
import 'package:dashboard/feature/revenue/controllers/branch_product_comparison_controller.dart';
import 'package:dashboard/feature/revenue/controllers/revenue_controller.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  test('RevenueController initializes with reactive loading state', () {
    final controller = RevenueController();
    Get.put(controller);

    expect(controller.isLoading.value, isTrue);
    expect(controller.errorMessage.value, isNull);
    expect(controller.dashboardData.value, isNull);
    expect(controller.analyticsResult.value, isNull);
  });

  test('BranchProductComparisonController handles branch and product selections', () {
    final controller = BranchProductComparisonController();
    Get.put(controller);

    final mockRecords = [
      InterestRecord(
        idTrxBunga: 1,
        idKantor: 1,
        idPinjaman: 101,
        jenisPinjaman: 'Kredit Modal Kerja',
        bulanan: List<double>.filled(12, 100000),
      ),
      InterestRecord(
        idTrxBunga: 2,
        idKantor: 2,
        idPinjaman: 102,
        jenisPinjaman: 'Kredit Investasi',
        bulanan: List<double>.filled(12, 80000),
      ),
    ];

    controller.updateRecords(mockRecords);

    expect(controller.availableBranches.length, equals(2));
    expect(controller.availableProducts.length, equals(2));
    expect(controller.selectedBranchIds, isEmpty);
    expect(controller.selectedProducts, isEmpty);

    // Toggle branch
    controller.toggleBranch(1);
    expect(controller.selectedBranchIds.contains(1), isTrue);

    // Toggle product
    controller.toggleProduct('Kredit Modal Kerja');
    expect(controller.selectedProducts.contains('Kredit Modal Kerja'), isTrue);

    // Toggle view mode
    expect(controller.viewMode.value, equals(ComparisonViewMode.barTotal));
    controller.setViewMode(ComparisonViewMode.lineMonthly);
    expect(controller.viewMode.value, equals(ComparisonViewMode.lineMonthly));
  });
}
