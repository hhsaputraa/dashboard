import 'package:fl_chart/fl_chart.dart';
import 'dashboard_data.dart';

/// Hasil kalkulasi data tren bulanan untuk visualisasi grafik.
class MonthlyTrendCalculationResult {
  final List<FlSpot> spots;
  final double chartMaxY;
  final double yInterval;
  final double totalBunga;

  const MonthlyTrendCalculationResult({
    required this.spots,
    required this.chartMaxY,
    required this.yInterval,
    required this.totalBunga,
  });

  /// Mengkalkulasi spots, maxY, dan total secara efisien dari `List<MonthlyTrendItem>`.
  factory MonthlyTrendCalculationResult.compute(List<MonthlyTrendItem> trend) {
    double maxY = 0;
    double totalBunga = 0;
    final spots = <FlSpot>[];

    for (int i = 0; i < trend.length; i++) {
      final val = trend[i].total;
      if (val > maxY) maxY = val;
      totalBunga += val;
      spots.add(FlSpot(i.toDouble(), val));
    }

    if (maxY == 0) maxY = 1000000;
    final chartMaxY = maxY / 0.93;
    final yInterval = (chartMaxY / 5).clamp(1.0, double.infinity);

    return MonthlyTrendCalculationResult(
      spots: spots,
      chartMaxY: chartMaxY,
      yInterval: yInterval,
      totalBunga: totalBunga,
    );
  }

  /// Memformat angka besar menjadi format ringkas (rb, jt, M).
  static String formatCompactValue(double value) {
    if (value <= 0) return '0';
    if (value >= 1000000000) {
      final v = value / 1000000000;
      return '${v.toStringAsFixed(v >= 10 ? 0 : 1)} M';
    } else if (value >= 1000000) {
      final v = value / 1000000;
      return '${v.toStringAsFixed(v >= 10 ? 0 : 1)} jt';
    } else if (value >= 1000) {
      final v = value / 1000;
      return '${v.toStringAsFixed(v >= 10 ? 0 : 1)} rb';
    }
    return value.toStringAsFixed(0);
  }
}
