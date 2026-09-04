# PRD & Arsitektur Refactoring GetX (Looping Workflow)

## 1. Executive Summary & Philosophy
Proyek ini adalah aplikasi Dashboard Perbankan (**BPR Supra**) berbasis Flutter.
Tujuan refactoring adalah merombak arsitektur aplikasi menjadi **GetX Clean Architecture & State Management**, meningkatkan modularitas, reaktivitas, testabilitas, dan kemudahan navigasi tanpa memecah fitur existing dan tanpa menyebabkan regresi fungsional (tetap zero error & 100% test pass).

### Aturan Eksekusi (1 Task Per Sesi Percakapan)
- Setiap task diselesaikan secara atomik dan terisolasi dalam 1 sesi percakapan.
- Setiap sesi wajib memvalidasi dart analyze (0 error) dan lutter test (semua passing) sebelum menandai task selesai.
- File plans/getx_refactor_prd.md bertindak sebagai *Single Source of Truth* status progress (Checklist status [ ] -> [x]).

---

## 2. Pemetaan Arsitektur Existing vs Target (GetX)

### 2.1 Arsitektur Saat Ini
- **State Management**: Campuran StatefulWidget, setState(), dan ValueNotifier (pada AuthService dan ApiClient).
- **Dependency Injection**: Pola singleton manual (AuthService(), ApiClient(), DashboardService()).
- **Navigasi**: Navigator 1.0 imperatif (Navigator.pushReplacement, MaterialPageRoute).
- **Struktur Folder**:
  `
  lib/
  ├── core/ (constants, network, presentation, security, theme)
  ├── feature/
  │   ├── auth/ (models, presentation, services)
  │   ├── home/ (model, presentation, services)
  │   ├── profile/ (presentation)
  │   ├── report/ (presentation)
  │   └── revenue/ (model, presentation)
  └── main.dart
  `

### 2.2 Target Arsitektur GetX (GetX Pattern / Clean Layering)
- **State Management**: GetxController dengan reaktivitas Rx / .obs atau update() (GetBuilder untuk list/chart performa tinggi).
- **Dependency Injection**: Bindings (Get.put(), Get.lazyPut()), memisahkan dependency initialization dari UI lifecycle.
- **Routing & Navigasi**: GetMaterialApp, GetPage, route name terpusat (AppRoutes), middleware auth (AuthMiddleware).
- **Struktur Folder Terstandarisasi**:
  `
  lib/
  ├── core/
  │   ├── constants/
  │   ├── network/
  │   ├── routes/ (app_pages.dart, app_routes.dart)
  │   ├── security/
  │   └── theme/
  ├── feature/
  │   ├── auth/
  │   │   ├── bindings/ (auth_binding.dart)
  │   │   ├── controllers/ (auth_controller.dart, login_controller.dart)
  │   │   ├── models/
  │   │   ├── presentation/
  │   │   └── services/
  │   ├── home/
  │   │   ├── bindings/ (home_binding.dart)
  │   │   ├── controllers/ (home_controller.dart, navigation_controller.dart)
  │   │   ├── model/
  │   │   ├── presentation/
  │   │   └── services/
  │   ├── profile/
  │   │   ├── bindings/ (profile_binding.dart)
  │   │   ├── controllers/ (profile_controller.dart)
  │   │   └── presentation/
  │   ├── report/
  │   │   ├── bindings/
  │   │   ├── controllers/
  │   │   └── presentation/
  │   └── revenue/
  │       ├── bindings/ (revenue_binding.dart)
  │       ├── controllers/ (revenue_controller.dart, branch_product_comparison_controller.dart)
  │       ├── model/
  │       └── presentation/
  └── main.dart
  `

---

## 3. Master Task List (Fase & Task Rinci)

### FASE 1: Foundation & Dependencies Setup
- [x] **TASK-01**: Integrasi dependencies GetX ke pubspec.yaml, verifikasi kompatibilitas versi SDK Flutter 3.13+ / Dart 3.x, dan validasi build clean.
- [x] **TASK-02**: Setup Arsitektur Routing GetX (AppRoutes dan AppPages) dan migrasi main.dart dari MaterialApp ke GetMaterialApp.

### FASE 2: Core & Service Layer Refactor
- [x] **TASK-03**: Refaktor ApiClient dan AuthService menjadi GetxService dengan Get.find() pattern, menggantikan singleton & ValueNotifier dengan Rx / GetX state stream.
- [x] **TASK-04**: Buat Global/Initial Binding (InitialBinding) untuk inisialisasi background services saat startup app.

### FASE 3: Authentication Feature Refactor
- [x] **TASK-05**: Implementasi LoginController (GetxController) untuk form validation, visual toggle password, loading state, dan error handling.
- [x] **TASK-06**: Refaktor LoginScreen & SplashScreen menjadi reactive UI menggunakan Obx / GetView<LoginController>, serta update test suite auth.

### FASE 4: Main Navigation & Shell Refactor
- [x] **TASK-07**: Implementasi NavigationController untuk bottom navigation bar dan tab management.
- [x] **TASK-08**: Refaktor MainNavigationScreen menggunakan GetX binding & controller, menghilangkan setState().

### FASE 5: Home & Dashboard Feature Refactor
- [x] **TASK-09**: Implementasi HomeController (GetxController) memisahkan business logic: fetch API, filter kantor cabang, cross-filtering produk, dan komputasi analitik eksekutif.
- [x] **TASK-10**: Refaktor HomeScreen dan widget-widget modular (KantorFilterChips, KpiSummarySection, MonthlyTrendChart, ProductBreakdownCard) menjadi reactive via Obx / GetBuilder.
- [x] **TASK-11**: Update dan validasi unit & widget test untuk Home feature.

### FASE 6: Revenue & Analytics Feature Refactor
- [x] **TASK-12**: Implementasi RevenueController & BranchProductComparisonController untuk mengelola state filter kantor cabang, filter jenis pinjaman, matrix perbandingan, dan mode chart (bar vs line).
- [x] **TASK-13**: Refaktor RevenueScreen, AllLoanProductsScreen, dan kartu komparasi produk ke reactive GetX widget.
- [x] **TASK-14**: Update dan validasi unit & benchmark test untuk Revenue & Comparison feature.

### FASE 7: Profile & Report Feature Refactor
- [x] **TASK-15**: Implementasi ProfileController (mengelola user session, data tampilan, dialog konfirmasi keluar via GetX dialog / modal).
- [x] **TASK-16**: Refaktor ProfileScreen dan KodeKolScreen (Report) menjadi GetX structure.
- [x] **TASK-17**: Update test suite profile.

### FASE 8: Final Cleanup & Regression Verification
- [x] **TASK-18**: Audit seluruh codebase: hapus unused imports, hapus sisa-sisa setState / ValueNotifier lama yang usang.
- [x] **TASK-19**: Menjalankan static analysis menyeluruh (dart analyze) dan complete test suite (flutter test) untuk memastikan 100% kelulusan tanpa peringatan.
