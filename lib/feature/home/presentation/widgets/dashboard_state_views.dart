import 'package:flutter/material.dart';
import 'package:dashboard/core/presentation/server_config_dialog.dart';
import 'package:dashboard/core/theme/app_theme.dart';

class DashboardLoadingView extends StatelessWidget {
  final String message;

  const DashboardLoadingView({
    super.key,
    this.message = 'Mengambil data...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class DashboardErrorView extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const DashboardErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  static final ButtonStyle _retryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  static final ButtonStyle _configButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFF991B1B),
    side: const BorderSide(color: Color(0xFFFCA5A5)),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFDC2626),
              size: 36,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Gagal Terhubung ke Server',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF991B1B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            errorMessage ?? 'Terjadi kesalahan saat memuat data.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFB91C1C),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Coba Lagi'),
                style: _retryButtonStyle,
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await ServerConfigDialog.show(context);
                  if (!context.mounted) return;
                  onRetry();
                },
                icon: const Icon(Icons.settings_outlined, size: 16),
                label: const Text('Pengaturan Server'),
                style: _configButtonStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
