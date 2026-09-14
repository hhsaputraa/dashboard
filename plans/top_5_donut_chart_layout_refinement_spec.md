# Top 5 Portfolio Donut Chart Layout Refinement Plan

> **Goal:** Pindahkan informasi persentase ke bagian tengah donut chart (hanya persentase), tampilkan nilai Rupiah di bawah lingkaran donut (langsung Rp tanpa label kata "Nominal/Total"), dan sederhanakan kartu item (legend card) agar hanya menampilkan nama produk.

**Architecture:**
- Hitung persentase proporsional Top 5 (`top5Percentage = (item.total / top5Total) * 100.0`).
- Di tengah donut (`Stack` center of `PieChart`):
  - Tampilkan persentase secara proporsional dan bersih: jika `_touchedIndex != -1`, tampilkan persentase produk terpilih (misal `40.0%`) dengan warna tema produk; jika default, tampilkan `100%`.
- Di bawah donut chart (sebelum Divider legend):
  - Tampilkan teks nilai Rupiah langsung: jika `_touchedIndex != -1`, format `item.total` (misal `Rp 400.000.000`); jika default, format `top5Total` (misal `Rp 1.000.000.000`).
- Di kartu item (legend card):
  - Hapus tampilan teks nilai Rupiah dan badge persentase pill.
  - Kartu hanya menampilkan bar warna indikator dan teks nama produk.
- Update unit & widget test di `test/home/home_widgets_test.dart`.

**Tech Stack:** Flutter, fl_chart, Dart 3.13+, Material 3.

## Global Constraints
- Layer Isolation & Flutter AI Developer Experience Standards (`AGENTS.md`, `GEMINI.md`).
- Static Analysis: 0 errors, 0 warnings pada `dart analyze`.
- Test Suite: 100% pass pada `flutter test`.
- Hot reload via DTD MCP.
- Graphify graph update via `graphify update .`.

---

## Tasks

### Task 1: Update `PortfolioDonutChart` Layout & Presentation
**Files:**
- Modify: `lib/feature/revenue/presentation/widgets/portfolio_donut_chart.dart`

### Task 2: Update Widget Tests
**Files:**
- Modify: `test/home/home_widgets_test.dart`

### Task 3: Validation, Hot Reload, & Graphify Update
**Files:**
- Validate: `dart analyze` & `flutter test`
- MCP Tool: `hot_reload`
- Background Task: `graphify update .`
