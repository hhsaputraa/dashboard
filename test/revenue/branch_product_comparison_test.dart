import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:dashboard/feature/home/model/interest_record.dart';
import 'package:dashboard/feature/revenue/model/branch_product_comparison_helper.dart';
import 'package:dashboard/feature/revenue/presentation/widgets/branch_product_comparison_card.dart';

void main() {
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final testRecords = [
    const InterestRecord(
      idTrxBunga: 1,
      idKantor: 1,
      idPinjaman: 1,
      jenisPinjaman: 'KREDIT KONSUMTIF',
      bulanan: [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100], // total 1200
    ),
    const InterestRecord(
      idTrxBunga: 2,
      idKantor: 1,
      idPinjaman: 2,
      jenisPinjaman: 'KREDIT MODAL KERJA',
      bulanan: [50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50], // total 600
    ),
    const InterestRecord(
      idTrxBunga: 3,
      idKantor: 2,
      idPinjaman: 1,
      jenisPinjaman: 'KREDIT KONSUMTIF',
      bulanan: [200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200], // total 2400
    ),
    const InterestRecord(
      idTrxBunga: 4,
      idKantor: 2,
      idPinjaman: 3,
      jenisPinjaman: 'KREDIT INVESTASI',
      bulanan: [80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80], // total 960
    ),
    const InterestRecord(
      idTrxBunga: 5,
      idKantor: 3,
      idPinjaman: 4,
      jenisPinjaman: 'KREDIT MULTIGUNA',
      bulanan: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10], // total 120
    ),
  ];

  group('BranchProductComparisonHelper Tests', () {
    test('getAvailableBranches sorts ascending by idKantor', () {
      final branches = BranchProductComparisonHelper.getAvailableBranches(testRecords);
      expect(branches.length, 3);
      // Kantor 1, 2, 3 ordered by idKantor
      expect(branches[0].idKantor, 1);
      expect(branches[0].total, 1800);
      expect(branches[1].idKantor, 2);
      expect(branches[1].total, 3360);
      expect(branches[2].idKantor, 3);
      expect(branches[2].total, 120);
    });

    test('getAvailableProducts sorts descending by total revenue', () {
      final products = BranchProductComparisonHelper.getAvailableProducts(testRecords);
      expect(products.length, 4);
      // KREDIT KONSUMTIF = 1200 + 2400 = 3600
      // KREDIT INVESTASI = 960
      // KREDIT MODAL KERJA = 600
      // KREDIT MULTIGUNA = 120
      expect(products[0].name, 'KREDIT KONSUMTIF');
      expect(products[0].total, 3600);
      expect(products[1].name, 'KREDIT INVESTASI');
      expect(products[1].total, 960);
      expect(products[2].name, 'KREDIT MODAL KERJA');
      expect(products[2].total, 600);
      expect(products[3].name, 'KREDIT MULTIGUNA');
      expect(products[3].total, 120);
    });

    test('getTopProducts extracts top N products', () {
      final top3 = BranchProductComparisonHelper.getTopProducts(testRecords, limit: 3);
      expect(top3, ['KREDIT KONSUMTIF', 'KREDIT INVESTASI', 'KREDIT MODAL KERJA']);
    });

    test('buildSeriesMap computes matrix accurately', () {
      final seriesMap = BranchProductComparisonHelper.buildSeriesMap(
        records: testRecords,
        selectedBranchIds: {1, 2},
        selectedProducts: {'KREDIT KONSUMTIF', 'KREDIT MODAL KERJA'},
      );

      expect(seriesMap.containsKey(1), isTrue);
      expect(seriesMap.containsKey(2), isTrue);
      expect(seriesMap.containsKey(3), isFalse);

      final k1Konsumtif = seriesMap[1]!['KREDIT KONSUMTIF']!;
      expect(k1Konsumtif.total, 1200);
      expect(k1Konsumtif.monthly.length, 12);
      expect(k1Konsumtif.monthly[0], 100);

      final k2Konsumtif = seriesMap[2]!['KREDIT KONSUMTIF']!;
      expect(k2Konsumtif.total, 2400);

      expect(seriesMap[2]!.containsKey('KREDIT MODAL KERJA'), isFalse);
    });
  });

  group('BranchProductComparisonCard Widget Tests', () {
    testWidgets('renders card with empty default selections, blocked product button, and guidance text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BranchProductComparisonCard(
                records: testRecords,
                currencyFormat: currencyFormat,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Komparasi Cabang & Pinjaman'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Tren'), findsOneWidget);

      // Default: empty selections
      expect(find.text('0 Cabang Dipilih'), findsOneWidget);
      expect(find.text('Pilih cabang dulu'), findsOneWidget);
      expect(find.text('Pilih cabang untuk mulai komparasi'), findsOneWidget);
      expect(find.text('Pilih kantor cabang terlebih dahulu'), findsOneWidget);

      // No chart before selections
      expect(find.byType(BarChart), findsNothing);
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('blocks product picker until branch is selected, then unblocks', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BranchProductComparisonCard(
                records: testRecords,
                currencyFormat: currencyFormat,
              ),
            ),
          ),
        ),
      );

      // Attempt to tap blocked product picker button
      await tester.tap(find.text('Pilih cabang dulu'));
      await tester.pump();

      // Verify snackbar is shown and modal is not opened
      expect(find.text('Pilih kantor cabang terlebih dahulu!'), findsOneWidget);
      expect(find.text('Pilih Jenis Pinjaman'), findsNothing);

      // Now pick a branch
      await tester.tap(find.text('Pilih Cabang'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Kantor Cabang'), findsOneWidget);
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Kantor 2'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Terapkan (1 Cabang)'));
      await tester.pumpAndSettle();

      // Now product button is unblocked!
      expect(find.text('1 Cabang Dipilih'), findsOneWidget);
      expect(find.text('0 Pinjaman Dipilih'), findsOneWidget);
      expect(find.text('Top 3 Pinjaman'), findsOneWidget);

      // Open product picker
      await tester.tap(find.text('Pilih Pinjaman'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Jenis Pinjaman'), findsOneWidget);
      await tester.tap(find.widgetWithText(CheckboxListTile, 'KREDIT KONSUMTIF'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Terapkan (1 Pinjaman)'));
      await tester.pumpAndSettle();

      // Chart is now rendered!
      expect(find.byType(BarChart), findsOneWidget);

      // Switch to LineChart
      await tester.tap(find.text('Tren'));
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsOneWidget);
    });
  });
}
