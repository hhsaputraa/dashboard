import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/dashboard/presentation/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen renders welcome message and logout button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    expect(find.text('BPR SUPRA Sistem Information'), findsOneWidget);
    expect(find.text('Selamat Datang di dashboard'), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
  });
}
