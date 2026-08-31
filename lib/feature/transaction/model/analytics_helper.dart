import 'package:dashboard/feature/home/model/dashboard_data.dart';

class BranchPerformance {
  final int idKantor;
  final String label;
  final double total;
  final double percentage;

  const BranchPerformance({
    required this.idKantor,
    required this.label,
    required this.total,
    required this.percentage,
  });
}

class QuarterPerformance {
  final String quarter; // 'Q1', 'Q2', 'Q3', 'Q4'
  final String title; // 'Kuartal 1', dst
  final String monthsLabel; // 'Jan - Mar', dst
  final double total;
  final double percentage;

  const QuarterPerformance({
    required this.quarter,
    required this.title,
    required this.monthsLabel,
    required this.total,
    required this.percentage,
  });
}

class AnalyticsResult {
  final List<BranchPerformance> branches;
  final List<QuarterPerformance> quarters;
  final BranchPerformance? topBranch;
  final QuarterPerformance? topQuarter;
  final ProductBreakdown? topProduct;

  const AnalyticsResult({
    required this.branches,
    required this.quarters,
    required this.topBranch,
    required this.topQuarter,
    required this.topProduct,
  });
}

class AnalyticsHelper {
  AnalyticsHelper._();

  /// Menghitung seluruh metrik komparasi & analisis dalam 1 pass O(N) yang sangat efisien
  static AnalyticsResult computeAnalytics(DashboardData data) {
    final grandTotal = data.summary.totalYTD;

    // 1. Agregasi Kantor
    final branchMap = <int, double>{};
    for (final r in data.records) {
      final rowTotal = r.bulanan.fold(0.0, (sum, val) => sum + val);
      branchMap[r.idKantor] = (branchMap[r.idKantor] ?? 0.0) + rowTotal;
    }

    // Pastikan Kantor 1, 2, 3 ada
    for (int k = 1; k <= 3; k++) {
      branchMap.putIfAbsent(k, () => 0.0);
    }

    final branchList = branchMap.entries.map((e) {
      final pct = grandTotal > 0 ? (e.value / grandTotal) * 100 : 0.0;
      return BranchPerformance(
        idKantor: e.key,
        label: 'Kantor ${e.key}',
        total: e.value,
        percentage: pct,
      );
    }).toList()
      ..sort((a, b) => a.idKantor.compareTo(b.idKantor));

    BranchPerformance? topBranch;
    if (branchList.isNotEmpty) {
      final sortedByTotal = List<BranchPerformance>.from(branchList)
        ..sort((a, b) => b.total.compareTo(a.total));
      if (sortedByTotal.first.total > 0) {
        topBranch = sortedByTotal.first;
      }
    }

    // 2. Agregasi Kuartal (Q1 - Q4) dari monthlyTrend
    double sumTrendRange(int start, int end) {
      double sum = 0.0;
      for (int i = start; i <= end && i < data.monthlyTrend.length; i++) {
        sum += data.monthlyTrend[i].total;
      }
      return sum;
    }

    final q1 = sumTrendRange(0, 2);
    final q2 = sumTrendRange(3, 5);
    final q3 = sumTrendRange(6, 8);
    final q4 = sumTrendRange(9, 11);

    final quarterList = [
      QuarterPerformance(
        quarter: 'Q1',
        title: 'Kuartal 1',
        monthsLabel: 'Jan - Mar',
        total: q1,
        percentage: grandTotal > 0 ? (q1 / grandTotal) * 100 : 0.0,
      ),
      QuarterPerformance(
        quarter: 'Q2',
        title: 'Kuartal 2',
        monthsLabel: 'Apr - Jun',
        total: q2,
        percentage: grandTotal > 0 ? (q2 / grandTotal) * 100 : 0.0,
      ),
      QuarterPerformance(
        quarter: 'Q3',
        title: 'Kuartal 3',
        monthsLabel: 'Jul - Sep',
        total: q3,
        percentage: grandTotal > 0 ? (q3 / grandTotal) * 100 : 0.0,
      ),
      QuarterPerformance(
        quarter: 'Q4',
        title: 'Kuartal 4',
        monthsLabel: 'Okt - Des',
        total: q4,
        percentage: grandTotal > 0 ? (q4 / grandTotal) * 100 : 0.0,
      ),
    ];

    QuarterPerformance? topQuarter;
    final sortedQuarters = List<QuarterPerformance>.from(quarterList)
      ..sort((a, b) => b.total.compareTo(a.total));
    if (sortedQuarters.first.total > 0) {
      topQuarter = sortedQuarters.first;
    }

    // 3. Top Product
    ProductBreakdown? topProduct;
    if (data.productBreakdown.isNotEmpty) {
      topProduct = data.productBreakdown.first;
    }

    return AnalyticsResult(
      branches: branchList,
      quarters: quarterList,
      topBranch: topBranch,
      topQuarter: topQuarter,
      topProduct: topProduct,
    );
  }
}
