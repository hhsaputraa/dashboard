# Spesifikasi Perbaikan Penyesuaian Data Riil

Dokumen ini merangkum perbaikan berdasarkan simulasi data riil pada Dashboard BPR SUPRA:

1. **Kantor Dinamis pada Filter Home**
   - Hapus hardcode kantor 1, 2, 3 di `KantorFilterChips` dan `ExecutiveAnalyticsHelper`.
   - `HomeController` mengumpulkan daftar seluruh `idKantor` unik dari `records` database.
   - Sediakan pilihan `Semua Kantor (id: 0)` dan seluruh kantor yang terdeteksi.

2. **Tipografi & Anti-Overflow Nama Kredit Panjang**
   - Mendukung nama produk panjang (misal: "KREDIT MODAL KERJA REKENING KORAN USAHA MIKRO").
   - Ganti `FittedBox` kaku yang menyusutkan teks pada `KpiStatCard` dengan `maxLines: 2` & `TextOverflow.ellipsis`.
   - Perbaiki layout pada `ProductBreakdownCard`, `AllLoanProductsScreen`, `PortfolioDonutChart`, `AnalyticsLeaderboardCard`, dan `BranchProductComparisonCard`.

3. **Visual Scaling Adaptif pada Bar Chart Komparasi Cabang & Pinjaman**
   - Mencegah batang bar kantor kecil terlihat gepeng / 0px saat dibandingkan dengan kantor raksasa.
   - Menggunakan Adaptive Visual Height dengan Minimum Visual Rod Height pada bar bernilai positif.
   - Nilai nominal Rupiah pada tooltip, label, dan kartu metrik tetap 100% riil dan akurat.
