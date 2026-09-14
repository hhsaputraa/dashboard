# App Startup & Splash Screen Performance Optimization Plan

> **Goal:** Mengoptimalkan waktu startup aplikasi dan transisi splash screen agar instan, ringan di perangkat low-end (HP kentang), dan tidak memblokir thread saat inisialisasi jaringan atau disk storage.

**Architecture:**
- Hilangkan double-initialization `initSession()` antara `main.dart` dan `SplashScreen`.
- Jadikan panggilan `fetchProfile()` di `AuthService.initSession()` bersifat asynchronous non-blocking (`unawaited`).
- Pangkas artificial delay `SplashScreen` dari 2000ms menjadi 800ms, serta kurangi durasi transisi layar menjadi 300ms.
- Perbarui unit test di `test/auth/splash_screen_test.dart` dan jalankan benchmark sebelum vs sesudah.

**Tech Stack:** Flutter, Dart 3.13+, GetX, flutter_secure_storage.

## Global Constraints
- Layer Isolation & Flutter AI Developer Experience Standards (`AGENTS.md`, `GEMINI.md`).
- Static Analysis: 0 errors, 0 warnings pada `dart analyze`.
- Test Suite: 100% pass pada `flutter test`.
- Hot reload via DTD MCP.
- Graphify graph update via `graphify update .`.

---

## Tasks

### Task 1: Optimize `AuthService.initSession` (Non-blocking network sync)
**Files:**
- Modify: `lib/feature/auth/services/auth_service.dart`

**Changes:**
- Di `initSession()`, setelah token dan cache lokal terbaca, panggil `unawaited(fetchProfile())` alih-alih `await fetchProfile()`.

### Task 2: Optimize `SplashScreen` Latency & Transitions
**Files:**
- Modify: `lib/feature/auth/presentation/splash_screen.dart`

**Changes:**
- Pangkas delay dari `2000ms` menjadi `800ms`.
- Jika sesi sudah diinisialisasi sebelumnya di `main()`, jangan lakukan re-initialization berulang yang memberatkan I/O storage.
- Pangkas durasi transisi manual dari `600ms` menjadi `300ms`.

### Task 3: Update & Add Startup Benchmarks / Tests
**Files:**
- Modify: `test/auth/splash_screen_test.dart`
- Create: `test/auth/startup_benchmark_test.dart`

### Task 4: Validation & Quality Gate
- Run `dart analyze` & `flutter test`.
- Update Graphify graph via `graphify update .`.
