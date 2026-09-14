import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dashboard/core/bindings/initial_binding.dart';
import 'package:dashboard/core/network/api_client.dart';
import 'package:dashboard/core/services/notification_service.dart';
import 'package:dashboard/feature/auth/services/auth_service.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  test('InitialBinding registers ApiClient, AuthService, and NotificationService in GetX container', () {
    expect(Get.isRegistered<ApiClient>(), isFalse);
    expect(Get.isRegistered<AuthService>(), isFalse);
    expect(Get.isRegistered<NotificationService>(), isFalse);

    InitialBinding().dependencies();

    expect(Get.isRegistered<ApiClient>(), isTrue);
    expect(Get.isRegistered<AuthService>(), isTrue);
    expect(Get.isRegistered<NotificationService>(), isTrue);

    final apiClient = Get.find<ApiClient>();
    final authService = Get.find<AuthService>();
    final notifService = Get.find<NotificationService>();

    expect(apiClient, isNotNull);
    expect(authService, isNotNull);
    expect(notifService, isNotNull);

    expect(ApiClient.to, same(apiClient));
    expect(AuthService.to, same(authService));
    expect(NotificationService.to, same(notifService));
  });

  test('AuthService reactive properties and backwards-compatible ValueNotifiers sync', () {
    InitialBinding().dependencies();
    final auth = AuthService.to;

    expect(auth.isAuthenticated, isFalse);
    expect(auth.rxToken.value, isNull);
    expect(auth.currentToken.value, isNull);
    expect(auth.rxUser.value, isNull);
    expect(auth.currentUser.value, isNull);
  });
}
