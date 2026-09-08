# Tasklist Refactoring: Dekomposisi God Nodes & Bridges

Dokumen ini berisi rencana kerja bertahap untuk mendekomposisi God Nodes dan Bridge Nodes yang teridentifikasi oleh Graphify tanpa merusak fungsi yang sedang berjalan (*zero breaking changes*).

---

## Prinsip Kerja & Batasan Refactoring
1. **Preserve Public API**: Nama widget, konstruktor, method publik, dan parameter tidak boleh berubah agar kode pemanggil tetap utuh.
2. **Layer Isolation**: UI hanya merender data siap pakai; kalkulasi matematika dan format data didelegasikan ke model/helper murni.
3. **Quality Gate per Task**: Setiap selesai satu task, wajib lulus dart analyze (0 error, 0 warning) dan lutter test (55 passing tests).
4. **Graphify Verification**: Setelah seluruh task selesai, perbarui graf dengan graphify update . untuk memvalidasi penurunan ketergantungan simpul.

---

## Daftar Tugas (Tasklist)

- [x] **Task 1: Decouple Service Dependency (DashboardService -> AuthService)**
  - [x] Tambahkan dependency injection via GetX / optional parameter pada DashboardService.
  - [x] Hindari inisialisasi hardcoded inal AuthService _authService = AuthService();.
  - [x] Jalankan dart analyze & lutter test.

- [x] **Task 2: Modularisasi UI God Component HomeBranchComparisonCard (60 edges)**
  - [x] Ekstrak modal pemilih cabang (BranchPickerBottomSheet) ke widget terpisah.
  - [x] Sederhanakan delegasi state modal dan dekomposisi widget.
  - [x] Pastikan HomeBranchComparisonCard tetap memiliki antarmuka publik yang persis sama.
  - [x] Jalankan dart analyze & lutter test.

- [x] **Task 3: Dekomposisi God Component BranchProductComparisonCard (70 edges, centrality 0.092)**
  - [x] Ekstrak modal pemilih generik (ItemPickerBottomSheet) ke widget terpisah.
  - [x] Reduksi kompleksitas kode kartu komparasi produk (-360 baris).
  - [x] Pastikan isolasi layer dan kontrak seleksi item terjaga.
  - [x] Pastikan seluruh interaksi gesture dan touch responsif tetap identik.
  - [x] Jalankan dart analyze & lutter test.

- [x] **Task 4: Refactor Caching & Helper pada MonthlyTrendChart (39 edges)**
  - [x] Ekstrak model kalkulasi MonthlyTrendCalculationResult & ormatCompactValue.
  - [x] Sederhanakan method _recomputeSpots dan state internal widget.
  - [x] Jalankan dart analyze & lutter test (ditambah 3 unit test baru).

- [x] **Task 5: Verifikasi Hasil Refactoring dengan Graphify**
  - [x] Jalankan graphify update . untuk memperbarui knowledge graph.
  - [x] Bandingkan degree (edges) dan betweenness centrality sebelum dan sesudah refactoring.
  - [x] Konfirmasi semua pengujian aplikasi tetap hijau (58/58 passed, 0 error).