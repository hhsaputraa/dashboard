import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dashboard/feature/report/controllers/report_controller.dart';
import 'package:dashboard/feature/report/presentation/report_screen.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('KodeKolScreen renders app bar title, summary metrics, and all 5 KOL cards',
      (WidgetTester tester) async {
    final controller = ReportController();
    Get.put(controller);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: KodeKolScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Kode KOL'), findsOneWidget);

    // Verify Summary Header
    expect(find.text('Pedoman Kolektibilitas OJK'), findsOneWidget);
    expect(find.text('Performing Loan'), findsOneWidget);
    expect(find.text('Non-Performing (NPL)'), findsOneWidget);

    // Verify Filter Chips
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('KOL 1'), findsNWidgets(2)); // Chip & Card badge
    expect(find.text('KOL 2'), findsNWidgets(2)); // Chip & Card badge
    expect(find.text('KOL 3'), findsNWidgets(2)); // Chip & Card badge
    expect(find.text('KOL 4'), findsNWidgets(2)); // Chip & Card badge
    expect(find.text('KOL 5'), findsNWidgets(2)); // Chip & Card badge

    // Verify NPL badges
    expect(find.text('NPL'), findsNWidgets(3)); // KOL 3, 4, 5
  });

  testWidgets('KodeKolScreen filtering by chip updates displayed cards reactively',
      (WidgetTester tester) async {
    final controller = ReportController();
    Get.put(controller);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: KodeKolScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on KOL 1 filter chip
    await tester.tap(find.widgetWithText(FilterChip, 'KOL 1'));
    await tester.pumpAndSettle();

    // KOL 1 card is present, KOL 5 card is no longer in list
    expect(find.text('KOL 1'), findsNWidgets(2)); // Chip & Card
    expect(find.text('KOL 5'), findsOneWidget); // Only chip exists, card is filtered out
    expect(find.text('NPL'), findsNothing); // KOL 1 has no NPL badge
  });
}
