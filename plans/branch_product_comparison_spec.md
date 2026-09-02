# Spec: Pendapatan Perbandingan Kantor Cabang Berdasarkan Jenis Pinjaman

## 1. Overview
Fitur ini menambahkan kartu analitik komparatif multi-dimensi pada Halaman Pendapatan (`RevenueScreen`) yang memungkinkan pengguna menganalisis pendapatan berdasarkan kombinasi Kantor Cabang (max 5) dan Jenis Pinjaman (max 3).

## 2. Requirements & User Flow
1. **Filter Kantor Cabang (Maksimal 5)**:
   - Pengguna dapat memilih kantor cabang yang ingin dibandingkan (minimal 1, maksimal 5).
   - Opsi shortcut: Pilih Top Cabang / Semua Cabang default (atau 3 cabang pertama jika > 5).
2. **Filter Jenis Pinjaman (Maksimal 3)**:
   - Pengguna dapat memilih jenis pinjaman yang ingin dibandingkan (minimal 1, maksimal 3).
   - Opsi shortcut "Top 3 Pinjaman" yang otomatis memilih 3 jenis pinjaman dengan pendapatan terbesar.
3. **Visualisasi Data**:
   - **Mode Bar Chart**: Menampilkan perbandingan total pendapatan per kantor cabang dengan batang terkelompok (*grouped bar chart*) untuk masing-masing jenis pinjaman yang dipilih.
   - **Mode Line Chart**: Menampilkan perbandingan tren pendapatan bulanan (Januari s/d Desember) dari jenis pinjaman terpilih di kantor-kantor terpilih.
   - **Mode Toggle**: Segmented button / switch tabs untuk beralih antara tampilan "Totalan (Bar)" dan "Tren Bulanan (Line)".

## 3. Architecture & Layering
- **Data Source**: Menggunakan `DashboardData.records` (`List<InterestRecord>`) yang sudah disediakan oleh API `fetchDashboardData(idKantor: 0)`.
- **Model / Helper**: `BranchProductComparisonHelper` untuk memproses agregasi data total dan bulanan per cabang dan per produk.
- **Presentation**: `BranchProductComparisonCard` diletakkan di `lib/feature/revenue/presentation/widgets/`.
- **Integration**: Diintegrasikan ke dalam `RevenueScreen`.

## 4. Quality Gate
- Static analysis: `dart analyze` (0 errors, 0 warnings).
- Tests: Unit test untuk kalkulasi agregasi dan widget test untuk interaksi chart.
