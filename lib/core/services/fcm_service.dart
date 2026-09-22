import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final RxnString tokenRx = RxnString();
  final RxnString apnsTokenRx = RxnString();
  final RxnString apnsErrorRx = RxnString();
  final RxBool isLoading = false.obs;
  final RxString statusMessage = 'Belum terhubung'.obs;

  Future<void> init({bool isManualRetry = false}) async {
    isLoading.value = true;
    statusMessage.value = 'Menghubungkan ke FCM & APNs...';
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

      // 2. Pada iOS, tunggu APNs token dengan polling loop (hingga 15 detik)
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken;
        for (int i = 0; i < 15; i++) {
          apnsToken = await _fcm.getAPNSToken();
          if (apnsToken != null) {
            developer.log('APNs Token didapat pada detik ke-$i: $apnsToken', name: 'FCM');
            break;
          }
          await Future.delayed(const Duration(seconds: 1));
        }

        if (apnsToken != null) {
          apnsTokenRx.value = apnsToken;
          apnsErrorRx.value = null;
          developer.log('APNs Token: $apnsToken', name: 'FCM');
        } else {
          try {
            final prefs = await SharedPreferences.getInstance();
            final nativeToken = prefs.getString('apns_device_token');
            final nativeError = prefs.getString('apns_error');
            apnsTokenRx.value = nativeToken;
            apnsErrorRx.value = nativeError;
            developer.log(
              'getAPNSToken() null. Native Token: $nativeToken, Native Error: $nativeError',
              name: 'FCM',
            );
          } catch (_) {}
          developer.log('APNs token belum siap dari getAPNSToken, mencoba _fcm.getToken()...', name: 'FCM');
        }
      }

      // 3. Ambil FCM Token perangkat
      String? token = await _fcm.getToken();
      developer.log('FCM Token: $token', name: 'FCM');
      currentToken = token;
      tokenRx.value = token;

      if (token != null) {
        statusMessage.value = 'Terhubung';
        if (isManualRetry) {
          Get.snackbar(
            'FCM Berhasil Diperbarui',
            'Token berhasil diambil ulang dari server.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF0F172A),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        statusMessage.value = 'FCM Token belum didapat dari server.';
      }

      _setupListeners();
    } catch (e, st) {
      developer.log('Error saat inisialisasi FCM: $e', name: 'FCM', error: e, stackTrace: st);
      String detail = e.toString();
      try {
        final prefs = await SharedPreferences.getInstance();
        final nativeError = prefs.getString('apns_error');
        if (nativeError != null && nativeError.isNotEmpty) {
          apnsErrorRx.value = nativeError;
          detail += ' (iOS APNs: $nativeError)';
        }
      } catch (_) {}

      statusMessage.value = detail;
      if (isManualRetry) {
        Get.snackbar(
          'Gagal Mengambil Token',
          detail,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF991B1B),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retryRegistration() async {
    await init(isManualRetry: true);
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
