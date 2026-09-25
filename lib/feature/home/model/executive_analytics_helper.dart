import 'package:dashboard/feature/home/model/dashboard_data.dart';

enum HhiRiskLevel {
  healthy, // HHI < 1500: Terdiversifikasi Sehat
  moderate, // 1500 <= HHI <= 2500: Konsentrasi Sedang
  highRisk, // HHI > 2500: Konsentrasi Tinggi / Dominan
}

class HhiResult {
  final double score;
  final HhiRiskLevel riskLevel;
  final String label;
  final String dominantProduct;
  final double dominantPercentage;
  final String description;

  const HhiResult({
    required this.score,
    required this.riskLevel,
    required this.label,
    required this.dominantProduct,
    required this.dominantPercentage,
    required this.description,
  });
}

class ExecutiveBranchItem {
  final int idKantor;
  final String label;
  final double total;
  final double percentage;
  final List<double> monthlyTrend;

  const ExecutiveBranchItem({
    required this.idKantor,
    required this.label,
    required this.total,
    required this.percentage,
    required this.monthlyTrend,
  });
}

class ExecutiveAnalyticsResult {
  final HhiResult hhi;
  final List<ExecutiveBranchItem> branches;
  final ExecutiveBranchItem? topBranch;
  final List<double> bankAverageMonthlyTrend;
  final double bankAverageTotal;

  const ExecutiveAnalyticsResult({
    required this.hhi,
    required this.branches,
    required this.topBranch,
    required this.bankAverageMonthlyTrend,
    required this.bankAverageTotal,
  });
}

class ExecutiveAnalyticsHelper {
  ExecutiveAnalyticsHelper._();

  /// Menghitung HHI Index & Komparasi Garis Tren Kantor dalam 1 pass O(N) yang sangat efisien
  static ExecutiveAnalyticsResult compute(DashboardData data) {
    final grandTotal = data.summary.totalYTD;

    // 1. Perhitungan Herfindahl-Hirschman Index (HHI)
    double hhiSum = 0.0;
    String dominantProduct = '-';
    double dominantPercentage = 0.0;

    if (data.productBreakdown.isNotEmpty && grandTotal > 0) {
      for (final p in data.productBreakdown) {
        final pct = p.percentage > 0
            ? p.percentage
            : (p.total / grandTotal) * 100;
        hhiSum += pct * pct;

        if (pct > dominantPercentage) {
          dominantPercentage = pct;
          dominantProduct = p.name.replaceAll('KREDIT ', '');
        }
      }
    }

    HhiRiskLevel riskLevel;
    String label;
    String description;

    if (hhiSum < 1500) {
      riskLevel = HhiRiskLevel.healthy;
      label = 'Terdiversifikasi Sehat';
      description = 'Penyebaran portofolio seimbang antar produk, risiko konsentrasi rendah.';
    } else if (hhiSum <= 2500) {
      riskLevel = HhiRiskLevel.moderate;
      label = 'Konsentrasi Sedang';
      description =
          'Portofolio cukup terdiversifikasi dengan dominasi utama produk $dominantProduct (${dominantPercentage.toStringAsFixed(1)}%).';
    } else {
      riskLevel = HhiRiskLevel.highRisk;
      label = 'Konsentrasi Tinggi';
      description =
          'Ketergantungan tinggi pada produk $dominantProduct (${dominantPercentage.toStringAsFixed(1)}%). Disarankan diversifikasi produk lain.';
    }

    final hhiResult = HhiResult(
      score: hhiSum,
      riskLevel: riskLevel,
      label: label,
      dominantProduct: dominantProduct,
      dominantPercentage: dominantPercentage,
      description: description,
    );

    // 2. Agregasi Komparasi Multi-Line Tren Seluruh Kantor Cabang
    final branchTotals = <int, double>{};
    final branchMonthly = <int, List<double>>{};

    for (final r in data.records) {
      if (r.idKantor <= 0) continue;
      double rowTotal = 0.0;
      final monthly = branchMonthly[r.idKantor] ??= List<double>.filled(
        12,
        0.0,
      );
      for (int i = 0; i < 12 && i < r.bulanan.length; i++) {
        final val = r.bulanan[i];
        rowTotal += val;
        monthly[i] += val;
      }
      branchTotals[r.idKantor] = (branchTotals[r.idKantor] ?? 0.0) + rowTotal;
    }

    // Fallback jika tidak ada records sama sekali
    if (branchTotals.isEmpty) {
      for (int k = 1; k <= 3; k++) {
        branchTotals[k] = 0.0;
      }
    }

    ExecutiveBranchItem? topBranch;
    final branchList = branchTotals.entries.map((e) {
      final pct = grandTotal > 0 ? (e.value / grandTotal) * 100 : 0.0;
      final monthly = branchMonthly[e.key] ?? List<double>.filled(12, 0.0);
      final item = ExecutiveBranchItem(
        idKantor: e.key,
        label: 'Kantor ${e.key}',
        total: e.value,
        percentage: pct,
        monthlyTrend: monthly,
      );
      if (item.total > 0 &&
          (topBranch == null || item.total > topBranch!.total)) {
        topBranch = item;
      }
      return item;
    }).toList()..sort((a, b) => a.idKantor.compareTo(b.idKantor));

    // 3. Hitung Rata-Rata Seluruh Bank (Benchmark Average)
    final branchCount = branchList.isNotEmpty ? branchList.length : 1;
    final avgMonthly = List<double>.filled(12, 0.0);
    for (int m = 0; m < 12; m++) {
      double monthSum = 0.0;
      for (final b in branchList) {
        if (m < b.monthlyTrend.length) {
          monthSum += b.monthlyTrend[m];
        }
      }
      avgMonthly[m] = monthSum / branchCount;
    }

    final avgTotal = grandTotal / branchCount;

    return ExecutiveAnalyticsResult(
      hhi: hhiResult,
      branches: branchList,
      topBranch: topBranch,
      bankAverageMonthlyTrend: avgMonthly,
      bankAverageTotal: avgTotal,
    );
  }
}
