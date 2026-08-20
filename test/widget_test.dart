import 'package:flutter_test/flutter_test.dart';

import 'package:dashboard/main.dart';

void main() {
  testWidgets('App renders LoginScreen smoke test', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BankDashboardApp());
    await tester.pumpAndSettle();

    // Verify that Login Screen elements are rendered.
    expect(find.text('BPR SUPRA Sistem Information'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
