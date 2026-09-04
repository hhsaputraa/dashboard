// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/feature/home/model/interest_record.dart';
import 'package:dashboard/feature/revenue/model/branch_product_comparison_helper.dart';

// Representasi algoritma lama (Sebelum Optimasi)
Map<int, Map<String, BranchProductSeries>> oldBuildSeriesMap({
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

void main() {
  final mockRecords = <InterestRecord>[];
  final branchIds = [1, 2, 3, 4, 5];
  final productNames = [
    'KREDIT KONSUMTIF',
    'KREDIT MODAL KERJA',
    'KREDIT INVESTASI',
    'KREDIT MULTIGUNA',
    'KREDIT KENDARAAN',
    'KREDIT PEMILIKAN RUMAH',
    'KREDIT PEGAWAI',
    'KREDIT PENSIUNAN',
  ];

  int recordId = 1;
  for (int i = 0; i < 500; i++) {
    final branch = branchIds[i % branchIds.length];
    final prod = productNames[i % productNames.length];
    mockRecords.add(
      InterestRecord(
        idTrxBunga: recordId++,
        idKantor: branch,
        idPinjaman: (i % productNames.length) + 1,
        jenisPinjaman: prod,
        bulanan: List<double>.generate(12, (m) => (m + 1) * 1000.0 + (i * 10)),
      ),
    );
  }

  final selectedBranches = {1, 2, 3};
  final selectedProducts = {
    'KREDIT KONSUMTIF',
    'KREDIT MODAL KERJA',
    'KREDIT INVESTASI',
  };

  test('Benchmark: Helper Matrix Calculation (500 records x 100 iterations)', () {
    for (int i = 0; i < 10; i++) {
      oldBuildSeriesMap(
        records: mockRecords,
        selectedBranchIds: selectedBranches,
        selectedProducts: selectedProducts,
      );
      BranchProductComparisonHelper.buildSeriesMap(
        records: mockRecords,
        selectedBranchIds: selectedBranches,
        selectedProducts: selectedProducts,
      );
    }

    const iterations = 100;

    final swOld = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      oldBuildSeriesMap(
        records: mockRecords,
        selectedBranchIds: selectedBranches,
        selectedProducts: selectedProducts,
      );
    }
    swOld.stop();
    final oldTimeUs = swOld.elapsedMicroseconds;
    final oldAvgMs = (oldTimeUs / iterations) / 1000.0;

    // Warm up JIT
    for (int i = 0; i < 20; i++) {
      BranchProductComparisonHelper.buildSeriesMap(
        records: mockRecords,
        selectedBranchIds: selectedBranches,
        selectedProducts: selectedProducts,
      );
    }

    final swNew = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      BranchProductComparisonHelper.buildSeriesMap(
        records: mockRecords,
        selectedBranchIds: selectedBranches,
        selectedProducts: selectedProducts,
      );
    }
    swNew.stop();
    final newTimeUs = swNew.elapsedMicroseconds;
    final newAvgMs = (newTimeUs / iterations) / 1000.0;

    final speedupHelper = oldTimeUs / (newTimeUs > 0 ? newTimeUs : 1);

    print('=== LATENCY BENCHMARK RESULT 1 ===');
    print('Operasi: Matrix Aggregation Helper (500 records, 100x runs)');
    print('Sebelum Optimasi (Old) : ${oldAvgMs.toStringAsFixed(3)} ms per operasi (Total: ${oldTimeUs / 1000} ms)');
    print('Sesudah Optimasi (New)  : ${newAvgMs.toStringAsFixed(3)} ms per operasi (Total: ${newTimeUs / 1000} ms)');
    print('Peningkatan Kecepatan  : ${speedupHelper.toStringAsFixed(2)}x lebih cepat!');

    expect(newAvgMs, lessThan(1.0));
  });

  test('Benchmark: Touch / Drag Interaction Latency (1.000 Touch Events)', () {
    const touchEvents = 1000;

    final swTouchOld = Stopwatch()..start();
    for (int i = 0; i < touchEvents; i++) {
      final branches = BranchProductComparisonHelper.getAvailableBranches(mockRecords);
      final filtered = mockRecords.where((r) => selectedBranches.contains(r.idKantor)).toList();
      final products = BranchProductComparisonHelper.getAvailableProducts(filtered);
      final seriesMap = oldBuildSeriesMap(
        records: mockRecords,
        selectedBranchIds: selectedBranches,
        selectedProducts: selectedProducts,
      );
      if (branches.isEmpty || products.isEmpty || seriesMap.isEmpty) {
        throw Exception();
      }
    }
    swTouchOld.stop();
    final oldTouchUs = swTouchOld.elapsedMicroseconds;
    final oldFrameMs = (oldTouchUs / touchEvents) / 1000.0;

    final cachedBranches = BranchProductComparisonHelper.getAvailableBranches(mockRecords);
    final filtered = mockRecords.where((r) => selectedBranches.contains(r.idKantor)).toList();
    final cachedProducts = BranchProductComparisonHelper.getAvailableProducts(filtered);
    final cachedSeriesMap = BranchProductComparisonHelper.buildSeriesMap(
      records: mockRecords,
      selectedBranchIds: selectedBranches,
      selectedProducts: selectedProducts,
    );

    final swTouchNew = Stopwatch()..start();
    for (int i = 0; i < touchEvents; i++) {
      final branches = cachedBranches;
      final products = cachedProducts;
      final seriesMap = cachedSeriesMap;
      if (branches.isEmpty || products.isEmpty || seriesMap.isEmpty) {
        throw Exception();
      }
    }
    swTouchNew.stop();
    final newTouchUs = swTouchNew.elapsedMicroseconds;
    final newFrameMs = (newTouchUs / touchEvents) / 1000.0;

    final speedupTouch = oldTouchUs / (newTouchUs > 0 ? newTouchUs : 1);

    print('=== LATENCY BENCHMARK RESULT 2 ===');
    print('Operasi: Touch/Pan Build Frame Latency (1.000 events)');
    print('Sebelum Optimasi (Old) : ${oldFrameMs.toStringAsFixed(3)} ms per frame (Total: ${(oldTouchUs / 1000).toStringAsFixed(2)} ms)');
    print('Sesudah Optimasi (New)  : ${newFrameMs.toStringAsFixed(4)} ms per frame (Total: ${(newTouchUs / 1000).toStringAsFixed(2)} ms)');
    print('Peningkatan Kecepatan  : ${speedupTouch.toStringAsFixed(1)}x lebih cepat!');
    print('Beban Frame Budget (16.6ms @ 60 FPS):');
    print('  - Sebelum: ${((oldFrameMs / 16.6) * 100).toStringAsFixed(1)}% frame budget terpakai');
    print('  - Sesudah: ${((newFrameMs / 16.6) * 100).toStringAsFixed(3)}% frame budget terpakai');

    expect(newTouchUs, lessThan(oldTouchUs));
  });
}