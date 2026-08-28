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

  /// Deserialisasi dari JSON response backend Go / Oracle
  factory InterestRecord.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final monthKeys = [
      'januari',
      'februari',
      'maret',
      'april',
      'mei',
      'juni',
      'juli',
      'agustus',
      'september',
      'oktober',
      'november',
      'desember',
    ];

    return InterestRecord(
      idTrxBunga: int.tryParse(json['id_trx_bunga']?.toString() ?? '') ?? 0,
      idKantor: int.tryParse(json['id_kantor']?.toString() ?? '') ?? 0,
      idPinjaman: int.tryParse(json['id_pinjaman']?.toString() ?? '') ?? 0,
      jenisPinjaman: json['jenis_pinjaman']?.toString() ?? '-',
      bulanan: monthKeys.map((k) => parseDouble(json[k])).toList(),
    );
  }
}
