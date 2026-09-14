# Top 5 Portfolio Donut Chart Redesign Implementation Plan

> **Goal:** Rombak tampilan Top 5 Portofolio Produk di `PortfolioDonutChart` dengan membersihkan tampilan teks/informasi di tengah lingkaran donut (mencegah collision/tumpukan nilai) serta menghitung ulang persentase khusus untuk produk Top 5 agar total persentasenya tepat 100%.

**Architecture:**
- Hitung `top5Total` dari total nominal produk Top 5 (`items.fold(...)`).
- Hitung persentase tiap item secara proporsional terhadap `top5Total` (`item.total / top5Total * 100.0`) untuk visualisasi irisan donut dan badge persentase pada legend card.
- Kosongkan isi `Stack` tengah donut (`centerSpaceRadius` tetap proporsional atau disesuaikan agar donut seimbang dan bersih tanpa teks yang bertabrakan).
- Hilangkan teks `title` angka di atas irisan donut agar visual chart bersih dan minimalis.
- Perbarui unit & widget test di `test/home/home_widgets_test.dart`.

**Tech Stack:** Flutter, fl_chart, Dart 3.13+, Material 3.

## Global Constraints
- Layer Isolation & Flutter AI Developer Experience Standards (`AGENTS.md`, `GEMINI.md`).
- Static Analysis: 0 errors, 0 warnings pada `dart analyze`.
- Test Suite: 100% pass pada `flutter test`.
- Hot reload via DTD MCP.
- Graphify graph update via `graphify update .`.

---

## Tasks

### Task 1: Update `PortfolioDonutChart` Logic & UI
**Files:**
- Modify: `lib/feature/revenue/presentation/widgets/portfolio_donut_chart.dart`

**Implementation Details:**
1. Hitung `top5Total`:
   ```dart
   final top5Total = items.fold<double>(0.0, (sum, item) => sum + item.total);
   ```
2. Buat mapping persentase proporsional Top 5:
   ```dart
   final top5Percentage = top5Total > 0 ? (item.total / top5Total) * 100.0 : 0.0;
   ```
3. Di `PieChartData`:
   - Set `title: ''` pada semua `PieChartSectionData` (baik touched maupun tidak) sehingga tidak ada angka bertumpukan di irisan.
   - Tetapkan interaksi sentuh tetap dinamis: `radius: isTouched ? 42.0 : 34.0`.
4. Di bagian dalam lubang donut:
   - Hapus teks tumpukan (`activeProduct.name`, `percentage`, `currencyFormat`, dan `TOTAL PORTOFOLIO`).
   - Jadikan center donut bersih dan rapi.
5. Di bagian Legend Card / Item List:
   - Tampilkan persentase proporsional Top 5 (`${top5Percentage.toStringAsFixed(1)}%`) sehingga total 5 kartu berjumlah 100.0%.
   - Tetap tampilkan nominal Rupiah asli dari `item.total`.

### Task 2: Update Widget Tests
**Files:**
- Modify: `test/home/home_widgets_test.dart`

**Implementation Details:**
1. Tambahkan test case spesifik yang memverifikasi bahwa persentase yang ditampilkan pada 5 item kartu dihitung proporsional terhadap total Top 5 (menghasilkan total 100%).
2. Verifikasi tidak ada lagi teks bertabrakan atau tumpukan di tengah lingkaran donut.
3. Jalankan `flutter test test/home/home_widgets_test.dart`.

### Task 3: Validation, Hot Reload, & Graphify Update
**Files:**
- Validate: `dart analyze` & `flutter test`
- MCP Tool: `hot_reload`
- Background Task: `graphify update .`
