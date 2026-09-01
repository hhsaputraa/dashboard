import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';
import 'package:dashboard/feature/home/model/executive_analytics_helper.dart';
import 'package:dashboard/feature/home/presentation/widgets/dashboard_state_views.dart';
import 'package:dashboard/feature/home/presentation/widgets/hhi_concentration_card.dart';
import 'package:dashboard/feature/home/presentation/widgets/home_branch_comparison_card.dart';
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

      expect(find.text('Mengambil data...'), findsOneWidget);
      expect(find.text('Gagal Terhubung ke Server'), findsOneWidget);
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

    test('ExecutiveAnalyticsHelper computes HHI and branch comparison correctly', () {
      const summary = DashboardSummary(
        totalYTD: 1000000,
        monthlyAverage: 83333,
        totalAccounts: 10,
        topProduct: 'KREDIT A',
      );
      const breakdown = [
        ProductBreakdown(name: 'Kredit A', total: 600000, percentage: 60.0),
        ProductBreakdown(name: 'Kredit B', total: 400000, percentage: 40.0),
      ];
      final data = DashboardData(
        summary: summary,
        monthlyTrend: const [],
        productBreakdown: breakdown,
        records: const [],
      );

      final result = ExecutiveAnalyticsHelper.compute(data);
      // HHI = 60^2 + 40^2 = 3600 + 1600 = 5200 (High Risk)
      expect(result.hhi.score, 5200.0);
      expect(result.hhi.riskLevel, HhiRiskLevel.highRisk);
      expect(result.hhi.label, 'Konsentrasi Tinggi');
      expect(result.branches.length, 3);
    });

    testWidgets('HhiConcentrationCard renders HHI score and status badge', (tester) async {
      const hhi = HhiResult(
        score: 1850.0,
        riskLevel: HhiRiskLevel.moderate,
        label: 'Konsentrasi Sedang',
        dominantProduct: 'MODAL KERJA',
        dominantPercentage: 35.0,
        description: 'Portofolio cukup terdiversifikasi.',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HhiConcentrationCard(hhi: hhi),
          ),
        ),
      );

      expect(find.text('Diversifikasi Portofolio (HHI)'), findsOneWidget);
      expect(find.text('Konsentrasi Sedang'), findsOneWidget);
      expect(find.text('1850'), findsOneWidget);
      expect(find.text('/ 10.000 poin'), findsOneWidget);
    });

    testWidgets('HomeBranchComparisonCard renders multi-line branch chart and chips', (tester) async {
      final branches = [
        const ExecutiveBranchItem(
          idKantor: 1,
          label: 'Kantor 1',
          total: 500000,
          percentage: 50.0,
          monthlyTrend: [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120],
        ),
        const ExecutiveBranchItem(
          idKantor: 2,
          label: 'Kantor 2',
          total: 300000,
          percentage: 30.0,
          monthlyTrend: [5, 15, 25, 35, 45, 55, 65, 75, 85, 95, 105, 115],
        ),
        const ExecutiveBranchItem(
          idKantor: 3,
          label: 'Kantor 3',
          total: 200000,
          percentage: 20.0,
          monthlyTrend: [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeBranchComparisonCard(
                branches: branches,
                topBranch: branches[0],
                bankAverageMonthlyTrend: const [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60],
                bankAverageTotal: 333333,
                currencyFormat: currencyFormat,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Komparasi Tren Cabang'), findsOneWidget);
      expect(find.text('Top 3'), findsOneWidget);
      expect(find.text('3 Terendah'), findsOneWidget);
      expect(find.text('Benchmark Rata-rata'), findsOneWidget);
      expect(find.text('Kantor 1'), findsAtLeast(1));
      expect(find.text('Kantor 2'), findsAtLeast(1));
      expect(find.text('Kantor 3'), findsAtLeast(1));

      // Tap 3 Terendah mode
      await tester.tap(find.text('3 Terendah'));
      await tester.pumpAndSettle();
    });
  });
}
