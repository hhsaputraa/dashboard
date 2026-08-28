import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';
import 'package:dashboard/feature/home/presentation/widgets/dashboard_state_views.dart';
import 'package:dashboard/feature/home/presentation/widgets/kantor_filter_chips.dart';
import 'package:dashboard/feature/home/presentation/widgets/kpi_stat_card.dart';
import 'package:dashboard/feature/home/presentation/widgets/kpi_summary_section.dart';
import 'package:dashboard/feature/home/presentation/widgets/monthly_trend_chart.dart';
import 'package:dashboard/feature/home/presentation/widgets/product_breakdown_card.dart';

void main() {
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  group('Home Modular Widgets Tests', () {
    testWidgets('KantorFilterChips triggers callback when selected', (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KantorFilterChips(
              selectedKantor: selected,
              onKantorChanged: (newVal) => selected = newVal,
            ),
          ),
        ),
      );

      expect(find.text('Semua Kantor'), findsOneWidget);
      expect(find.text('Kantor 1'), findsOneWidget);

      await tester.tap(find.text('Kantor 1'));
      await tester.pumpAndSettle();

      expect(selected, 1);
    });

    testWidgets('KpiStatCard renders title, value and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KpiStatCard(
              title: 'Total Akun',
              value: '150 Data',
              icon: Icons.people,
              iconColor: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Total Akun'), findsOneWidget);
      expect(find.text('150 Data'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('KpiSummarySection renders total and average', (tester) async {
      const summary = DashboardSummary(
        totalYTD: 500000000,
        monthlyAverage: 41666666,
        totalAccounts: 120,
        topProduct: 'KREDIT MODAL KERJA',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KpiSummarySection(
              summary: summary,
              currencyFormat: currencyFormat,
            ),
          ),
        ),
      );

      expect(find.text('TOTAL PENDAPATAN BUNGA'), findsOneWidget);
      expect(find.text('Total Data Bunga'), findsOneWidget);
      expect(find.text('120 Data'), findsOneWidget);
      expect(find.text('MODAL KERJA'), findsOneWidget);
    });

    testWidgets('ProductBreakdownCard renders items and supports tap selection', (tester) async {
      String? selectedProduct;
      const breakdown = [
        ProductBreakdown(name: 'Kredit Modal Kerja', total: 300000, percentage: 75.0),
        ProductBreakdown(name: 'Kredit Konsumtif', total: 100000, percentage: 25.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ProductBreakdownCard(
                  breakdown: breakdown,
                  grandTotal: 400000,
                  currencyFormat: currencyFormat,
                  selectedProductName: selectedProduct,
                  onProductSelected: (val) {
                    setState(() => selectedProduct = val);
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Kontribusi Berdasarkan Jenis Kredit'), findsOneWidget);
      expect(find.text('Kredit Modal Kerja'), findsOneWidget);
      expect(find.text('Kredit Konsumtif'), findsOneWidget);

      // Verify Kredit Modal Kerja (higher total) appears before Kredit Konsumtif
      final modalKerjaPos = tester.getTopLeft(find.text('Kredit Modal Kerja'));
      final konsumtifPos = tester.getTopLeft(find.text('Kredit Konsumtif'));
      expect(modalKerjaPos.dy < konsumtifPos.dy, isTrue);

      // Tap on Kredit Modal Kerja to select
      await tester.tap(find.text('Kredit Modal Kerja'));
      await tester.pumpAndSettle();

      expect(selectedProduct, 'Kredit Modal Kerja');
      expect(find.text('Reset'), findsOneWidget);

      // Tap Reset to clear selection
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(selectedProduct, isNull);
    });

    testWidgets('MonthlyTrendChart shows custom title and triggers reset', (tester) async {
      bool resetCalled = false;
      const trend = [
        MonthlyTrendItem(month: 'Jan', total: 100000),
        MonthlyTrendItem(month: 'Feb', total: 150000),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyTrendChart(
              trend: trend,
              currencyFormat: currencyFormat,
              selectedProductName: 'Kredit Modal Kerja',
              onResetFilter: () => resetCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Tren: Kredit Modal Kerja'), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);

      await tester.tap(find.text('Semua'));
      await tester.pumpAndSettle();

      expect(resetCalled, isTrue);
    });

    testWidgets('DashboardStateViews render loading and error with retry', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const DashboardLoadingView(),
                DashboardErrorView(
                  errorMessage: 'Koneksi timeout',
                  onRetry: () => retried = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Mengambil data live dari Database Oracle...'), findsOneWidget);
      expect(find.text('Gagal Terhubung ke Database Oracle'), findsOneWidget);
      expect(find.text('Koneksi timeout'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();
      expect(retried, isTrue);
    });

    test('DashboardData.fromJson pre-sorts product breakdown descending by total', () {
      final json = {
        'summary': {'total_ytd': 400000, 'monthly_average': 33333, 'total_accounts': 10, 'top_product': 'B'},
        'monthly_trend': [],
        'product_breakdown': [
          {'name': 'A', 'total': 100000, 'percentage': 25.0},
          {'name': 'B', 'total': 300000, 'percentage': 75.0},
        ],
        'records': [],
      };

      final data = DashboardData.fromJson(json);
      expect(data.productBreakdown.length, 2);
      expect(data.productBreakdown[0].name, 'B');
      expect(data.productBreakdown[0].total, 300000);
      expect(data.productBreakdown[1].name, 'A');
      expect(data.productBreakdown[1].total, 100000);
    });
  });
}
