import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';
import 'package:dashboard/feature/home/model/monthly_trend_calculator.dart';

void main() {
  group('MonthlyTrendCalculationResult Tests', () {
    test('computes spots, total, and chartMaxY accurately for non-empty trend', () {
      final trend = [
        const MonthlyTrendItem(month: 'Jan', total: 1000000),
        const MonthlyTrendItem(month: 'Feb', total: 3000000),
        const MonthlyTrendItem(month: 'Mar', total: 2000000),
      ];

      final result = MonthlyTrendCalculationResult.compute(trend);

      expect(result.spots.length, equals(3));
      expect(result.spots[0].x, equals(0.0));
      expect(result.spots[0].y, equals(1000000.0));
      expect(result.spots[1].x, equals(1.0));
      expect(result.spots[1].y, equals(3000000.0));
      expect(result.spots[2].x, equals(2.0));
      expect(result.spots[2].y, equals(2000000.0));

      expect(result.totalBunga, equals(6000000.0));
      expect(result.chartMaxY, closeTo(3000000 / 0.93, 0.001));
      expect(result.yInterval, greaterThan(0));
    });

    test('handles empty or zero-valued trends gracefully', () {
      final result = MonthlyTrendCalculationResult.compute(const []);

      expect(result.spots, isEmpty);
      expect(result.totalBunga, equals(0.0));
      expect(result.chartMaxY, closeTo(1000000.0 / 0.93, 0.001));
      expect(result.yInterval, greaterThan(0));
    });

    test('formats compact values correctly across different magnitudes', () {
      expect(MonthlyTrendCalculationResult.formatCompactValue(0), equals('0'));
      expect(MonthlyTrendCalculationResult.formatCompactValue(-50), equals('0'));
      expect(MonthlyTrendCalculationResult.formatCompactValue(500), equals('500'));
      expect(MonthlyTrendCalculationResult.formatCompactValue(1500), equals('1.5 rb'));
      expect(MonthlyTrendCalculationResult.formatCompactValue(2500000), equals('2.5 jt'));
      expect(MonthlyTrendCalculationResult.formatCompactValue(15000000), equals('15 jt'));
      expect(MonthlyTrendCalculationResult.formatCompactValue(1200000000), equals('1.2 M'));
      expect(MonthlyTrendCalculationResult.formatCompactValue(12000000000), equals('12 M'));
    });
  });
}
