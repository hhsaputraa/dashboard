// ignore_for_file: avoid_print
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';

// --- Algoritma Lama (Sebelum Optimasi) ---
List<ProductBreakdown> oldFilterBreakdown(List<ProductBreakdown> list, String query) {
  if (query.isEmpty) return list;
  return list
      .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
      .toList();
}

// --- Algoritma Baru (Sesudah Optimasi: Single Lowercase Query & Fast Matching) ---
class OptimizedProductFilter {
  final List<ProductBreakdown> source;
  final List<String> lowerNames;

  OptimizedProductFilter(this.source)
      : lowerNames = source.map((e) => e.name.toLowerCase()).toList(growable: false);

  List<ProductBreakdown> filter(String query) {
    if (query.isEmpty) return source;
    final q = query.toLowerCase();
    final result = <ProductBreakdown>[];
    for (int i = 0; i < source.length; i++) {
      if (lowerNames[i].contains(q)) {
        result.add(source[i]);
      }
    }
    return result;
  }
}

// --- Komponen Progress Bar Baru (Tanpa Ticker / AnimationController Overhead) ---
class FastProgressBar extends StatelessWidget {
  final double value;
  final Color foregroundColor;
  final Color backgroundColor;
  final double height;
  final BorderRadius borderRadius;

  const FastProgressBar({
    super.key,
    required this.value,
    required this.foregroundColor,
    required this.backgroundColor,
    this.height = 6.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: foregroundColor,
            borderRadius: borderRadius,
          ),
        ),
      ),
    );
  }
}

void main() {
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Generate 200 realistic banking product breakdown items
  final mockBreakdown = List<ProductBreakdown>.generate(200, (i) {
    final names = [
      'KREDIT MODAL KERJA SEKTOR PERTANIAN',
      'KREDIT KONSUMTIF MULTIGUNA PEGAWAI',
      'KREDIT INVESTASI PABRIK DAN MESIN',
      'KREDIT KEPEMILIKAN RUMAH SUBSIDI',
      'KREDIT KENDARAAN BERMOTOR KOMERSIAL',
      'KREDIT PENSIUNAN DANA TASPEN',
      'KREDIT MIKRO USAHA KECIL MENENGAH',
      'KREDIT REKENING KORAN EKSEKUTIF',
    ];
    final name = '${names[i % names.length]} TIPE ${i + 1}';
    final total = 1000000.0 * (200 - i);
    return ProductBreakdown(
      name: name,
      total: total,
      percentage: (200 - i) * 0.5,
    );
  });

  const searchQueries = ['modal', 'KONSUMTIF', 'rumah', 'tipe 15', 'pabrik', 'tidakada'];

  test('Benchmark 1: Search & Filter Algorithm Latency (200 items x 1,000 queries)', () {
    const iterations = 1000;
    final optFilter = OptimizedProductFilter(mockBreakdown);

    // Warm up
    for (int i = 0; i < 20; i++) {
      final q = searchQueries[i % searchQueries.length];
      oldFilterBreakdown(mockBreakdown, q);
      optFilter.filter(q);
    }

    // Benchmark Old
    final swOld = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      final q = searchQueries[i % searchQueries.length];
      oldFilterBreakdown(mockBreakdown, q);
    }
    swOld.stop();
    final oldTimeUs = swOld.elapsedMicroseconds;
    final oldAvgMs = (oldTimeUs / iterations) / 1000.0;

    // Benchmark New
    final swNew = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      final q = searchQueries[i % searchQueries.length];
      optFilter.filter(q);
    }
    swNew.stop();
    final newTimeUs = swNew.elapsedMicroseconds;
    final newAvgMs = (newTimeUs / iterations) / 1000.0;

    final speedup = oldTimeUs / (newTimeUs > 0 ? newTimeUs : 1);

    print('\n==================== BENCHMARK RESULT 1 ====================');
    print('Operasi: Search & Filter (200 item x 1.000 pencarian)');
    print('Sebelum Optimasi (Old) : ${oldAvgMs.toStringAsFixed(4)} ms per query (Total: ${(oldTimeUs / 1000).toStringAsFixed(2)} ms)');
    print('Sesudah Optimasi (New)  : ${newAvgMs.toStringAsFixed(4)} ms per query (Total: ${(newTimeUs / 1000).toStringAsFixed(2)} ms)');
    print('Peningkatan Kecepatan  : ${speedup.toStringAsFixed(2)}x lebih cepat!');
    print('============================================================\n');

    expect(newAvgMs, lessThan(oldAvgMs));
  });

  testWidgets('Benchmark 2: Full List Frame Render Time (shrinkWrap vs Virtualized)', (tester) async {
    // 1. Old approach: ConstrainedBox + shrinkWrap + LinearProgressIndicator
    final oldListWidget = MaterialApp(
      home: Scaffold(
        body: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 340),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 50,
            itemBuilder: (context, index) {
              final item = mockBreakdown[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.name),
                      Text(currencyFormat.format(item.total)),
                      const LinearProgressIndicator(value: 0.5),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    // 2. New approach: Virtualized itemExtent + FastProgressBar (No shrinkWrap overhead)
    final newListWidget = MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: math.min(50 * 80.0, 340.0),
          child: ListView.builder(
            itemExtent: 80.0,
            itemCount: 50,
            itemBuilder: (context, index) {
              final item = mockBreakdown[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.name),
                      Text(currencyFormat.format(item.total)),
                      const FastProgressBar(
                        value: 0.5,
                        foregroundColor: Colors.red,
                        backgroundColor: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    const frameRounds = 50;

    // Measure Old Render
    final swOld = Stopwatch()..start();
    for (int i = 0; i < frameRounds; i++) {
      await tester.pumpWidget(oldListWidget);
    }
    swOld.stop();
    final oldRenderUs = swOld.elapsedMicroseconds;
    final oldRenderAvgMs = (oldRenderUs / frameRounds) / 1000.0;

    // Measure New Render
    final swNew = Stopwatch()..start();
    for (int i = 0; i < frameRounds; i++) {
      await tester.pumpWidget(newListWidget);
    }
    swNew.stop();
    final newRenderUs = swNew.elapsedMicroseconds;
    final newRenderAvgMs = (newRenderUs / frameRounds) / 1000.0;

    final renderSpeedup = oldRenderUs / (newRenderUs > 0 ? newRenderUs : 1);

    print('\n==================== BENCHMARK RESULT 2 ====================');
    print('Operasi: Re-render Frame List (50 items x 50 frame pumps)');
    print('Sebelum Optimasi (Old) : ${oldRenderAvgMs.toStringAsFixed(3)} ms per frame');
    print('Sesudah Optimasi (New)  : ${newRenderAvgMs.toStringAsFixed(3)} ms per frame');
    print('Peningkatan Kecepatan  : ${renderSpeedup.toStringAsFixed(2)}x lebih cepat!');
    print('Frame Budget Terpakai  :');
    print('  - Sebelum: ${((oldRenderAvgMs / 16.6) * 100).toStringAsFixed(1)}% dari 60fps budget (16.6ms)');
    print('  - Sesudah: ${((newRenderAvgMs / 16.6) * 100).toStringAsFixed(1)}% dari 60fps budget (16.6ms)');
    print('============================================================\n');

    expect(newRenderAvgMs, lessThan(oldRenderAvgMs));
  });
}
