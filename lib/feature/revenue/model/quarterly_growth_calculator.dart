import 'package:dashboard/feature/revenue/model/analytics_helper.dart';

/// Calculation result containing total quarters amount and rank-based radius mapping.
class QuarterRadiusComputationResult {
  final double totalQuarters;
  final Map<int, double> baseRadiusMap;

  const QuarterRadiusComputationResult({
    required this.totalQuarters,
    required this.baseRadiusMap,
  });
}

/// Pure helper responsible for ranking, total calculation, and radius assignment
/// for QuarterlyGrowthChart sections.
class QuarterlyGrowthCalculator {
  static const List<double> defaultTierRadii = [92.0, 78.0, 66.0, 54.0];
  static const double fallbackRadius = 54.0;

  /// Calculates total revenue across quarters and generates a radius mapping
  /// based on descending ranking of performance.
  static QuarterRadiusComputationResult computeRadiiAndTotal({
    required List<QuarterPerformance> quarters,
    List<double> tierRadii = defaultTierRadii,
  }) {
    double total = 0.0;
    for (final q in quarters) {
      total += q.total;
    }

    final sortedIndices = List<int>.generate(quarters.length, (i) => i)
      ..sort((a, b) => quarters[b].total.compareTo(quarters[a].total));

    final radiusMap = <int, double>{};
    for (int rank = 0; rank < sortedIndices.length; rank++) {
      final itemIndex = sortedIndices[rank];
      radiusMap[itemIndex] = rank < tierRadii.length ? tierRadii[rank] : fallbackRadius;
    }

    return QuarterRadiusComputationResult(
      totalQuarters: total,
      baseRadiusMap: radiusMap,
    );
  }
}
