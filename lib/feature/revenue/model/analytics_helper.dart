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
  final List<ProductBreakdown>? topProducts;

  List<ProductBreakdown> get safeTopProducts => topProducts ?? const [];
  List<BranchPerformance> get safeTopBranches => branches.take(3).toList();

  const AnalyticsResult({
    required this.branches,
    required this.quarters,
    required this.topBranch,
    required this.topQuarter,
    required this.topProduct,
    this.topProducts = const [],
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
      double rowTotal = 0.0;
      for (final val in r.bulanan) {
        rowTotal += val;
      }
      branchMap[r.idKantor] = (branchMap[r.idKantor] ?? 0.0) + rowTotal;
    }

    // Fallback kantor hanya jika tidak ada record sama sekali
    if (branchMap.isEmpty) {
      for (int k = 1; k <= 3; k++) {
        branchMap[k] = 0.0;
      }
    }

    BranchPerformance? topBranch;
    final allBranches = branchMap.entries.map((e) {
      final pct = grandTotal > 0 ? (e.value / grandTotal) * 100 : 0.0;
      final perf = BranchPerformance(
        idKantor: e.key,
        label: 'Kantor ${e.key}',
        total: e.value,
        percentage: pct,
      );
      if (perf.total > 0 && (topBranch == null || perf.total > topBranch!.total)) {
        topBranch = perf;
      }
      return perf;
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total)); // Urutkan dari total pendapatan tertinggi

    final top3Branches = allBranches.take(3).toList();

    // 2. Agregasi Kuartal (Q1 - Q4) dari monthlyTrend
    double sumTrendRange(int start, int end) {
      double sum = 0.0;
      final trendLen = data.monthlyTrend.length;
      final maxIndex = end < trendLen ? end : trendLen - 1;
      for (int i = start; i <= maxIndex; i++) {
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
    for (final q in quarterList) {
      if (q.total > 0 && (topQuarter == null || q.total > topQuarter.total)) {
        topQuarter = q;
      }
    }

    // 3. Top Products (Ambil Top 5 jenis pinjaman dengan nominal tertinggi)
    ProductBreakdown? topProduct;
    final topProducts = data.productBreakdown.take(5).toList();
    if (topProducts.isNotEmpty) {
      topProduct = topProducts.first;
    }

    return AnalyticsResult(
      branches: top3Branches,
      quarters: quarterList,
      topBranch: topBranch,
      topQuarter: topQuarter,
      topProduct: topProduct,
      topProducts: topProducts,
    );
  }
}
