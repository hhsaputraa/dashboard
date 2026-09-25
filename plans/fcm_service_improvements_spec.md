# Spec: Perbaikan FcmService

## Step 1 - Mencegah Duplikasi Listener (Selesai)
- Menambahkan flag boolean penjaga `_listenersConfigured = false;`.
- Mencegah memory leak akibat pemanggilan berulang `_setupListeners()` saat refresh token.

## Step 2 - Menampilkan In-App Notification saat Foreground (Sedang Dikerjakan)
### Masalah:
- Secara default, saat aplikasi sedang aktif dibuka (*foreground*), Firebase Cloud Messaging tidak menampilkan notifikasi pop-up/heads-up banner di Android maupun sebagian lingkungan iOS.
- Callback `FirebaseMessaging.onMessage` hanya mencatat `developer.log`, sehingga pengguna tidak mendapatkan feedback visual saat ada pesan masuk saat aplikasi aktif.

### Solusi:
- Buat method helper `_showForegroundNotification(RemoteMessage message)` yang mengekstrak `title` dan `body` dari `message.notification` atau `message.data`.
- Tampilkan *heads-up in-app notification* menggunakan `Get.snackbar` di posisi atas (`SnackPosition.TOP`) dengan styling modern banking dark-theme yang elegan.
- Berikan durasi tampilan 4 detik dan dukung *swipe to dismiss*.

### Validasi:
- `analyze_files` 0 errors.
- `flutter test` lulus.
