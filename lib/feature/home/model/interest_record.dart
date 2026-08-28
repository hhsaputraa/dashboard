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
