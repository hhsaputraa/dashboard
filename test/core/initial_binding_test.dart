import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dashboard/core/bindings/initial_binding.dart';
import 'package:dashboard/core/network/api_client.dart';
import 'package:dashboard/feature/auth/services/auth_service.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  test('InitialBinding registers ApiClient and AuthService in GetX container', () {
    expect(Get.isRegistered<ApiClient>(), isFalse);
    expect(Get.isRegistered<AuthService>(), isFalse);

    InitialBinding().dependencies();

    expect(Get.isRegistered<ApiClient>(), isTrue);
    expect(Get.isRegistered<AuthService>(), isTrue);

    final apiClient = Get.find<ApiClient>();
    final authService = Get.find<AuthService>();

    expect(apiClient, isNotNull);
    expect(authService, isNotNull);

    expect(ApiClient.to, same(apiClient));
    expect(AuthService.to, same(authService));
  });

  test('AuthService initializes with clean reactive properties', () {
    InitialBinding().dependencies();
    final auth = AuthService.to;

    expect(auth.isAuthenticated, isFalse);
    expect(auth.rxToken.value, isNull);
    expect(auth.token, isNull);
    expect(auth.rxUser.value, isNull);
    expect(auth.user, isNull);
  });
}
