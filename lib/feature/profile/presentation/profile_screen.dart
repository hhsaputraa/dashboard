import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:dashboard/core/services/native_push_service.dart';
import 'package:dashboard/feature/auth/models/user_model.dart';
import 'package:dashboard/feature/profile/controllers/profile_controller.dart';

/// Halaman Profil Pengguna berbasis GetX Clean Architecture.
/// Menggunakan Obx untuk reaktivitas data profil dan mendelegasikan
/// seluruh format & sesi logout ke [ProfileController].
class ProfileScreen extends StatelessWidget {
  @Deprecated('Gunakan ProfileController dan GetX Obx reaktif')
  final ValueNotifier<UserModel?>? userNotifier;
  @Deprecated('Gunakan ProfileController.confirmAndLogout()')
  final Future<void> Function()? onLogout;
  final ProfileController? controller;

  const ProfileScreen({
    super.key,
    this.userNotifier,
    this.onLogout,
    this.controller,
  });

  ProfileController get _controller {
    if (controller != null) return controller!;
    if (Get.isRegistered<ProfileController>()) {
      return Get.find<ProfileController>();
    }
    return Get.put(ProfileController());
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;

    // Dukungan backward-compatibility jika userNotifier diinjeksi via constructor
    if (userNotifier != null) {
      return ValueListenableBuilder<UserModel?>(
        valueListenable: userNotifier!,
        builder: (context, user, _) {
          return _buildScaffold(context, ctrl, user);
        },
      );
    }

    // Default GetX reactive view menggunakan Obx
    return Obx(() {
      final user = ctrl.user;
      return _buildScaffold(context, ctrl, user);
    });
  }

  Widget _buildScaffold(
    BuildContext context,
    ProfileController ctrl,
    UserModel? user,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: user == null
          ? _buildEmptyState(ctrl)
          : _buildProfileContent(context, ctrl, user),
    );
  }

  Widget _buildEmptyState(ProfileController ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_outline_rounded,
              size: 56,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sesi Profil Tidak Ditemukan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Silakan muat ulang data atau lakukan login kembali.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => ctrl.refreshProfile(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Muat Ulang Profil'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F172A),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    ProfileController ctrl,
    UserModel user,
  ) {
    final initials = ctrl.getInitials(user.fullName);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // 1. Kartu Identitas Profil (Header Card)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Lingkaran Avatar Monogram Elegan
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFDC2626), // Bank Crimson Red
                        Color(0xFF991B1B), // Burgundy Deep Red
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33DC2626),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Nama Lengkap
                Text(
                  user.fullName.isNotEmpty ? user.fullName : 'Pengguna',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),

                // Username Handle
                Text(
                  '@${user.username}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),

                // Badges: Role & Status Akun
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: user.isAdmin
                            ? const Color(0xFFFEF2F2)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: user.isAdmin
                              ? const Color(0xFFFECACA)
                              : const Color(0xFFBFDBFE),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            user.isAdmin
                                ? Icons.admin_panel_settings_rounded
                                : Icons.person_rounded,
                            size: 13,
                            color: user.isAdmin
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.isAdmin ? 'Administrator' : 'Staff',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: user.isAdmin
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: user.isActive
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: user.isActive
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: user.isActive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            user.isActive ? 'Aktif' : 'Nonaktif',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: user.isActive
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Kartu Rincian Akun (Details Card)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user.email.isNotEmpty ? user.email : '-',
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildInfoRow(
                  icon: Icons.access_time_rounded,
                  label: 'Login terakhir pada',
                  value: ctrl.formatLastLogin(user.lastLoginAt),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Kartu Status Push Notifikasi & APNs Token (Self-Hosted Gorush)
          _buildNativePushCard(context),

          const SizedBox(height: 24),

          // 4. Tombol Logout (Clean & Elegant Action via Controller)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => ctrl.handleLogout(
                context: context,
                customLogout: onLogout,
              ),
              icon: const Icon(
                Icons.logout_rounded,
                size: 18,
                color: Color(0xFFDC2626),
              ),
              label: const Text(
                'Keluar dari Akun',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC2626),
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2),
                side: const BorderSide(color: Color(0xFFFECACA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNativePushCard(BuildContext context) {
    final nativePush = NativePushService.instance;

    return Obx(() {
      final token = nativePush.deviceTokenRx.value;
      final error = nativePush.errorRx.value;
      final isLoading = nativePush.isLoading.value;
      final isConnected = token != null && token.isNotEmpty;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isConnected ? const Color(0xFFE2E8F0) : const Color(0xFFFCA5A5),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Baris Notifikasi
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isConnected
                        ? const Color(0xFFECFDF5)
                        : (isLoading ? const Color(0xFFEFF6FF) : const Color(0xFFFEF2F2)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isConnected
                        ? Icons.notifications_active_rounded
                        : (isLoading ? Icons.sync_rounded : Icons.notifications_off_rounded),
                    size: 20,
                    color: isConnected
                        ? const Color(0xFF059669)
                        : (isLoading ? const Color(0xFF2563EB) : const Color(0xFFDC2626)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Push Notification (Gorush Self-Host)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        isConnected
                            ? 'Siap menerima notifikasi native'
                            : (isLoading ? 'Mendeteksi device token...' : 'Belum terhubung'),
                        style: TextStyle(
                          fontSize: 12,
                          color: isConnected ? const Color(0xFF059669) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isConnected
                        ? const Color(0xFFD1FAE5)
                        : (isLoading ? const Color(0xFFDBEAFE) : const Color(0xFFFEE2E2)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isConnected ? 'Aktif' : (isLoading ? 'Memuat' : 'Offline'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isConnected
                          ? const Color(0xFF047857)
                          : (isLoading ? const Color(0xFF1D4ED8) : const Color(0xFFB91C1C)),
                    ),
                  ),
                ),
              ],
            ),

            if (error != null && error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'iOS APNs Info: $error',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF991B1B),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Token Container (Native APNs)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isConnected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isConnected ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'DEVICE TOKEN NATIVE (APNS 64-HEX):',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF166534),
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (isConnected)
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: token));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Device Token berhasil disalin ke clipboard!'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF15803D),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.copy_rounded, size: 12, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Salin Token',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    token ?? 'Token perangkat belum terdeteksi dari OS.',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: isConnected ? const Color(0xFF14532D) : const Color(0xFF94A3B8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Tombol Muat Ulang & Sinkronisasi
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isLoading
                    ? null
                    : () async {
                        await nativePush.init(isManualRetry: true);
                        await nativePush.syncDeviceToken();
                      },
                icon: isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  isLoading ? 'Memuat Token...' : 'Ambil Ulang & Sinkronkan ke Database',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  backgroundColor: const Color(0xFFEFF6FF),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
