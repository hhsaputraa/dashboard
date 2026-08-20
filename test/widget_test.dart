import 'package:flutter_test/flutter_test.dart';

import 'package:dashboard/main.dart';

void main() {
  testWidgets('App renders Mobile LoginScreen smoke test', (
    WidgetTester tester,
  ) async {
    // Build app and trigger frame.
    await tester.pumpWidget(const BankDashboardApp());
    await tester.pumpAndSettle();

    // Verify that Login Screen elements are rendered cleanly.
    expect(find.text('BPR SUPRA'), findsOneWidget);
    expect(find.textContaining('Sistem Informasi'), findsOneWidget);
    expect(find.text('Masuk'), findsAtLeastNWidgets(1));
    expect(find.byTooltip('Pengaturan Server'), findsOneWidget);
  });
}
