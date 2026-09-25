import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../../feature/auth/services/auth_service.dart';

/// Service push notifikasi mandiri (Self-Hosted via Gorush & Native OS APNs)
/// 100% bebas dari ketergantungan Firebase SDK.
class NativePushService {
  NativePushService._internal() {
    _setupMethodChannel();
  }
  static final NativePushService instance = NativePushService._internal();

  static const MethodChannel _channel = MethodChannel('com.bprsupra.dashboard/native_push');

  /// Token perangkat aktif (APNs 64-hex pada iOS)
  final RxnString deviceTokenRx = RxnString();
  final RxnString errorRx = RxnString();
  final RxBool isLoading = false.obs;
  final RxString statusMessage = 'Belum terhubung'.obs;

  bool _isInitialized = false;
  bool _pendingSync = false;

  bool get isInitialized => _isInitialized;
  String? get activeToken => deviceTokenRx.value;

  void _setupMethodChannel() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _channel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'onDeviceToken':
            final token = call.arguments as String?;
            if (token != null && token.isNotEmpty) {
              developer.log('APNs Token diterima via MethodChannel stream: $token', name: 'NativePush');
              _onTokenObtained(token);
            }
            break;
          case 'onDeviceTokenError':
            final error = call.arguments as String?;
            if (error != null && error.isNotEmpty) {
              developer.log('APNs Error diterima via MethodChannel stream: $error', name: 'NativePush');
              errorRx.value = error;
              if (deviceTokenRx.value == null || deviceTokenRx.value!.isEmpty) {
                statusMessage.value = 'iOS APNs Error: $error';
              }
            }
            break;
        }
      });
    }
  }

  void _onTokenObtained(String token, {bool isManualRetry = false}) {
    final isNewToken = deviceTokenRx.value != token;
    deviceTokenRx.value = token;
    errorRx.value = null;
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

    if (isNewToken || _pendingSync || AuthService().isAuthenticated) {
      _pendingSync = false;
      unawaited(syncDeviceToken());
    }
  }

  /// Inisialisasi pembacaan token native dari sistem operasi
  Future<void> init({bool isManualRetry = false}) async {
    isLoading.value = true;
    statusMessage.value = 'Mendeteksi device token native...';

    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? token = deviceTokenRx.value;

        // 1. Jika retry manual, minta OS untuk memicu ulang proses registrasi APNs
        if (isManualRetry) {
          try {
            await _channel.invokeMethod('requestRegistration');
          } catch (e) {
            developer.log('Gagal invoke requestRegistration: $e', name: 'NativePush');
          }
        }

        // 2. Coba minta token langsung lewat MethodChannel
        try {
          final res = await _channel.invokeMapMethod<String, String>('getDeviceToken');
          final chToken = res?['token'];
          final chError = res?['error'];

          if (chError != null && chError.isNotEmpty) {
            errorRx.value = chError;
            developer.log('APNs Native Error via getDeviceToken: $chError', name: 'NativePush');
          }

          if (chToken != null && chToken.isNotEmpty) {
            token = chToken;
            developer.log('APNs Token langsung didapat via MethodChannel: $chToken', name: 'NativePush');
          }
        } catch (e) {
          developer.log('MethodChannel getDeviceToken fallback: $e', name: 'NativePush');
        }

        // 3. Jika token belum didapat, lakukan polling retry loop hingga 10 detik
        // Mengombinasikan MethodChannel + SharedPreferences dengan reload() wajib!
        if (token == null || token.isEmpty) {
          for (int i = 0; i < 10; i++) {
            if (deviceTokenRx.value != null && deviceTokenRx.value!.isNotEmpty) {
              token = deviceTokenRx.value;
              break;
            }

            // Coba lewat MethodChannel
            try {
              final res = await _channel.invokeMapMethod<String, String>('getDeviceToken');
              final chToken = res?['token'];
              final chError = res?['error'];

              if (chError != null && chError.isNotEmpty) {
                errorRx.value = chError;
              }

              if (chToken != null && chToken.isNotEmpty) {
                token = chToken;
                developer.log('APNs Token ditemukan via MethodChannel pada detik ke-$i: $token', name: 'NativePush');
                break;
              }
            } catch (_) {}

            // Coba lewat SharedPreferences dengan reload() dari disk UserDefaults
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.reload(); // SANGAT PENTING: refresh in-memory cache dari native storage!
              final pToken = prefs.getString('apns_device_token');
              final pError = prefs.getString('apns_error');

              if (pError != null && pError.isNotEmpty) {
                errorRx.value = pError;
                developer.log('APNs Native Error dari SharedPreferences: $pError', name: 'NativePush');
              }

              if (pToken != null && pToken.isNotEmpty) {
                token = pToken;
                developer.log('APNs Native Token ditemukan dari SharedPreferences pada detik ke-$i: $token', name: 'NativePush');
                break;
              }
            } catch (_) {}

            await Future.delayed(const Duration(seconds: 1));
          }
        }

        if (token != null && token.isNotEmpty) {
          _onTokenObtained(token, isManualRetry: isManualRetry);
        } else {
          if (errorRx.value != null && errorRx.value!.isNotEmpty) {
            statusMessage.value = 'iOS APNs Error: ${errorRx.value}';
          } else {
            statusMessage.value = 'APNs Token belum tersedia dari Apple';
          }
          developer.log('APNs token tidak ditemukan setelah polling', name: 'NativePush');
        }
      } else {
        // Platform Android atau Web
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
