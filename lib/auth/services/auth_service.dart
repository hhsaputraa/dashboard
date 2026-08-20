import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/security/aes_encryption.dart';
import '../models/auth_result.dart';
import '../models/user_model.dart';

/// Service untuk mengelola autentikasi, enkripsi kredensial, dan persistensi sesi user.
/// Menggunakan pola Singleton sederhana agar state user & token dapat diakses di seluruh aplikasi.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _apiClient = ApiClient();

  /// State reaktif user dan token login
  final ValueNotifier<UserModel?> currentUser = ValueNotifier<UserModel?>(null);
  final ValueNotifier<String?> currentToken = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isCheckingAuth = ValueNotifier<bool>(true);

  /// Status apakah user sedang login
  bool get isAuthenticated => currentToken.value != null && currentToken.value!.isNotEmpty;

  /// Memuat token & data user dari local storage saat aplikasi pertama kali dibuka.
  Future<void> initSession() async {
    isCheckingAuth.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyAuthToken);
      final userJsonStr = prefs.getString(AppConstants.keyUserData);

      if (token != null && token.isNotEmpty) {
        currentToken.value = token;

        // Muat data user dari cache lokal jika ada
        if (userJsonStr != null && userJsonStr.isNotEmpty) {
          try {
            currentUser.value = UserModel.fromJson(jsonDecode(userJsonStr));
          } catch (_) {}
        }

        // Sinkronisasi data user terbaru dengan backend di background
        await fetchProfile();
      }
    } catch (_) {
      // Jika terjadi error lokal, biarkan user tetap di halaman login
    } finally {
      isCheckingAuth.value = false;
    }
  }

  /// Melakukan login dengan enkripsi kredensial AES-256-CBC.
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isEmpty || password.isEmpty) {
      return AuthResult.failure('Username dan password wajib diisi.');
    }

    try {
      // 1. Enkripsi kredensial dengan AES-256-CBC
      final encryptedUsername = AesEncryption.encrypt(cleanUsername);
      final encryptedPassword = AesEncryption.encrypt(password);

      // 2. Kirim request ke backend Go
      final response = await _apiClient.post(
        '/api/auth/login',
        body: {
          'username': encryptedUsername,
          'password': encryptedPassword,
        },
        timeout: const Duration(seconds: 15),
      );

      // 3. Tangani respon JSON dari server
      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return AuthResult.failure(
          'Format respon server tidak valid (HTTP ${response.statusCode}). Pastikan server Go aktif.',
        );
      }

      if (response.statusCode == 200) {
        final data = decoded['data'] ?? decoded;
        final token = data['token']?.toString() ?? '';

        if (token.isNotEmpty) {
          // Simpan token ke state & local storage
          currentToken.value = token;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConstants.keyAuthToken, token);

          // 4. Ambil profil lengkap user dari /api/auth/me
          await fetchProfile();

          return AuthResult.success(
            message: 'Login berhasil.',
            user: currentUser.value,
          );
        }
      }

      // Jika server mengembalikan status error (400, 401, 500, dll.)
      final errorMsg = decoded['message'] ?? 'Login gagal. Periksa username dan password Anda.';
      return AuthResult.failure(errorMsg.toString());
    } on http.ClientException catch (e) {
      return AuthResult.failure(
        'Gagal terhubung ke server backend di ${_apiClient.baseUrl} (${e.message}). Pastikan server aktif.',
      );
    } on TimeoutException {
      return AuthResult.failure(
        'Koneksi timeout: Server backend membutuhkan waktu terlalu lama untuk merespons.',
      );
    } catch (e) {
      return AuthResult.failure('Terjadi kendala saat login: $e');
    }
  }

  /// Mendaftarkan pengguna baru dengan kredensial terenkripsi AES-256-CBC.
  Future<AuthResult> register({
    required String username,
    required String password,
    required String fullName,
    required String email,
  }) async {
    final cleanUsername = username.trim();
    final cleanFullName = fullName.trim();
    final cleanEmail = email.trim();

    if (cleanUsername.isEmpty || password.isEmpty || cleanFullName.isEmpty) {
      return AuthResult.failure('Semua kolom pendaftaran wajib diisi.');
    }

    try {
      final encryptedUsername = AesEncryption.encrypt(cleanUsername);
      final encryptedPassword = AesEncryption.encrypt(password);

      final response = await _apiClient.post(
        '/api/auth/register',
        body: {
          'username': encryptedUsername,
          'password': encryptedPassword,
          'full_name': cleanFullName,
          'email': cleanEmail,
        },
        timeout: const Duration(seconds: 15),
      );

      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return AuthResult.failure(
          'Format respon server tidak valid (HTTP ${response.statusCode}).',
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResult.success(
          message: decoded['message']?.toString() ?? 'Pendaftaran berhasil. Silakan login.',
        );
      }

      final errorMsg = decoded['message'] ?? 'Pendaftaran akun gagal.';
      return AuthResult.failure(errorMsg.toString());
    } on http.ClientException catch (e) {
      return AuthResult.failure('Gagal terhubung ke server: ${e.message}');
    } on TimeoutException {
      return AuthResult.failure('Koneksi timeout saat mendaftar akun.');
    } catch (e) {
      return AuthResult.failure('Terjadi kendala: $e');
    }
  }

  /// Mengambil profil user terbaru dari `GET /api/auth/me`.
  Future<bool> fetchProfile() async {
    final token = currentToken.value;
    if (token == null || token.isEmpty) return false;

    try {
      final response = await _apiClient.get(
        '/api/auth/me',
        token: token,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final userData = decoded['data']?['user'] ?? decoded['user'];
        if (userData != null) {
          final user = UserModel.fromJson(userData);
          currentUser.value = user;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            AppConstants.keyUserData,
            jsonEncode(user.toJson()),
          );
          return true;
        }
      } else if (response.statusCode == 401) {
        // Token sudah expired / tidak valid di backend -> otomatis logout
        await logout();
      }
    } catch (_) {}
    return false;
  }

  /// Menghapus sesi login di client dan backend.
  Future<void> logout() async {
    final token = currentToken.value;
    if (token != null && token.isNotEmpty) {
      try {
        await _apiClient.post('/api/auth/logout', token: token);
      } catch (_) {}
    }

    // Bersihkan state & storage lokal
    currentToken.value = null;
    currentUser.value = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyAuthToken);
      await prefs.remove(AppConstants.keyUserData);
    } catch (_) {}
  }
}
