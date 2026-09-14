import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dashboard/feature/auth/presentation/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders BPR Supra emblem, title, subtitle, and loader', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    // Initial frame and animation start
    await tester.pump(const Duration(milliseconds: 200));

    // Verify official BPR Supra emblem is rendered with Image.asset
    final imageFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/images/bpr_emblem_red.png',
    );
    expect(imageFinder, findsOneWidget);

    // Verify title and subtitle
    expect(find.text('BPR SUPRA'), findsOneWidget);
    expect(find.text('Executive Dashboard System'), findsOneWidget);

    // Verify loader and version
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);

    // Advance clock past the 800ms delay to resolve timer and navigate away
    await tester.pump(const Duration(milliseconds: 1000));
    // Advance transition duration (300ms)
    await tester.pump(const Duration(milliseconds: 300));
  });
}
