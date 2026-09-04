import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Model representasi kategori Kolektibilitas (KOL 1 - 5)
class KolCategory {
  final int kol;
  final String title;
  final String status;
  final String dpdRange;
  final String risk;
  final bool isNpl;
  final String provisionRate;
  final String actionGuidance;
  final Color color;

  const KolCategory({
    required this.kol,
    required this.title,
    required this.status,
    required this.dpdRange,
    required this.risk,
    required this.isNpl,
    required this.provisionRate,
    required this.actionGuidance,
    required this.color,
  });
}

/// Controller GetX untuk mengelola state dan analitik data laporan Kolektibilitas (Kode KOL)
class ReportController extends GetxController {
  final RxInt selectedKolFilter = 0.obs; // 0 = Semua, 1..5 = Kol spesifik
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  static const List<KolCategory> defaultCategories = [
    KolCategory(
      kol: 1,
      title: 'KOL 1 - Lancar',
      status: 'Lancar',
      dpdRange: '0 Hari (Tepat Waktu)',
      risk: 'Sangat Rendah',
      isNpl: false,
      provisionRate: '1% PPAP Umum',
      actionGuidance: 'Lakukan monitoring berkala dan pertahankan kedisiplinan angsuran debitur.',
      color: Color(0xFF10B981), // Emerald Green
    ),
    KolCategory(
      kol: 2,
      title: 'KOL 2 - DPK',
      status: 'Dalam Perhatian Khusus',
      dpdRange: '1 - 90 Hari',
      risk: 'Rendah - Sedang',
      isNpl: false,
      provisionRate: '5% PPAP Khusus',
      actionGuidance: 'Hubungi debitur melalui reminder telepon/kunjungan lapangan sebelum jatuh ke NPL.',
      color: Color(0xFFF59E0B), // Amber
    ),
    KolCategory(
      kol: 3,
      title: 'KOL 3 - Kurang Lancar',
      status: 'Kurang Lancar',
      dpdRange: '91 - 120 Hari',
      risk: 'Tinggi (NPL)',
      isNpl: true,
      provisionRate: '15% (setelah dikurangi agunan)',
      actionGuidance: 'Kirimkan Surat Peringatan (SP 1) dan evaluasi kemampuan restrukturisasi kredit.',
      color: Color(0xFFF97316), // Orange
    ),
    KolCategory(
      kol: 4,
      title: 'KOL 4 - Diragukan',
      status: 'Diragukan',
      dpdRange: '121 - 180 Hari',
      risk: 'Sangat Tinggi (NPL)',
      isNpl: true,
      provisionRate: '50% (setelah dikurangi agunan)',
      actionGuidance: 'Kirimkan Surat Peringatan Keras (SP 2/3) dan persiapkan negosiasi penyelesaian agunan.',
      color: Color(0xFFDC2626), // Crimson Red
    ),
    KolCategory(
      kol: 5,
      title: 'KOL 5 - Macet',
      status: 'Macet',
      dpdRange: '> 180 Hari',
      risk: 'Ekstrem (Macet / NPL)',
      isNpl: true,
      provisionRate: '100% (setelah dikurangi agunan)',
      actionGuidance: 'Lakukan upaya eksekusi agunan, sita jaminan, lelang, atau proses hukum penyelesaian kredit.',
      color: Color(0xFF991B1B), // Burgundy Deep Red
    ),
  ];

  /// Daftar kategori yang telah difilter berdasarkan chip pilihan dan search query
  List<KolCategory> get filteredCategories {
    return defaultCategories.where((category) {
      if (selectedKolFilter.value > 0 && category.kol != selectedKolFilter.value) {
        return false;
      }
      if (searchQuery.value.trim().isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final matchTitle = category.title.toLowerCase().contains(query);
        final matchStatus = category.status.toLowerCase().contains(query);
        final matchDpd = category.dpdRange.toLowerCase().contains(query);
        return matchTitle || matchStatus || matchDpd;
      }
      return true;
    }).toList();
  }

  /// Total kategori NPL
  int get nplCount => defaultCategories.where((c) => c.isNpl).length;

  /// Total kategori Perhatian / Monitoring Lancar
  int get performingCount => defaultCategories.where((c) => !c.isNpl).length;

  /// Ubah filter kategori KOL
  void setFilter(int kol) {
    selectedKolFilter.value = kol;
  }

  /// Update kata kunci pencarian
  void setSearch(String query) {
    searchQuery.value = query;
  }

  /// Bersihkan filter pencarian
  void resetFilter() {
    selectedKolFilter.value = 0;
    searchQuery.value = '';
  }

  /// Simulasi refresh laporan
  Future<void> refreshReport() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    isLoading.value = false;
  }
}
