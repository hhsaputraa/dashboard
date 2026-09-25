import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../../feature/auth/services/auth_service.dart';

/// Service push notifikasi mandiri (Self-Hosted via Gorush & Native OS APNs)
/// 100% bebas dari ketergantungan Firebase SDK.
class NativePushService {
  NativePushService._internal();
  static final NativePushService instance = NativePushService._internal();

  /// Token perangkat aktif (APNs 64-hex pada iOS)
  final RxnString deviceTokenRx = RxnString();
  final RxnString errorRx = RxnString();
  final RxBool isLoading = false.obs;
  final RxString statusMessage = 'Belum terhubung'.obs;

  bool _isInitialized = false;
  bool _pendingSync = false;

  bool get isInitialized => _isInitialized;
  String? get activeToken => deviceTokenRx.value;

  /// Inisialisasi pembacaan token native dari sistem operasi
  Future<void> init({bool isManualRetry = false}) async {
    isLoading.value = true;
    statusMessage.value = 'Mendeteksi device token native...';

    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? token;

        // Coba baca token native dari SharedPreferences (disimpan oleh AppDelegate.swift)
        // Lakukan retry loop hingga 10 detik saat cold-start
        for (int i = 0; i < 10; i++) {
          final prefs = await SharedPreferences.getInstance();
          token = prefs.getString('apns_device_token');
          final error = prefs.getString('apns_error');

          if (error != null && error.isNotEmpty) {
            errorRx.value = error;
            developer.log('APNs Native Error: $error', name: 'NativePush');
          }

          if (token != null && token.isNotEmpty) {
            developer.log(
              'APNs Native Token ditemukan pada detik ke-$i: $token',
              name: 'NativePush',
            );
            break;
          }

          await Future.delayed(const Duration(seconds: 1));
        }

        if (token != null && token.isNotEmpty) {
          deviceTokenRx.value = token;
          statusMessage.value = 'Terhubung (Native APNs)';

          if (isManualRetry) {
            Get.snackbar(
              'Token Berhasil Diambil',
              'APNs Device Token aktif dan siap digunakan.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF0F172A),
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }

          // Jika ada sinkronisasi yang tertunda (user sudah login duluan), lakukan sync sekarang
          if (_pendingSync || AuthService().isAuthenticated) {
            _pendingSync = false;
            unawaited(syncDeviceToken());
          }
        } else {
          statusMessage.value = 'APNs Token belum tersedia dari Apple';
          developer.log('APNs token tidak ditemukan di SharedPreferences', name: 'NativePush');
        }
      } else {
        // Platform Android atau Web (Bisa dikembangkan untuk WebSocket / self-host push)
        statusMessage.value = 'Platform belum menggunakan native APNs';
      }

      _isInitialized = true;
    } catch (e) {
      statusMessage.value = 'Gagal inisialisasi: $e';
      developer.log('Error saat init NativePushService: $e', name: 'NativePush');
    } finally {
      isLoading.value = false;
    }
  }

  /// Sinkronkan token perangkat secara otomatis ke database Oracle melalui Go API
  Future<bool> syncDeviceToken({String? authToken}) async {
    final token = deviceTokenRx.value;
    final activeAuthToken = authToken ?? AuthService().token;

    // Jika belum login, tandai agar otomatis sync begitu user login
    if (activeAuthToken == null || activeAuthToken.isEmpty) {
      _pendingSync = true;
      developer.log('Auth token belum ada, menunda sync device token', name: 'NativePush');
      return false;
    }

    // Jika device token belum siap, tandai pending
    if (token == null || token.isEmpty) {
      _pendingSync = true;
      developer.log('Device token belum siap, menunda sync ke backend', name: 'NativePush');
      return false;
    }

    try {
      final platformStr = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
      final response = await ApiClient().post(
        '/api/user/device-token',
        token: activeAuthToken,
        body: {
          'device_token': token,
          'platform': platformStr,
        },
        timeout: const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        developer.log('Device token berhasil disinkronkan ke Oracle DB', name: 'NativePush');
        _pendingSync = false;
        return true;
      } else {
        developer.log(
          'Gagal sync device token: HTTP ${response.statusCode} - ${response.body}',
          name: 'NativePush',
        );
        return false;
      }
    } catch (e) {
      developer.log('Exception saat sync device token: $e', name: 'NativePush');
      return false;
    }
  }

  /// Nonaktifkan token di backend saat user logout
  Future<void> unregisterDeviceToken({String? authToken}) async {
    final activeAuthToken = authToken ?? AuthService().token;
    final token = deviceTokenRx.value;

    if (activeAuthToken == null || activeAuthToken.isEmpty) return;

    try {
      await ApiClient().delete(
        '/api/user/device-token',
        token: activeAuthToken,
        body: token != null && token.isNotEmpty ? {'device_token': token} : null,
        timeout: const Duration(seconds: 5),
      );
      developer.log('Device token dinonaktifkan di backend', name: 'NativePush');
    } catch (e) {
      developer.log('Gagal unregister device token: $e', name: 'NativePush');
    }
  }
}
