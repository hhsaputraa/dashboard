import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => Get.isRegistered<NotificationService>()
      ? Get.find<NotificationService>()
      : _instance;
  NotificationService._internal();

  static NotificationService get to => Get.isRegistered<NotificationService>()
      ? Get.find<NotificationService>()
      : Get.put(NotificationService(), permanent: true);

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final RxnString fcmToken = RxnString();
  final RxnString tokenError = RxnString();
  final RxBool isFetchingToken = false.obs;
  final RxInt unreadCount = 0.obs;
  final RxList<AppNotificationItem> notificationHistory =
      <AppNotificationItem>[].obs;
  final RxBool isInitialized = false.obs;
  bool _isListening = false;

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

  static const MethodChannel _apnsDiagnosticChannel =
      MethodChannel('com.bprsupra.dashboard/apns_diagnostics');

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

      // On iOS, check permission and request APNs token
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final settings = await FirebaseMessaging.instance.getNotificationSettings();
        debugPrint('[NotificationService] iOS Notification Permission: ${settings.authorizationStatus}');
        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          tokenError.value =
              'Izin Notifikasi ditolak di iPhone. Buka Pengaturan iPhone > Pemberitahuan > BPR SUPRA > aktifkan "Izinkan Pemberitahuan".';
          isFetchingToken.value = false;
          return;
        } else if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
          await _requestPermissions();
        }

        // Trigger native registration
        try {
          await _apnsDiagnosticChannel.invokeMethod('requestRegister');
        } catch (_) {}

        String? apnsToken;
        int attempts = 0;
        const maxAttempts = 10;

        while (apnsToken == null && attempts < maxAttempts) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken != null) break;

          // Check if native iOS caught an explicit error from Apple
          try {
            final diag = await _apnsDiagnosticChannel.invokeMethod<Map>('getApnsDiagnostic');
            final nativeError = diag?['error'] as String?;
            if (nativeError != null && nativeError.isNotEmpty) {
              tokenError.value = 'Apple APNs Error: $nativeError';
              debugPrint('[NotificationService] Apple APNs native error: $nativeError');
              isFetchingToken.value = false;
              return;
            }
          } catch (_) {}

          debugPrint('[NotificationService] Waiting for APNs token (attempt ${attempts + 1}/$maxAttempts)...');
          await Future.delayed(const Duration(milliseconds: 1500));
          attempts++;
        }

        if (apnsToken == null) {
          // Last check for native error
          try {
            final diag = await _apnsDiagnosticChannel.invokeMethod<Map>('getApnsDiagnostic');
            final nativeError = diag?['error'] as String?;
            if (nativeError != null && nativeError.isNotEmpty) {
              tokenError.value = 'Apple APNs Error: $nativeError';
              isFetchingToken.value = false;
              return;
            }
          } catch (_) {}

          final errorMsg =
              'APNs Token timeout dari Apple. Pastikan koneksi internet aktif dan perangkat terhubung ke APNs.';
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
    if (_isListening) {
      debugPrint('[NotificationService] Message listeners already set up, skipping.');
      return;
    }
    _isListening = true;

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
    final messageId = message.messageId;
    if (messageId != null && notificationHistory.any((e) => e.id == messageId)) {
      debugPrint('[NotificationService] Duplicate message ignored: $messageId');
      return;
    }

    final title = message.notification?.title ?? message.data['title'] ?? 'Notifikasi Baru';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    // Add to local in-memory history
    final item = AppNotificationItem(
      id: messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      receivedAt: DateTime.now(),
      data: message.data,
      isRead: false,
    );
    notificationHistory.insert(0, item);
    unreadCount.value++;

    if (isForeground) {
      // On iOS: FirebaseMessaging foreground presentation options (alert: true)
      // already instructs Apple UNUserNotificationCenter to display the native
      // system banner at the top of the screen. Triggering a local notification
      // here on iOS creates a duplicate system banner!
      // On Android: Android does NOT display heads-up notifications automatically
      // when in foreground, so we use local notifications only on Android.
      if (defaultTargetPlatform == TargetPlatform.android) {
        _showLocalNotification(item);
      }
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
