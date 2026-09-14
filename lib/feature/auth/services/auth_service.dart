import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dashboard/core/constants/app_constants.dart';
import 'package:dashboard/core/network/api_client.dart';
import 'package:dashboard/core/security/aes_encryption.dart';
import '../models/auth_result.dart';
import '../models/user_model.dart';

/// Service untuk mengelola autentikasi, enkripsi kredensial, dan persistensi sesi user.
/// Berbasis GetxService dengan dependency injection Get.find() & Get.put().
class AuthService extends GetxService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => Get.isRegistered<AuthService>() ? Get.find<AuthService>() : _instance;
  AuthService._internal();

  static AuthService get to => Get.find<AuthService>();

  ApiClient get _apiClient => Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// State reaktif GetX
  final Rxn<UserModel> rxUser = Rxn<UserModel>();
  final Rxn<String> rxToken = Rxn<String>();
  final RxBool rxIsCheckingAuth = true.obs;

  /// Getters untuk state GetX
  UserModel? get user => rxUser.value;
  String? get token => rxToken.value;

  /// ValueNotifier bridge untuk kompatibilitas mundur dengan widget existing
  @Deprecated('Gunakan rxUser atau getter user di AuthService')
  final ValueNotifier<UserModel?> currentUser = ValueNotifier<UserModel?>(null);
  @Deprecated('Gunakan rxToken atau getter token di AuthService')
  final ValueNotifier<String?> currentToken = ValueNotifier<String?>(null);
  @Deprecated('Gunakan rxIsCheckingAuth di AuthService')
  final ValueNotifier<bool> isCheckingAuth = ValueNotifier<bool>(true);

  void _setUser(UserModel? u) {
    rxUser.value = u;
    currentUser.value = u;
  }

  void _setToken(String? t) {
    rxToken.value = t;
    currentToken.value = t;
  }

  void _setCheckingAuth(bool checking) {
    rxIsCheckingAuth.value = checking;
    isCheckingAuth.value = checking;
  }

  /// Status apakah user sedang login
  bool get isAuthenticated => rxToken.value != null && rxToken.value!.isNotEmpty;

  /// Memuat token & data user dari hardware-backed storage terenkripsi saat aplikasi pertama kali dibuka.
  Future<void> initSession() async {
    _setCheckingAuth(true);
    try {
      final token = await _secureStorage.read(key: AppConstants.keyAuthToken);
      final userJsonStr = await _secureStorage.read(key: AppConstants.keyUserData);

      if (token != null && token.isNotEmpty) {
        _setToken(token);

        // Muat data user dari cache lokal terenkripsi jika ada
        if (userJsonStr != null && userJsonStr.isNotEmpty) {
          try {
            _setUser(UserModel.fromJson(jsonDecode(userJsonStr)));
          } catch (_) {}
        }

        // Sinkronisasi data user terbaru dengan backend di background tanpa memblokir startup
        unawaited(fetchProfile());
      }
    } catch (_) {
      // Jika terjadi error lokal, biarkan user tetap di halaman login
    } finally {
      _setCheckingAuth(false);
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
          // Simpan token ke state & secure storage terenkripsi (Android KeyStore / iOS Keychain)
          _setToken(token);
          await _secureStorage.write(
            key: AppConstants.keyAuthToken,
            value: token,
          );

          if (data['user'] != null) {
            try {
              final user = UserModel.fromJson(data['user']);
              _setUser(user);
              await _secureStorage.write(
                key: AppConstants.keyUserData,
                value: jsonEncode(user.toJson()),
              );
            } catch (_) {}
          }

          // Sinkronkan profil lengkap di background agar tidak menghalangi navigasi UI (1 RTT vs 2 RTT)
          unawaited(fetchProfile());

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
    final activeToken = token;
    if (activeToken == null || activeToken.isEmpty) return false;

    try {
      final response = await _apiClient.get(
        '/api/auth/me',
        token: activeToken,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final userData = decoded['data']?['user'] ?? decoded['user'];
        if (userData != null) {
          final user = UserModel.fromJson(userData);
          _setUser(user);

          await _secureStorage.write(
            key: AppConstants.keyUserData,
            value: jsonEncode(user.toJson()),
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

  /// Menghapus sesi login di client dan backend secara aman.
  Future<void> logout() async {
    final activeToken = token;
    if (activeToken != null && activeToken.isNotEmpty) {
      try {
        await _apiClient.post('/api/auth/logout', token: activeToken);
      } catch (_) {}
    }

    // Bersihkan state & secure storage lokal
    _setToken(null);
    _setUser(null);

    try {
      await _secureStorage.delete(key: AppConstants.keyAuthToken);
      await _secureStorage.delete(key: AppConstants.keyUserData);
    } catch (_) {}
  }
}
