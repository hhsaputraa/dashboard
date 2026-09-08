# Tasklist Refactoring & Improvement Fase 2

Rencana kerja bertahap untuk menerapkan 5 perbaikan arsitektur dan refactoring kode agar lebih modular, DRY, dan memiliki performa tinggi tanpa merusak fungsionalitas aplikasi (*zero breaking changes*).

---

## Prinsip & Standar Kualitas
1. **Preserve Compatibility**: Seluruh widget, API publik, dan fungsi bisnis tetap berjalan 100% identik bagi user.
2. **Layer Isolation**: Logika kalkulasi ditaruh di model/helper murni, komponen UI bersama dipusatkan di `lib/core/presentation/widgets/`.
3. **Quality Gate per Task**: Setiap selesai satu task, wajib lulus `dart analyze` (0 issue) dan `flutter test` (semua test hijau).
4. **Verifikasi Graphify**: Di akhir pengerjaan, perbarui graf dengan `graphify update .` untuk mengukur dampak peningkatan struktur kode.

---

## Daftar Tugas (Tasklist)

- [x] **Task 1: Unifikasi Modal Item Picker ke Core Shared UI**
  - [x] Pindahkan `ItemPickerBottomSheet<T, K>` ke `lib/core/presentation/widgets/item_picker_bottom_sheet.dart`.
  - [x] Hubungkan `HomeBranchComparisonCard` agar menggunakan `ItemPickerBottomSheet<ExecutiveBranchItem, int>`.
  - [x] Hapus file redundan `lib/feature/home/presentation/widgets/branch_picker_bottom_sheet.dart`.
  - [x] Sesuaikan import di `feature/revenue` dan jalankan `dart analyze` & `flutter test`.

- [x] **Task 2: Ekstraksi Shared Widget SyncStatusIndicator ke Core UI**
  - [x] Buat widget bersama `lib/core/presentation/widgets/sync_status_indicator.dart`.
  - [x] Refactor `HomeScreen` untuk menggunakan `SyncStatusIndicator`.
  - [x] Refactor `RevenueScreen` untuk menggunakan `SyncStatusIndicator`.
  - [x] Jalankan `dart analyze` & `flutter test`.

- [x] **Task 3: Dekomposisi Kalkulasi Trend pada HomeController ke Pure Helper**
  - [x] Buat helper murni `lib/feature/home/model/home_product_trend_helper.dart`.
  - [x] Delegasikan `_calculateActiveTrend` dari `HomeController` ke helper tersebut.
  - [x] Buat unit test komprehensif di `test/home/home_product_trend_helper_test.dart`.
  - [x] Jalankan `dart analyze` & `flutter test`.

- [x] **Task 4: Ekstraksi Kalkulasi pada QuarterlyGrowthChart ke Pure Helper**
  - [x] Buat helper kalkulasi `lib/feature/revenue/model/quarterly_growth_calculator.dart`.
  - [x] Delegasikan kalkulasi tier radius [92, 78, 66, 54], total, dan persentase kuartal dari widget ke helper.
  - [x] Buat unit test di `test/revenue/quarterly_growth_calculator_test.dart`.
  - [x] Jalankan `dart analyze` & `flutter test`.

- [x] **Task 5: Header Token Helper pada ApiClient**
  - [x] Tambahkan method helper `authHeaders(String? token)` pada `ApiClient`.
  - [x] Rapikan pembuatan header di `DashboardService` agar seragam dan DRY.
  - [x] Jalankan `dart analyze` & `flutter test`.

- [x] **Task 6: Graphify Update & Verifikasi Metrik Akhir**
  - [x] Jalankan `graphify update .` untuk memperbarui knowledge graph.
  - [x] Hitung metrik degree dan centrality terbaru.
  - [x] Konfirmasi seluruh test suite proyek tetap hijau 100%.
