import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dashboard/core/services/notification_service.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  group('NotificationService Unit Tests', () {
    test('initializes with default zero counts and empty history', () {
      final service = Get.put(NotificationService());

      expect(service.unreadCount.value, equals(0));
      expect(service.notificationHistory, isEmpty);
      expect(service.fcmToken.value, isNull);
    });

    test('manual notification handling updates unreadCount and history', () {
      final service = Get.put(NotificationService());

      final item = AppNotificationItem(
        id: '101',
        title: 'Pembayaran Diterima',
        body: 'Setoran tabungan sebesar Rp 5.000.000 berhasil',
        receivedAt: DateTime.now(),
        isRead: false,
      );

      service.notificationHistory.insert(0, item);
      service.unreadCount.value++;

      expect(service.unreadCount.value, equals(1));
      expect(service.notificationHistory.length, equals(1));
      expect(service.notificationHistory.first.title, equals('Pembayaran Diterima'));
      expect(service.notificationHistory.first.isRead, isFalse);
    });

    test('markAllAsRead sets all items isRead=true and unreadCount to 0', () {
      final service = Get.put(NotificationService());

      service.notificationHistory.addAll([
        AppNotificationItem(
          id: '1',
          title: 'Notif 1',
          body: 'Body 1',
          receivedAt: DateTime.now(),
          isRead: false,
        ),
        AppNotificationItem(
          id: '2',
          title: 'Notif 2',
          body: 'Body 2',
          receivedAt: DateTime.now(),
          isRead: false,
        ),
      ]);
      service.unreadCount.value = 2;

      service.markAllAsRead();

      expect(service.unreadCount.value, equals(0));
      expect(service.notificationHistory.every((n) => n.isRead), isTrue);
    });

    test('clearAll clears history list and unreadCount', () {
      final service = Get.put(NotificationService());

      service.notificationHistory.add(
        AppNotificationItem(
          id: '1',
          title: 'Notif',
          body: 'Body',
          receivedAt: DateTime.now(),
          isRead: false,
        ),
      );
      service.unreadCount.value = 1;

      service.clearAll();

      expect(service.notificationHistory, isEmpty);
      expect(service.unreadCount.value, equals(0));
    });
  });
}
