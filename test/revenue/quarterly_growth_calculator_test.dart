import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/feature/revenue/model/analytics_helper.dart';
import 'package:dashboard/feature/revenue/model/quarterly_growth_calculator.dart';

void main() {
  group('QuarterlyGrowthCalculator Tests', () {
    test('computes total 0 and empty radius map when quarters list is empty', () {
      final result = QuarterlyGrowthCalculator.computeRadiiAndTotal(quarters: []);
      expect(result.totalQuarters, equals(0.0));
      expect(result.baseRadiusMap, isEmpty);
    });

    test('computes total and assigns tier radii based on descending ranking', () {
      final quarters = [
        const QuarterPerformance(quarter: 'Q1', title: 'Kuartal 1', total: 1000, percentage: 10, monthsLabel: 'Jan-Mar'),
        const QuarterPerformance(quarter: 'Q2', title: 'Kuartal 2', total: 4000, percentage: 40, monthsLabel: 'Apr-Jun'),
        const QuarterPerformance(quarter: 'Q3', title: 'Kuartal 3', total: 3000, percentage: 30, monthsLabel: 'Jul-Sep'),
        const QuarterPerformance(quarter: 'Q4', title: 'Kuartal 4', total: 2000, percentage: 20, monthsLabel: 'Okt-Des'),
      ];

      final result = QuarterlyGrowthCalculator.computeRadiiAndTotal(quarters: quarters);

      expect(result.totalQuarters, equals(10000.0));
      // Ranking:
      // Rank 0: Q2 (index 1) -> 92.0
      // Rank 1: Q3 (index 2) -> 78.0
      // Rank 2: Q4 (index 3) -> 66.0
      // Rank 3: Q1 (index 0) -> 54.0
      expect(result.baseRadiusMap[1], equals(92.0));
      expect(result.baseRadiusMap[2], equals(78.0));
      expect(result.baseRadiusMap[3], equals(66.0));
      expect(result.baseRadiusMap[0], equals(54.0));
    });

    test('falls back to 54.0 radius when ranks exceed tierRadii length', () {
      final quarters = [
        const QuarterPerformance(quarter: 'Q1', title: 'K1', total: 50, percentage: 10, monthsLabel: ''),
        const QuarterPerformance(quarter: 'Q2', title: 'K2', total: 40, percentage: 10, monthsLabel: ''),
        const QuarterPerformance(quarter: 'Q3', title: 'K3', total: 30, percentage: 10, monthsLabel: ''),
        const QuarterPerformance(quarter: 'Q4', title: 'K4', total: 20, percentage: 10, monthsLabel: ''),
        const QuarterPerformance(quarter: 'Q5', title: 'K5', total: 10, percentage: 10, monthsLabel: ''),
      ];

      final result = QuarterlyGrowthCalculator.computeRadiiAndTotal(quarters: quarters);

      expect(result.totalQuarters, equals(150.0));
      expect(result.baseRadiusMap[0], equals(92.0)); // rank 0
      expect(result.baseRadiusMap[1], equals(78.0)); // rank 1
      expect(result.baseRadiusMap[2], equals(66.0)); // rank 2
      expect(result.baseRadiusMap[3], equals(54.0)); // rank 3
      expect(result.baseRadiusMap[4], equals(54.0)); // rank 4 (fallback)
    });
  });
}
