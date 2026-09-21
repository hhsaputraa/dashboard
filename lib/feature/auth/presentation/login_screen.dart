import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:dashboard/core/presentation/server_config_dialog.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  LoginController get _controller =>
      Get.isRegistered<LoginController>() ? Get.find<LoginController>() : Get.put(LoginController());

  // Static cached borders for InputDecoration to avoid object allocation during builds/rebuilds
  static final OutlineInputBorder _defaultBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
  );
  static final OutlineInputBorder _enabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
  );
  static final OutlineInputBorder _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
  );
  static final OutlineInputBorder _errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
  );
  static final OutlineInputBorder _focusedErrorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Latar belakang putih bersih (White / Light Mode)
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- BACKGROUND GAMBAR ONLINE SUPER OPTIMAL ---
          const _LoginBackground(),

          // --- KONTEN UTAMA LOGIN ---
          SafeArea(
            child: Column(
              children: [
                // --- 1. HEADER ATAS (Brand Monogram & Pengaturan Server) ---
                const _LoginHeader(),

                const Divider(height: 1, color: Color(0xFFF1F5F9)),

                // --- 2. AREA FORM LOGIN UTAMA ---
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 20,
                      ),
                      child: Form(
                        key: _controller.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Subtitle Kecil & Judul Utama Khas Mobile Modern
                            const Text(
                              'DASHBOARD MONITORING APP',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'LOGIN',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.0,
                              ),
                            ),

                            // Banner Pesan Error jika Login Gagal
                            Obx(() {
                              final error = _controller.errorMessage.value;
                              if (error == null) return const SizedBox.shrink();
                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFFCA5A5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          size: 20,
                                          color: Color(0xFFDC2626),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            error,
                                            style: const TextStyle(
                                              color: Color(0xFF991B1B),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              );
                            }),

                            // --- INPUT USERNAME ---
                            const Text(
                              'Username',
                              style: TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(() => TextFormField(
                              controller: _controller.usernameController,
                              textInputAction: TextInputAction.next,
                              enabled: !_controller.isLoading.value,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 15,
                              ),
                              decoration: _buildInputDecoration(
                                hintText: 'Username',
                                prefixIcon: Icons.person_outline_rounded,
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Username tidak boleh kosong';
                                }
                                return null;
                              },
                            )),
                            const SizedBox(height: 20),

                            // --- INPUT PASSWORD ---
                            const Text(
                              'Password',
                              style: TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(() => TextFormField(
                              controller: _controller.passwordController,
                              obscureText: _controller.obscurePassword.value,
                              textInputAction: TextInputAction.done,
                              enabled: !_controller.isLoading.value,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 15,
                              ),
                              onFieldSubmitted: (_) => _controller.submitLogin(),
                              decoration: _buildInputDecoration(
                                hintText: 'Password',
                                prefixIcon: Icons.lock_outline_rounded,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _controller.obscurePassword.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF64748B),
                                    size: 20,
                                  ),
                                  onPressed: _controller.togglePasswordVisibility,
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Password tidak boleh kosong';
                                }
                                return null;
                              },
                            )),
                            const SizedBox(height: 32),

                            // --- TOMBOL UTAMA MASUK ---
                            Obx(() {
                              final loading = _controller.isLoading.value;
                              return SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: loading ? null : _controller.submitLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: loading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Masuk',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                          ],
                                        ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // --- 3. FOOTER MINIMALIS ---
                const _LoginFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper untuk gaya input yang konsisten, bersih, dan modern
  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(prefixIcon, size: 20, color: const Color(0xFF64748B)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: _defaultBorder,
      enabledBorder: _enabledBorder,
      focusedBorder: _focusedBorder,
      errorBorder: _errorBorder,
      focusedErrorBorder: _focusedErrorBorder,
    );
  }
}

/// Header login terpisah sebagai widget const untuk menghindari re-render saat state form berubah.
class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'BPR SUPRA',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '• Sistem Informasi',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => ServerConfigDialog.show(context),
            icon: const Icon(
              Icons.tune_rounded,
              color: Color(0xFF64748B),
              size: 20,
            ),
            tooltip: 'Pengaturan Server',
          ),
        ],
      ),
    );
  }
}

/// Footer login terpisah sebagai widget const untuk menghemat alokasi memori re-render.
class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        '© BPR SUPRA ARTAPERSADA',
        style: TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Widget background berkinerja tinggi: 100% offline native decoration
/// tanpa network request blocking, terisolasi dengan RepaintBoundary.
class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base background: gradien halus slate-white modern
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color(0xFFF8FAFC),
                  Color(0xFFF1F5F9),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Accent glow atas kanan: Brand Primary Color
          Positioned(
            top: -120,
            right: -100,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.08),
                      AppTheme.primaryColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Accent glow bawah kiri: Deep Blue Accent
          Positioned(
            bottom: -100,
            left: -80,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2563EB).withValues(alpha: 0.05),
                      const Color(0xFF2563EB).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
