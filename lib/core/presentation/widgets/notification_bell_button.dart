import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key});

  NotificationService get _service => NotificationService.to;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = _service.unreadCount.value;

      return Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifikasi',
            onPressed: () => _showNotificationSheet(context),
          ),
          if (count > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    });
  }

  void _showNotificationSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'Pusat Notifikasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Obx(() {
                    if (_service.notificationHistory.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return TextButton(
                      onPressed: () => _service.markAllAsRead(),
                      child: const Text(
                        'Tandai Dibaca',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // FCM Token section with loading, retry & copy features
            Obx(() {
              final token = _service.fcmToken.value;
              final error = _service.tokenError.value;
              final isLoading = _service.isFetchingToken.value;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: error != null
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: error != null
                        ? const Color(0xFFFECACA)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          error != null
                              ? Icons.error_outline_rounded
                              : (token != null
                                  ? Icons.check_circle_rounded
                                  : Icons.key_rounded),
                          size: 18,
                          color: error != null
                              ? AppTheme.primaryColor
                              : (token != null
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'FCM Device Token (Testing)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              if (isLoading)
                                Row(
                                  children: const [
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Menunggu izin & APNs Apple...',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                )
                              else if (token != null)
                                Text(
                                  '${token.substring(0, token.length > 28 ? 28 : token.length)}...',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: Color(0xFF334155),
                                  ),
                                )
                              else
                                const Text(
                                  'Token belum tersedia',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (token != null)
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            tooltip: 'Salin Token',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: token));
                              Get.snackbar(
                                'Token Tersalin',
                                'FCM Device Token telah disalin ke clipboard!',
                                snackPosition: SnackPosition.BOTTOM,
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 2),
                              );
                            },
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            tooltip: 'Muat Ulang Token',
                            onPressed: isLoading
                                ? null
                                : () => _service.fetchToken(isRetry: true),
                          ),
                      ],
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        error,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFB91C1C),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

            const Divider(height: 16),

            // Notification List
            Expanded(
              child: Obx(() {
                final list = _service.notificationHistory;
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 56,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum Ada Notifikasi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Notifikasi baru akan muncul di sini secara real-time.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final timeFormatted =
                        DateFormat('HH:mm - dd MMM yyyy').format(item.receivedAt);

                    return Container(
                      decoration: BoxDecoration(
                        color: item.isRead
                            ? const Color(0xFFF8FAFC)
                            : AppTheme.primaryColor.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: item.isRead
                              ? Colors.grey.shade200
                              : AppTheme.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.isRead
                              ? Colors.grey.shade200
                              : AppTheme.primaryColor.withValues(alpha: 0.12),
                          child: Icon(
                            Icons.notifications_active_rounded,
                            size: 20,
                            color: item.isRead
                                ? Colors.grey.shade600
                                : AppTheme.primaryColor,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: item.isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              item.body,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeFormatted,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          item.isRead = true;
                          if (_service.unreadCount.value > 0) {
                            _service.unreadCount.value--;
                          }
                          _service.notificationHistory.refresh();
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
