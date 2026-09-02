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
    if (records.isEmpty) return const [];
    final map = <int, double>{};
    for (final r in records) {
      double sum = 0.0;
      for (final v in r.bulanan) {
        sum += v;
      }
      map[r.idKantor] = (map[r.idKantor] ?? 0.0) + sum;
    }

    final list = <BranchInfo>[];
    for (final entry in map.entries) {
      list.add(BranchInfo(
        idKantor: entry.key,
        label: 'Kantor ${entry.key}',
        total: entry.value,
      ));
    }
    list.sort((a, b) => a.idKantor.compareTo(b.idKantor));
    return list;
  }

  static List<ProductInfo> getAvailableProducts(List<InterestRecord> records) {
    if (records.isEmpty) return const [];
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

    final list = <ProductInfo>[];
    for (final entry in map.entries) {
      list.add(ProductInfo(name: entry.key, total: entry.value));
    }
    list.sort((a, b) => b.total.compareTo(a.total));
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
    if (records.isEmpty || selectedBranchIds.isEmpty || selectedProducts.isEmpty) {
      return const {};
    }

    final accumulators = <int, Map<String, _SeriesAccumulator>>{};

    for (final r in records) {
      if (!selectedBranchIds.contains(r.idKantor)) continue;
      final jenis = r.jenisPinjaman;
      if (!selectedProducts.contains(jenis)) continue;

      final branchMap = accumulators[r.idKantor] ??= <String, _SeriesAccumulator>{};
      final acc = branchMap[jenis] ??= _SeriesAccumulator(
        idKantor: r.idKantor,
        branchLabel: 'Kantor ${r.idKantor}',
        jenisPinjaman: jenis,
      );

      acc.addMonthly(r.bulanan);
    }

    final result = <int, Map<String, BranchProductSeries>>{};
    for (final bEntry in accumulators.entries) {
      final pMap = <String, BranchProductSeries>{};
      for (final pEntry in bEntry.value.entries) {
        pMap[pEntry.key] = pEntry.value.toSeries();
      }
      result[bEntry.key] = pMap;
    }

    return result;
  }
}

class _SeriesAccumulator {
  final int idKantor;
  final String branchLabel;
  final String jenisPinjaman;
  double total = 0.0;
  final List<double> monthly = List<double>.filled(12, 0.0);

  _SeriesAccumulator({
    required this.idKantor,
    required this.branchLabel,
    required this.jenisPinjaman,
  });

  void addMonthly(List<double> values) {
    final len = values.length < 12 ? values.length : 12;
    for (int i = 0; i < len; i++) {
      final v = values[i];
      monthly[i] += v;
      total += v;
    }
  }

  BranchProductSeries toSeries() => BranchProductSeries(
    idKantor: idKantor,
    branchLabel: branchLabel,
    jenisPinjaman: jenisPinjaman,
    total: total,
    monthly: monthly,
  );
}
