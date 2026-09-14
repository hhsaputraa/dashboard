import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dashboard/core/routes/app_routes.dart';
import 'package:dashboard/feature/auth/models/user_model.dart';
import 'package:dashboard/feature/auth/presentation/login_screen.dart';
import 'package:dashboard/feature/auth/services/auth_service.dart';

/// Controller GetX untuk mengelola sesi user pada halaman Profil,
/// formatting data tampilan, state reaktif, serta konfirmasi logout.
class ProfileController extends GetxController {
  final Rxn<UserModel> customUser = Rxn<UserModel>();
  final RxBool isLoggingOut = false.obs;
  final RxBool isRefreshing = false.obs;

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Ags',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  AuthService get _authService =>
      Get.isRegistered<AuthService>() ? Get.find<AuthService>() : AuthService();

  /// Mengambil data user aktif, memprioritaskan customUser jika di-inject (misal untuk testing)
  UserModel? get user => customUser.value ?? _authService.user;

  /// Inisialisasi awal sinkronisasi user dari AuthService
  @override
  void onInit() {
    super.onInit();
    // Sinkronisasi data awal jika AuthService sudah memiliki user
    if (_authService.user != null && customUser.value == null) {
      customUser.value = _authService.user;
    }
  }

  /// Ekstraksi inisial 1-2 karakter dari nama lengkap
  String getInitials(String? fullName) {
    if (fullName == null) return 'U';
    final clean = fullName.trim();
    if (clean.isEmpty) return 'U';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length > 1 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean[0].toUpperCase();
  }

  /// Format tanggal login terakhir ke waktu lokal WIB dengan nama bulan Indonesia
  String formatLastLogin(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Aktif Sekarang';
    try {
      final clean = raw.trim().replaceAll('"', '');
      final dt = DateTime.parse(clean).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = _months[dt.month - 1];
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day $month $year, $hour:$minute WIB';
    } catch (_) {
      return 'Aktif Sekarang';
    }
  }

  /// Inisial dari user aktif saat ini
  String get initials => getInitials(user?.fullName);

  /// String login terakhir yang telah terformat
  String get formattedLastLogin => formatLastLogin(user?.lastLoginAt);

  /// Label peran pengguna (Administrator vs User)
  String get userRole => (user?.isAdmin ?? false) ? 'Administrator' : 'User';

  /// Label status pengguna (Aktif vs Non-Aktif)
  String get userStatus => (user?.isActive ?? false) ? 'Aktif' : 'Non-Aktif';

  /// Memperbarui profil pengguna dari backend
  Future<bool> refreshProfile() async {
    isRefreshing.value = true;
    try {
      final success = await _authService.fetchProfile();
      if (success && _authService.user != null) {
        customUser.value = _authService.user;
      }
      isRefreshing.value = false;
      return success;
    } catch (_) {
      isRefreshing.value = false;
      return false;
    }
  }

  /// Menampilkan modal/dialog konfirmasi logout dan memproses sesi keluar
  Future<bool> handleLogout({
    BuildContext? context,
    Future<void> Function()? customLogout,
  }) async {
    bool? confirmed;

    final dialogWidget = AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 22),
          SizedBox(width: 10),
          Text(
            'Konfirmasi Keluar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
      content: const Text(
        'Apakah Anda yakin ingin keluar dari akun ini?',
        style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (context != null) {
              Navigator.of(context).pop(false);
            } else {
              Get.back(result: false);
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF64748B),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text(
            'Batal',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (context != null) {
              Navigator.of(context).pop(true);
            } else {
              Get.back(result: true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          child: const Text(
            'Keluar',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );

    if (context != null) {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => dialogWidget,
      );
    } else {
      confirmed = await Get.dialog<bool>(dialogWidget);
    }

    if (confirmed != true) return false;

    isLoggingOut.value = true;

    try {
      if (customLogout != null) {
        await customLogout();
      } else {
        await _authService.logout();
      }

      // Bersihkan customUser
      customUser.value = null;
      isLoggingOut.value = false;

      // Navigasi ke halaman login
      if (Get.key.currentState != null) {
        Get.offAllNamed(AppRoutes.login);
      } else if (context != null && context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
      return true;
    } catch (_) {
      isLoggingOut.value = false;
      return false;
    }
  }
}
