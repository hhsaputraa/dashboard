# Tasklist Security Hardening: Paket 1 (Network & Platform Hardening)

Rencana kerja implementasi pengerasan keamanan mobile (*Mobile Security Hardening*) sesuai standar **OWASP MASVS-NETWORK** dan **MASVS-CODE**.

---

## 1. Sasaran & Lingkup Perubahan
1. **Network Security Config (Android)**:
   - Batasi traffic cleartext (HTTP) hanya untuk lingkungan lokal/emulator (`localhost`, `10.0.2.2`, `127.0.0.1`) pada debug build.
   - Wajibkan HTTPS secara ketat pada Release build (`cleartextTrafficPermitted="false"`).
   - Buat file `android/app/src/main/res/xml/network_security_config.xml`.
   - Perbarui `android:networkSecurityConfig` di `AndroidManifest.xml` dan hapus `android:usesCleartextTraffic="true"`.
2. **ProGuard / R8 Code Shrinking & Obfuscation**:
   - Aktifkan `isMinifyEnabled = true` dan `isShrinkResources = true` pada blok `buildTypes.release` di `build.gradle.kts`.
   - Buat konfigurasi rules `android/app/proguard-rules.pro` yang melindungi class data model Flutter, GetX, dan native plugin.
3. **URL Validation & HTTPS Enforcement pada ServerConfigDialog**:
   - Validasi skema URL agar mewajibkan HTTPS untuk domain publik non-lokal.
   - Izinkan HTTP hanya jika host adalah loopback/local IP (`localhost`, `127.0.0.1`, `10.0.2.2`, `192.168.x.x`).
   - Tampilkan pesan peringatan keamanan jika user mencoba menyimpan URL non-HTTPS untuk domain publik.
4. **Quality Gate**:
   - `dart analyze` (0 issue).
   - `flutter test` (semua 65 tests lulus 100%).

---

## 2. Daftar Tugas (Tasklist)

- [x] **Task 1.1: Buat Android Network Security Config & Update AndroidManifest**
  - [x] Buat `android/app/src/main/res/xml/network_security_config.xml`.
  - [x] Update `AndroidManifest.xml` untuk mereferensikan network security config dan menghapus cleartext traffic global.
- [x] **Task 1.2: Konfigurasi ProGuard / R8 Obfuscation pada Android Gradle**
  - [x] Buat `android/app/proguard-rules.pro` dengan rules Flutter, GetX, crypto, dan secure storage.
  - [x] Aktifkan `isMinifyEnabled = true` dan `isShrinkResources = true` di `android/app/build.gradle.kts`.
- [x] **Task 1.3: URL Validator & HTTPS Enforcer pada Server Config & ApiClient**
  - [x] Buat helper validator `lib/core/security/url_security_validator.dart`.
  - [x] Integrasikan validasi pada `ServerConfigDialog` sebelum test koneksi & save.
  - [x] Buat unit test di `test/core/url_security_validator_test.dart`.
- [x] **Task 1.4: Verifikasi Kualitas & Regression Testing**
  - [x] Jalankan `dart analyze` (0 error, 0 warning).
  - [x] Jalankan `flutter test` (semua test lulus).
