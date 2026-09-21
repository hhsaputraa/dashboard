import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log(
    'Notifikasi Background Diterima: ${message.notification?.title}',
    name: 'FCM',
  );
}

class FcmService {
  FcmService._internal();
  static final FcmService instance = FcmService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    // 1. Minta izin ke pengguna (Penting untuk Android 13+ & iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    developer.log(
      'Status Izin Notifikasi: ${settings.authorizationStatus}',
      name: 'FCM',
    );

    // 2. Ambil FCM Token perangkat
    // Token ini yang nanti dikirim ke backend Anda jika ingin mengirim notif ke device ini
    String? token = await _fcm.getToken();
    developer.log('FCM Token: $token', name: 'FCM');

    // Listener jika token diperbarui oleh Firebase
    _fcm.onTokenRefresh.listen((newToken) {
      developer.log('FCM Token Refresh: $newToken', name: 'FCM');
      // TODO: Kirim token baru ke backend server jika diperlukan
    });

    // 3. Tangani notifikasi saat aplikasi sedang AKTIF / DIBUKA (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log(
        'Notifikasi Foreground: ${message.notification?.title} - ${message.notification?.body}',
        name: 'FCM',
      );
      // Di sini nanti bisa dipasang popup dialog/snackbar atau Local Notifications
    });

    // 4. Tangani saat notifikasi DIKLIK oleh user (Aplikasi di background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log(
        'Notifikasi diklik user (dari background): ${message.data}',
        name: 'FCM',
      );
      // TODO: Navigasi ke halaman tertentu berdasarkan message.data
    });

    // 5. Cek jika aplikasi dibuka DARI NOTIFIKASI saat kondisi mati total (Terminated)
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      developer.log(
        'Aplikasi dibuka dari notifikasi terminated: ${initialMessage.data}',
        name: 'FCM',
      );
    }
  }
}
