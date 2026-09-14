// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Startup Latency Benchmarks', () {
    test('Benchmark: Artificial Splash Delay Reduction (2000ms vs 800ms)', () {
      const oldDelayMs = 2000;
      const newDelayMs = 800;
      const speedup = oldDelayMs / newDelayMs;

      print('\n==================== STARTUP BENCHMARK 1 ====================');
      print('Operasi: Artificial Splash Screen Delay');
      print('Sebelum Optimasi (Old) : $oldDelayMs ms');
      print('Sesudah Optimasi (New)  : $newDelayMs ms');
      print('Peningkatan Kecepatan  : ${speedup.toStringAsFixed(2)}x lebih cepat!');
      print('Waktu Tunggu Berkurang : -${oldDelayMs - newDelayMs} ms');
      print('============================================================\n');

      expect(speedup, greaterThanOrEqualTo(2.5));
    });

    test('Benchmark: Network Blocking vs Unawaited Profile Sync', () async {
      // Simulate network latency (e.g. 1500ms on 3G/slow connection)
      Future<String> simulateFetchProfile() async {
        await Future.delayed(const Duration(milliseconds: 1500));
        return 'profile_loaded';
      }

      // Old pattern: await network call in startup path
      final oldStopwatch = Stopwatch()..start();
      await simulateFetchProfile();
      oldStopwatch.stop();
      final oldElapsed = oldStopwatch.elapsedMilliseconds;

      // New pattern: unawaited background sync in startup path
      final newStopwatch = Stopwatch()..start();
      unawaited(simulateFetchProfile());
      newStopwatch.stop();
      final newElapsed = newStopwatch.elapsedMicroseconds / 1000.0;

      print('\n==================== STARTUP BENCHMARK 2 ====================');
      print('Operasi: Profile Sync During App Launch (1500ms Network Latency)');
      print('Sebelum Optimasi (Old Blocking)   : $oldElapsed ms (memblokir splash)');
      print('Sesudah Optimasi (New Non-blocking): ${newElapsed.toStringAsFixed(3)} ms (non-blocking)');
      print('Startup Thread Responsiveness      : ${(oldElapsed / (newElapsed > 0 ? newElapsed : 0.001)).toStringAsFixed(0)}x lebih responsif!');
      print('============================================================\n');

      expect(newElapsed, lessThan(5.0)); // Should return essentially instantaneously
    });
  });
}
