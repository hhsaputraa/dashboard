import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dashboard/feature/report/controllers/report_controller.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  test('ReportController initializes with 5 KOL categories and default filter 0', () {
    final controller = ReportController();
    Get.put(controller);

    expect(controller.selectedKolFilter.value, 0);
    expect(controller.searchQuery.value, '');
    expect(controller.filteredCategories.length, 5);
    expect(controller.performingCount, 2);
    expect(controller.nplCount, 3);
  });

  test('ReportController filter by specific KOL updates filteredCategories', () {
    final controller = ReportController();
    Get.put(controller);

    controller.setFilter(1);
    expect(controller.selectedKolFilter.value, 1);
    expect(controller.filteredCategories.length, 1);
    expect(controller.filteredCategories.first.kol, 1);
    expect(controller.filteredCategories.first.status, 'Lancar');

    controller.setFilter(5);
    expect(controller.filteredCategories.length, 1);
    expect(controller.filteredCategories.first.kol, 5);
    expect(controller.filteredCategories.first.status, 'Macet');
    expect(controller.filteredCategories.first.isNpl, isTrue);
  });

  test('ReportController search filters categories by keyword', () {
    final controller = ReportController();
    Get.put(controller);

    controller.setSearch('Macet');
    expect(controller.filteredCategories.length, 1);
    expect(controller.filteredCategories.first.kol, 5);

    controller.setSearch('DPK');
    expect(controller.filteredCategories.length, 1);
    expect(controller.filteredCategories.first.kol, 2);

    controller.resetFilter();
    expect(controller.selectedKolFilter.value, 0);
    expect(controller.searchQuery.value, '');
    expect(controller.filteredCategories.length, 5);
  });
}
