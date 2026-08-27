class InterestRecord {
  final int idTrxBunga;
  final int idKantor;
  final int idPinjaman;
  final String jenisPinjaman;
  final List<double> bulanan;

  const InterestRecord({
    required this.idTrxBunga,
    required this.idKantor,
    required this.idPinjaman,
    required this.jenisPinjaman,
    required this.bulanan,
  });

  /// Menghitung total bunga 1 tahun untuk baris ini
  double get totalTahun => bulanan.fold(0.0, (sum, val) => sum + val);

  /// Helper untuk membaca baris CSV / JSON dengan aman
  factory InterestRecord.fromList(List<dynamic> row) {
    return InterestRecord(
      idTrxBunga: int.tryParse(row[0].toString()) ?? 0,
      idKantor: int.tryParse(row[1].toString()) ?? 0,
      idPinjaman: int.tryParse(row[2].toString()) ?? 0,
      jenisPinjaman: row[3]?.toString() ?? '-',
      bulanan: List.generate(12, (index) {
        // Ambil data bulan dari index ke-4 s.d. 15
        final valStr = row.length > (4 + index)
            ? row[4 + index]?.toString()
            : '';
        return double.tryParse(valStr ?? '') ?? 0.0;
      }),
    );
  }
}
