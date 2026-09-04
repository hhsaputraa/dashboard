import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dashboard/feature/home/controllers/navigation_controller.dart';
import 'package:dashboard/feature/home/presentation/main_navigation_screen.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  test('NavigationController initializes at index 0 and updates correctly', () {
    final controller = NavigationController();
    Get.put(controller);

    expect(controller.selectedIndex.value, equals(0));
    expect(controller.currentIndex, equals(0));

    controller.changePage(2);
    expect(controller.selectedIndex.value, equals(2));
    expect(controller.currentIndex, equals(2));

    // Changing to same index does not trigger redundant changes
    controller.changePage(2);
    expect(controller.selectedIndex.value, equals(2));
  });

  testWidgets('MainNavigationScreen renders all 4 destinations and switches tabs',
      (WidgetTester tester) async {
    final controller = Get.put(NavigationController());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: MainNavigationScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Pendapatan'), findsOneWidget);
    expect(find.text('Laporan'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    expect(controller.selectedIndex.value, equals(0));

    // Tap Pendapatan tab
    await tester.tap(find.text('Pendapatan'));
    await tester.pump();
    expect(controller.selectedIndex.value, equals(1));

    // Tap Profil tab
    await tester.tap(find.text('Profil'));
    await tester.pump();
    expect(controller.selectedIndex.value, equals(3));
  });
}
