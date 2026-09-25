# Spec: Refactoring Fitur Auth untuk Clean Architecture & Kemudahan Junior

## 1. Latar Belakang & Tujuan
Fitur autentikasi (`feature/auth`) memiliki fungsionalitas dan keamanan yang baik, namun memiliki sisa-sisa migrasi (*legacy tech debt*) yang membingungkan:
1. **Dual State Management**: `AuthService` mempertahankan `ValueNotifier` (@Deprecated) berdampingan dengan GetX `Rx`, menyebabkan setter memutakhirkan dua state sekaligus.
2. **Hybrid DI / Singleton**: Campuran `factory AuthService()` singleton internal dengan `Get.find<AuthService>()`.
3. **Magic Numbers**: Parsing JSON di `UserModel` menggunakan integer mentah (`7` untuk admin, `1` untuk active) tanpa penjelasan konstanta.
4. **Navigasi Ganda di SplashScreen**: Percabangan `Get.offNamed` vs `Navigator.pushReplacement`.

## 2. Rincian Perubahan
- **`lib/core/constants/app_constants.dart`**:
  - Menambahkan konstanta role pengguna (misal: `roleAdminFlag = 7`).
- **`lib/feature/auth/models/user_model.dart`**:
  - Menggunakan konstanta role agar jelas tujuannya.
- **`lib/feature/auth/services/auth_service.dart`**:
  - Menghapus field `ValueNotifier` deprecated (`currentUser`, `currentToken`, `isCheckingAuth`).
  - Menggunakan GetX reactive properties secara konsisten (`rxUser`, `rxToken`, `rxIsCheckingAuth`).
  - Menyederhanakan setter internal `_setUser`, `_setToken`, `_setCheckingAuth`.
  - Menggunakan `AuthService.to` sebagai accessor resmi GetX.
- **`lib/feature/auth/controllers/login_controller.dart`**:
  - Mengakses `AuthService` langsung via `AuthService.to` alih-alih `Get.isRegistered ? ... : ...`.
- **`lib/feature/auth/presentation/login_screen.dart`**:
  - Mengubah deklarasi controller menjadi bersih via `Get.find<LoginController>()` (didukung oleh `AuthBinding`).
- **`lib/feature/auth/presentation/splash_screen.dart`**:
  - Menyederhanakan navigasi langsung menggunakan GetX `Get.offNamed()`.
- **`test/core/initial_binding_test.dart`**:
  - Memperbarui pengujian untuk memverifikasi `rxToken`, `rxUser`, `isAuthenticated` tanpa bergantung pada ValueNotifier yang sudah dihapus.

## 3. Kriteria Validasi
- `dart analyze` lolos tanpa error / warning.
- Unit tests `flutter test test/auth/` dan `flutter test test/core/` berhasil.
