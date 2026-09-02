import 'package:dashboard/feature/home/model/interest_record.dart';

class BranchInfo {
  final int idKantor;
  final String label;
  final double total;

  const BranchInfo({
    required this.idKantor,
    required this.label,
    required this.total,
  });
}

class ProductInfo {
  final String name;
  final double total;

  const ProductInfo({required this.name, required this.total});
}

class BranchProductSeries {
  final int idKantor;
  final String branchLabel;
  final String jenisPinjaman;
  final double total;
  final List<double> monthly; // 12 bulan

  const BranchProductSeries({
    required this.idKantor,
    required this.branchLabel,
    required this.jenisPinjaman,
    required this.total,
    required this.monthly,
  });
}

class BranchProductComparisonHelper {
  static List<BranchInfo> getAvailableBranches(List<InterestRecord> records) {
    final map = <int, double>{};
    for (final r in records) {
      double sum = 0.0;
      for (final v in r.bulanan) {
        sum += v;
      }
      map[r.idKantor] = (map[r.idKantor] ?? 0.0) + sum;
    }

    final list = map.entries.map((e) {
      return BranchInfo(
        idKantor: e.key,
        label: 'Kantor ${e.key}',
        total: e.value,
      );
    }).toList()..sort((a, b) => a.idKantor.compareTo(b.idKantor));

    return list;
  }

  static List<ProductInfo> getAvailableProducts(List<InterestRecord> records) {
    final map = <String, double>{};
    for (final r in records) {
      final name = r.jenisPinjaman.trim();
      if (name.isEmpty) continue;
      double sum = 0.0;
      for (final v in r.bulanan) {
        sum += v;
      }
      map[name] = (map[name] ?? 0.0) + sum;
    }

    final list = map.entries.map((e) {
      return ProductInfo(name: e.key, total: e.value);
    }).toList()..sort((a, b) => b.total.compareTo(a.total));

    return list;
  }

  static List<String> getTopProducts(
    List<InterestRecord> records, {
    int limit = 3,
  }) {
    return getAvailableProducts(records)
        .take(limit)
        .map((p) => p.name)
        .toList();
  }

  static Map<int, Map<String, BranchProductSeries>> buildSeriesMap({
    required List<InterestRecord> records,
    required Set<int> selectedBranchIds,
    required Set<String> selectedProducts,
  }) {
    final result = <int, Map<String, BranchProductSeries>>{};

    for (final r in records) {
      if (!selectedBranchIds.contains(r.idKantor)) continue;
      if (!selectedProducts.contains(r.jenisPinjaman)) continue;

      final branchMap = result[r.idKantor] ??= <String, BranchProductSeries>{};

      final existing = branchMap[r.jenisPinjaman];
      if (existing == null) {
        double rowTotal = 0.0;
        final monthlyCopy = List<double>.from(r.bulanan);
        while (monthlyCopy.length < 12) {
          monthlyCopy.add(0.0);
        }
        for (final v in monthlyCopy) {
          rowTotal += v;
        }

        branchMap[r.jenisPinjaman] = BranchProductSeries(
          idKantor: r.idKantor,
          branchLabel: 'Kantor ${r.idKantor}',
          jenisPinjaman: r.jenisPinjaman,
          total: rowTotal,
          monthly: monthlyCopy,
        );
      } else {
        final newMonthly = List<double>.filled(12, 0.0);
        for (int i = 0; i < 12; i++) {
          final m1 = i < existing.monthly.length ? existing.monthly[i] : 0.0;
          final m2 = i < r.bulanan.length ? r.bulanan[i] : 0.0;
          newMonthly[i] = m1 + m2;
        }
        double newTotal = 0.0;
        for (final v in newMonthly) {
          newTotal += v;
        }
        branchMap[r.jenisPinjaman] = BranchProductSeries(
          idKantor: r.idKantor,
          branchLabel: 'Kantor ${r.idKantor}',
          jenisPinjaman: r.jenisPinjaman,
          total: newTotal,
          monthly: newMonthly,
        );
      }
    }

    return result;
  }
}
