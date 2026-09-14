import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dashboard/firebase_options.dart';
import '../theme/app_theme.dart';

/// Top-level background message handler for FCM.
/// Must be top-level and decorated with @pragma('vm:entry-point')
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options != null) {
      await Firebase.initializeApp(options: options);
    } else {
      await Firebase.initializeApp();
    }
  }
  debugPrint('Handling a background message: ${message.messageId}');
}

/// Simple model for notifications kept in-memory
class AppNotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final Map<String, dynamic> data;
  bool isRead;

  AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.data = const {},
    this.isRead = false,
  });
}

class NotificationService extends GetxService {
  static NotificationService get to => Get.isRegistered<NotificationService>()
      ? Get.find<NotificationService>()
      : Get.put(NotificationService());

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final RxnString fcmToken = RxnString();
  final RxnString tokenError = RxnString();
  final RxBool isFetchingToken = false.obs;
  final RxInt unreadCount = 0.obs;
  final RxList<AppNotificationItem> notificationHistory =
      <AppNotificationItem>[].obs;
  final RxBool isInitialized = false.obs;

  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDescription =
      'This channel is used for important notifications.';

  /// Initialize Firebase & Local Notifications
  Future<NotificationService> init() async {
    try {
      // 1. Initialize Firebase Core
      if (Firebase.apps.isEmpty) {
        final options = DefaultFirebaseOptions.currentPlatform;
        if (options != null) {
          await Firebase.initializeApp(options: options);
        } else {
          await Firebase.initializeApp();
        }
      }

      // 2. Set background messaging handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Request permissions (iOS and Android 13+)
      await _requestPermissions();

      // 4. Initialize Local Notifications for foreground display
      await _initLocalNotifications();

      // 5. Setup foreground notification presentation options for iOS
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      // 6. Setup message listeners
      _setupMessageListeners();

      // 7. Fetch & monitor FCM Token (runs asynchronously so it doesn't block startup)
      fetchToken();

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        fcmToken.value = newToken;
        tokenError.value = null;
        debugPrint('[NotificationService] FCM Token refreshed: $newToken');
      });

      isInitialized.value = true;
      debugPrint('[NotificationService] Initialized successfully');
    } catch (e, st) {
      debugPrint('[NotificationService] Initialization error: $e\n$st');
    }

    return this;
  }

  Future<void> _requestPermissions() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint(
      '[NotificationService] User granted permission: ${settings.authorizationStatus}',
    );

    // Request Android 13+ permission via local notifications plugin
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('[NotificationService] Local notification tapped: ${response.payload}');
        _handlePayload(response.payload);
      },
    );

    // Create high importance channel for Android
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> fetchToken({bool isRetry = false}) async {
    isFetchingToken.value = true;
    tokenError.value = null;

    try {
      if (Firebase.apps.isEmpty) {
        final options = DefaultFirebaseOptions.currentPlatform;
        if (options != null) {
          await Firebase.initializeApp(options: options);
        } else {
          await Firebase.initializeApp();
        }
      }

      // On iOS, Firebase requires an APNs token from Apple before generating an FCM token.
      // APNs token generation is asynchronous and may take several seconds.
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken;
        int attempts = 0;
        const maxAttempts = 10;

        while (apnsToken == null && attempts < maxAttempts) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken == null) {
            debugPrint('[NotificationService] Waiting for APNs token (attempt ${attempts + 1}/$maxAttempts)...');
            await Future.delayed(const Duration(milliseconds: 1500));
            attempts++;
          }
        }

        if (apnsToken == null) {
          final errorMsg =
              'APNs Token belum diterima dari Apple (timeout). Pastikan: 1) Akun Apple Dev mengaktifkan Push Notifications untuk App ID ini, 2) Entitlements aps-environment terpasang, 3) Bukan dijalankan di simulator non-APNs.';
          tokenError.value = errorMsg;
          debugPrint('[NotificationService] $errorMsg');
          isFetchingToken.value = false;
          return;
        }

        debugPrint('[NotificationService] APNs Token ready: $apnsToken');
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        fcmToken.value = token;
        tokenError.value = null;
        debugPrint('=============================================');
        debugPrint('🔥 FCM DEVICE TOKEN:');
        debugPrint(token);
        debugPrint('=============================================');
      } else {
        tokenError.value = 'FCM Token bernilai null dari Firebase';
      }
    } catch (e) {
      tokenError.value = 'Gagal memuat token: $e';
      debugPrint('[NotificationService] Error retrieving FCM token: $e');
    } finally {
      isFetchingToken.value = false;
    }
  }

  void _setupMessageListeners() {
    // 1. FOREGROUND: App is actively open on screen
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[NotificationService] Foreground message received: ${message.messageId}');
      _handleIncomingMessage(message, isForeground: true);
    });

    // 2. BACKGROUND: App was in background and user clicked notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[NotificationService] Notification opened from background: ${message.messageId}');
      _handleIncomingMessage(message, isForeground: false);
      _navigateToDestination(message.data);
    });

    // 3. TERMINATED: App was completely closed and launched via notification tap
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('[NotificationService] App launched from terminated state via notification: ${message.messageId}');
        _handleIncomingMessage(message, isForeground: false);
        _navigateToDestination(message.data);
      }
    });
  }

  void _handleIncomingMessage(RemoteMessage message, {required bool isForeground}) {
    final title = message.notification?.title ?? message.data['title'] ?? 'Notifikasi Baru';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    // Add to local in-memory history
    final item = AppNotificationItem(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      receivedAt: DateTime.now(),
      data: message.data,
      isRead: false,
    );
    notificationHistory.insert(0, item);
    unreadCount.value++;

    if (isForeground) {
      // Show native heads-up notification and in-app snackbar
      _showLocalNotification(item);
      _showInAppSnackbar(item);
    }
  }

  Future<void> _showLocalNotification(AppNotificationItem item) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      color: AppTheme.primaryColor,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.show(
      id: item.id.hashCode,
      title: item.title,
      body: item.body,
      notificationDetails: notificationDetails,
      payload: item.id,
    );
  }

  void _showInAppSnackbar(AppNotificationItem item) {
    if (Get.context == null) return;

    Get.snackbar(
      item.title,
      item.body,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: const Color(0xFF0F172A),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      icon: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.notifications_active_rounded,
          color: AppTheme.primaryColor,
          size: 22,
        ),
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      duration: const Duration(seconds: 4),
      onTap: (_) {
        item.isRead = true;
        if (unreadCount.value > 0) unreadCount.value--;
        _navigateToDestination(item.data);
      },
    );
  }

  void _handlePayload(String? payload) {
    if (payload != null) {
      final item = notificationHistory.firstWhereOrNull((e) => e.id == payload);
      if (item != null) {
        item.isRead = true;
        if (unreadCount.value > 0) unreadCount.value--;
        _navigateToDestination(item.data);
      }
    }
  }

  void _navigateToDestination(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    if (route != null && route.isNotEmpty) {
      Get.toNamed(route);
    }
  }

  void markAllAsRead() {
    for (var n in notificationHistory) {
      n.isRead = true;
    }
    unreadCount.value = 0;
  }

  void clearAll() {
    notificationHistory.clear();
    unreadCount.value = 0;
  }
}
