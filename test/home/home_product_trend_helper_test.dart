import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';
import 'package:dashboard/feature/home/model/home_product_trend_helper.dart';
import 'package:dashboard/feature/home/model/interest_record.dart';

void main() {
  group('HomeProductTrendHelper Tests', () {
    final defaultMonthlyTrend = [
      const MonthlyTrendItem(month: 'Jan', total: 1000),
      const MonthlyTrendItem(month: 'Feb', total: 2000),
    ];

    final dummySummary = const DashboardSummary(
      totalYTD: 10000000,
      monthlyAverage: 833333,
      totalAccounts: 100,
      topProduct: 'Kredit Modal Kerja',
    );

    test('returns default data.monthlyTrend when selectedProduct is null or empty', () {
      final data = DashboardData(
        summary: dummySummary,
        monthlyTrend: defaultMonthlyTrend,
        productBreakdown: [],
        records: [],
      );

      final resultNull = HomeProductTrendHelper.calculateActiveTrend(
        data: data,
        selectedProduct: null,
      );
      expect(resultNull, equals(defaultMonthlyTrend));

      final resultEmpty = HomeProductTrendHelper.calculateActiveTrend(
        data: data,
        selectedProduct: '   ',
      );
      expect(resultEmpty, equals(defaultMonthlyTrend));
    });

    test('aggregates 12 months correctly when records match selectedProduct', () {
      final records = [
        const InterestRecord(
          idTrxBunga: 1,
          idKantor: 1,
          idPinjaman: 101,
          jenisPinjaman: 'Kredit Modal Kerja',
          bulanan: [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200],
        ),
        const InterestRecord(
          idTrxBunga: 2,
          idKantor: 2,
          idPinjaman: 102,
          jenisPinjaman: 'kredit modal kerja', // case insensitive
          bulanan: [50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50],
        ),
        const InterestRecord(
          idTrxBunga: 3,
          idKantor: 1,
          idPinjaman: 103,
          jenisPinjaman: 'Kredit Investasi',
          bulanan: [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120],
        ),
      ];

      final data = DashboardData(
        summary: dummySummary,
        monthlyTrend: defaultMonthlyTrend,
        productBreakdown: [],
        records: records,
      );

      final result = HomeProductTrendHelper.calculateActiveTrend(
        data: data,
        selectedProduct: 'Kredit Modal Kerja',
      );

      expect(result.length, equals(12));
      expect(result[0].month, equals('Jan'));
      expect(result[0].total, equals(150.0)); // 100 + 50
      expect(result[1].total, equals(250.0)); // 200 + 50
      expect(result[11].month, equals('Des'));
      expect(result[11].total, equals(1250.0)); // 1200 + 50
    });

    test('falls back to productBreakdown with predefined monthlyTrend if available', () {
      final customProductTrend = [
        const MonthlyTrendItem(month: 'Jan', total: 300),
        const MonthlyTrendItem(month: 'Feb', total: 600),
      ];

      final product = ProductBreakdown(
        name: 'Kredit Konsumtif',
        total: 5000000,
        percentage: 50.0,
        monthlyTrend: customProductTrend,
      );

      final data = DashboardData(
        summary: dummySummary,
        monthlyTrend: defaultMonthlyTrend,
        productBreakdown: [product],
        records: [],
      );

      final result = HomeProductTrendHelper.calculateActiveTrend(
        data: data,
        selectedProduct: 'Kredit Konsumtif',
      );

      expect(result, equals(customProductTrend));
    });

    test('scales monthlyTrend by ratio when productBreakdown has no predefined trend', () {
      final product = const ProductBreakdown(
        name: 'Kredit Konsumtif',
        total: 2000000, // 20% of totalYTD (10,000,000)
        percentage: 20.0,
        monthlyTrend: null,
      );

      final data = DashboardData(
        summary: dummySummary,
        monthlyTrend: defaultMonthlyTrend,
        productBreakdown: [product],
        records: [],
      );

      final result = HomeProductTrendHelper.calculateActiveTrend(
        data: data,
        selectedProduct: 'Kredit Konsumtif',
      );

      expect(result.length, equals(2));
      expect(result[0].total, closeTo(200.0, 0.001)); // 1000 * 0.2
      expect(result[1].total, closeTo(400.0, 0.001)); // 2000 * 0.2
    });
  });
}
