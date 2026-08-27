import '../model/interest_record.dart';

class SnapshotData {
  final String id;
  final String label;
  final DateTime date;
  final List<InterestRecord> records;

  const SnapshotData({
    required this.id,
    required this.label,
    required this.date,
    required this.records,
  });
}

class DummySnapshotRepository {
  /// Daftar nama bulan untuk sumbu X grafik
  static const List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Ags',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Raw data contoh dari file CSV yang kamu berikan
  static final List<InterestRecord> _sampleData10Aug = [
    InterestRecord.fromList([
      '109',
      '1',
      '29',
      'KREDIT PA EKA',
      '1000001',
      '1000002',
      '1000003',
      '1000004',
      '1000005',
      '1000006',
      '1000007',
      '1000008',
      '1000009',
      '1000010',
      '1000011',
      '1000012',
    ]),
    InterestRecord.fromList([
      '110',
      '2',
      '31',
      'KREDIT PA HARI',
      '',
      '',
      '',
      '',
      '',
      '2000001',
      '2000002',
      '2000003',
      '2000004',
      '2000005',
      '2000006',
      '2000007',
    ]),
    InterestRecord.fromList([
      '111',
      '3',
      '27',
      'KREDIT PA ASEP',
      '3000001',
      '3000002',
      '3000003',
      '3000004',
      '3000005',
      '3000006',
      '3000007',
      '3000008',
      '3000009',
      '3000010',
      '3000011',
      '3000012',
    ]),
    InterestRecord.fromList([
      '112',
      '1',
      '28',
      'KREDIT PA YURI',
      '4000001',
      '4000002',
      '4000003',
      '4000004',
      '4000005',
      '4000006',
      '4000007',
      '4000008',
      '4000009',
      '4000010',
      '4000011',
      '4000012',
    ]),
    InterestRecord.fromList([
      '113',
      '2',
      '31',
      'KREDIT PA HARI',
      '5000001',
      '5000002',
      '5000003',
      '5000004',
      '5000005',
      '5000006',
      '5000007',
      '5000008',
      '5000009',
      '5000010',
      '5000011',
      '5000012',
    ]),
    InterestRecord.fromList([
      '114',
      '3',
      '29',
      'KREDIT PA EKA',
      '6000001',
      '6000002',
      '6000003',
      '6000004',
      '6000005',
      '6000006',
      '6000007',
      '6000008',
      '6000009',
      '6000010',
      '6000011',
      '6000012',
    ]),
    InterestRecord.fromList([
      '117',
      '3',
      '30',
      'KREDIT PA BANGKIT',
      '9000001',
      '9000002',
      '9000003',
      '9000004',
      '9000005',
      '9000006',
      '9000007',
      '9000008',
      '9000009',
      '9000010',
      '9000011',
      '9000012',
    ]),
    InterestRecord.fromList([
      '136',
      '1',
      '27',
      'KREDIT PA ASEP',
      '4257342',
      '8997333',
      '2392815',
      '190377',
      '8181465',
      '9948714',
      '6550998',
      '1014510',
      '9683116',
      '6104324',
      '8800634',
      '8633703',
    ]),
    InterestRecord.fromList([
      '137',
      '2',
      '31',
      'KREDIT PA HARI',
      '8062900',
      '8185605',
      '5002801',
      '7174106',
      '6739281',
      '3133067',
      '7970974',
      '',
      '9061568',
      '3134093',
      '2442311',
      '4866847',
    ]),
  ];

  /// Raw data snapshot versi tgl 5 (lebih sedikit / variasi nilai)
  static final List<InterestRecord> _sampleData05Aug = [
    InterestRecord.fromList([
      '109',
      '1',
      '29',
      'KREDIT PA EKA',
      '1000001',
      '1000002',
      '1000003',
      '1000004',
      '1000005',
      '1000006',
      '1000007',
      '1000008',
      '',
      '',
      '',
      '',
    ]),
    InterestRecord.fromList([
      '111',
      '3',
      '27',
      'KREDIT PA ASEP',
      '3000001',
      '3000002',
      '3000003',
      '3000004',
      '3000005',
      '3000006',
      '3000007',
      '',
      '',
      '',
      '',
      '',
    ]),
    InterestRecord.fromList([
      '112',
      '1',
      '28',
      'KREDIT PA YURI',
      '4000001',
      '4000002',
      '4000003',
      '4000004',
      '4000005',
      '4000006',
      '4000007',
      '',
      '',
      '',
      '',
      '',
    ]),
    InterestRecord.fromList([
      '117',
      '3',
      '30',
      'KREDIT PA BANGKIT',
      '9000001',
      '9000002',
      '9000003',
      '9000004',
      '9000005',
      '9000006',
      '9000007',
      '',
      '',
      '',
      '',
      '',
    ]),
  ];

  /// Daftar Snapshot yang tersedia untuk dipilih oleh user
  static final List<SnapshotData> availableSnapshots = [
    SnapshotData(
      id: 'snap-2',
      label: 'Posisi 10 Ags 2026 (Terbaru)',
      date: DateTime(2026, 8, 10),
      records: _sampleData10Aug,
    ),
    SnapshotData(
      id: 'snap-1',
      label: 'Posisi 05 Ags 2026 (Awal Bulan)',
      date: DateTime(2026, 8, 5),
      records: _sampleData05Aug,
    ),
  ];

  // --- FUNGSI-FUNGSI KALKULASI & AGREGASI ---

  /// 1. Hitung total bunga tahunan
  static double calculateGrandTotal(List<InterestRecord> records) {
    return records.fold(0.0, (sum, r) => sum + r.totalTahun);
  }

  /// 2. Hitung total nominal per bulan (List 12 angka: Jan s.d. Des)
  static List<double> calculateMonthlyTotals(List<InterestRecord> records) {
    final totals = List<double>.filled(12, 0.0);
    for (final r in records) {
      for (int i = 0; i < 12; i++) {
        totals[i] += r.bulanan[i];
      }
    }
    return totals;
  }

  /// 3. Hitung distribusi kontribusi per jenis pinjaman
  static Map<String, double> calculateProductTotals(
    List<InterestRecord> records,
  ) {
    final map = <String, double>{};
    for (final r in records) {
      map[r.jenisPinjaman] = (map[r.jenisPinjaman] ?? 0.0) + r.totalTahun;
    }
    return map;
  }
}
