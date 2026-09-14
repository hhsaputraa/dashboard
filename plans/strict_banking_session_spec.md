# Strict Banking In-Memory Session (Auto-Logout on App Close) Implementation Plan

> **Goal:** Terapkan standar perbankan (Strict Banking In-Memory Session): Sesi aktif (auth token) disimpan hanya di memori runtime (In-Memory RAM). Saat aplikasi ditutup/swipe up (proses mati), sesi otomatis hilang sehingga saat aplikasi dibuka kembali, user selalu diarahkan ke layar Login.

**Architecture:**
- Ubah manajemen token pada `AuthService`: Token autentikasi disimpan di memori (`rxToken` / in-memory).
- Hapus persistensi token disk permanen (`_secureStorage.write(key: AppConstants.keyAuthToken)`) saat login, atau bersihkan saat start jika ada residu.
- Tetap izinkan penyimpanan username/nama akun untuk kemudahan user ("Remember Username" non-sensitive), namun token otorisasi tidak pernah bertahan setelah proses aplikasi dimatikan.
- Saat aplikasi pertama kali dibuka (Splash Screen), `initSession()` mendapati memori kosong (`token == null`), sehingga `isAuthenticated == false` dan langsung mengarahkan user ke halaman Login.
- Saat user login dan berada di dalam aplikasi, navigasi antar menu (Home, Revenue, Report, Profile) tetap berjalan mulus menggunakan in-memory token.

**Tech Stack:** Flutter, Dart 3.13+, GetX, FlutterSecureStorage.

## Global Constraints
- Layer Isolation & Flutter AI Developer Experience Standards (`AGENTS.md`, `GEMINI.md`).
- Static Analysis: 0 errors, 0 warnings pada `dart analyze`.
- Test Suite: 100% pass pada `flutter test`.
- Hot reload via DTD MCP.
- Graphify graph update via `graphify update .`.

---

## Tasks

### Task 1: Update `AuthService` for In-Memory Session
**Files:**
- Modify: `lib/feature/auth/services/auth_service.dart`

**Implementation Details:**
1. Di `initSession()`:
   - Bersihkan residu token lama dari storage disk terenkripsi jika ada, sehingga tidak ada token persisten lintas sesi:
     ```dart
     await _secureStorage.delete(key: AppConstants.keyAuthToken);
     ```
   - Pastikan `_setToken(null)` saat cold start.
2. Di `login()`:
   - Simpan token di runtime memory state: `_setToken(token)`.
   - JANGAN simpan token ke disk storage persisten (`_secureStorage.delete(key: AppConstants.keyAuthToken)`).
   - Data profil non-sensitif (seperti nama display/username) dapat disimpan untuk autofill/greeting jika diperlukan.

### Task 2: Update Tests for In-Memory Session & Splash Navigation
**Files:**
- Modify: `test/auth/auth_service_test.dart` (jika ada) atau buat test baru
- Modify: `test/auth/splash_screen_test.dart`
- Update: `test/widget_test.dart`

### Task 3: Validation, Hot Reload, & Graphify Update
- Jalankan `dart analyze` & `flutter test`.
- Jalankan `graphify update .`.
