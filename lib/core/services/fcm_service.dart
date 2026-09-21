import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

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
  String? currentToken;

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

      // Aktifkan banner pop-up saat aplikasi sedang dibuka (Foreground) di iOS
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 2. Pada iOS, tunggu APNs token dengan polling loop (hingga 25 detik)
      // Apple butuh waktu beberapa detik untuk koneksi ke APNs server
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken;
        for (int i = 0; i < 25; i++) {
          apnsToken = await _fcm.getAPNSToken();
          if (apnsToken != null) {
            developer.log('APNs Token didapat pada detik ke-$i: $apnsToken', name: 'FCM');
            break;
          }
          await Future.delayed(const Duration(seconds: 1));
        }

        if (apnsToken == null) {
          developer.log(
            'APNs token belum siap setelah 25 detik. Kemungkinan profil provisioning belum memuat entitlement push notification.',
            name: 'FCM',
          );
          _showStatusSnackbar(
            title: 'APNs Belum Siap',
            message: 'APNs token belum diberikan oleh iOS. Pastikan sertifikat memuat Push Notifications.',
            isError: true,
          );
          _setupListeners();
          return;
        }
      }

      // 3. Ambil FCM Token perangkat
      String? token = await _fcm.getToken();
      developer.log('FCM Token: $token', name: 'FCM');
      currentToken = token;

      if (token != null) {
        _showTokenSnackbar(token);
      }

      _setupListeners();
    } catch (e, st) {
      developer.log('Error saat inisialisasi FCM: $e', name: 'FCM', error: e, stackTrace: st);
      _showStatusSnackbar(
        title: 'FCM Error',
        message: 'Gagal inisialisasi: $e',
        isError: true,
      );
    }
  }

  void _showTokenSnackbar(String token) {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (Get.context != null) {
        Get.snackbar(
          'FCM Berhasil Terhubung',
          'Token: ${token.substring(0, token.length > 20 ? 20 : token.length)}... (Ketuk SALIN untuk kirim test)',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF0F172A),
          colorText: Colors.white,
          duration: const Duration(seconds: 15),
          mainButton: TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: token));
              Get.rawSnackbar(
                message: 'FCM Token berhasil disalin ke clipboard!',
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text(
              'SALIN TOKEN',
              style: TextStyle(
                color: Color(0xFF38BDF8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    });
  }

  void _showStatusSnackbar({required String title, required String message, bool isError = false}) {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (Get.context != null) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: isError ? const Color(0xFF991B1B) : const Color(0xFF0F172A),
          colorText: Colors.white,
          duration: const Duration(seconds: 8),
        );
      }
    });
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
