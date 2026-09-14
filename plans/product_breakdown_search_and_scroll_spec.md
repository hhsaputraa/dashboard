# ProductBreakdownCard Search, Bounded Height, and Scrollbar Implementation Plan

> **Goal:** Batasi tinggi kartu 'Kontribusi Berdasarkan Jenis Pinjaman' (ProductBreakdownCard) dengan batas adaptif (maks 340px), tambahkan search bar instan, dan sediakan scrollbar persisten dengan ScrollController untuk mempermudah navigasi data kredit.

**Architecture:** 
- Konversi `ProductBreakdownCard` dari `StatelessWidget` menjadi `StatefulWidget` internal (menjaga public API tetap identik).
- Tambahkan `TextEditingController` untuk pencarian realtime dan `ScrollController` untuk scroll list serta kontrol scrollbar.
- Gunakan `ConstrainedBox(maxHeight: 340)` + `Scrollbar(thumbVisibility: true, controller: _scrollController)` + `ListView.builder(controller: _scrollController, shrinkWrap: true)`.

**Tech Stack:** Flutter, Dart 3.13+, Material Design 3.

---

## Tasks

- [x] **Task 1: Update ProductBreakdownCard Widget**
  - [x] Ubah `ProductBreakdownCard` menjadi `StatefulWidget`.
  - [x] Inisialisasi `_searchController` dan `_scrollController`, bersihkan di `dispose()`.
  - [x] Tambahkan search input bar modern dengan icon pencarian, hint text, dan tombol clear saat ada teks.
  - [x] Implementasikan filter list berdasarkan nama produk (case-insensitive) dan empty state jika tidak ada hasil cocok.
  - [x] Bungkus list dengan `ConstrainedBox(maxHeight: 340)`, `Scrollbar(thumbVisibility: true, controller: _scrollController)`, dan `ListView.builder(controller: _scrollController, shrinkWrap: true)`.

- [x] **Task 2: Update Widget Tests in `test/home/home_widgets_test.dart`**
  - [x] Pastikan pengujian existing tetap lulus 100%.
  - [x] Tambahkan test case untuk interaksi pencarian (ketik query, verifikasi pemfilteran item).
  - [x] Tambahkan test case untuk tombol clear text search.
  - [x] Tambahkan test case verifikasi keberadaan `Scrollbar` dan scroll view.

- [x] **Task 3: Validation & Quality Gate**
  - [x] Jalankan `dart analyze` (wajib 0 error, 0 warning).
  - [x] Jalankan `flutter test test/home/home_widgets_test.dart` dan full test suite (72/72 tests pass).
  - [x] Jalankan `graphify update .` untuk memperbarui AST graph.
