import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
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
    try {
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

      // 2. Pada iOS, cek ketersediaan APNs token terlebih dahulu dengan timeout.
      // Sideloaded IPA tanpa sertifikat Apple Push Notifications tidak akan menerima APNs token.
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _fcm.getAPNSToken().timeout(
          const Duration(seconds: 3),
          onTimeout: () => null,
        );
        developer.log('APNs Token: $apnsToken', name: 'FCM');

        if (apnsToken == null) {
          developer.log(
            'APNs token belum tersedia atau profil provisioning IPA belum mendukung push notification.',
            name: 'FCM',
          );
          _setupListeners();
          return;
        }
      }

      // 3. Ambil FCM Token perangkat dengan timeout aman agar tidak membekukan app
      String? token = await _fcm.getToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      developer.log('FCM Token: $token', name: 'FCM');

      _setupListeners();
    } catch (e, st) {
      developer.log('Error saat inisialisasi FCM: $e', name: 'FCM', error: e, stackTrace: st);
    }
  }

  void _setupListeners() {
    // Listener jika token diperbarui oleh Firebase
    _fcm.onTokenRefresh.listen((newToken) {
      developer.log('FCM Token Refresh: $newToken', name: 'FCM');
    });

    // Tangani notifikasi saat aplikasi sedang AKTIF / DIBUKA (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log(
        'Notifikasi Foreground: ${message.notification?.title} - ${message.notification?.body}',
        name: 'FCM',
      );
    });

    // Tangani saat notifikasi DIKLIK oleh user (Aplikasi di background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log(
        'Notifikasi diklik user: ${message.data}',
        name: 'FCM',
      );
    });

    // Cek jika aplikasi dibuka DARI NOTIFIKASI saat kondisi mati total (Terminated)
    _fcm.getInitialMessage().then((initialMessage) {
      if (initialMessage != null) {
        developer.log(
          'Aplikasi dibuka dari notifikasi terminated: ${initialMessage.data}',
          name: 'FCM',
        );
      }
    }).catchError((e) {
      developer.log('Gagal memuat initialMessage: $e', name: 'FCM');
    });
  }
}
