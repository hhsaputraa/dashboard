import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dashboard/feature/auth/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
  });

  group('AuthService Strict Banking In-Memory Session Tests', () {
    test('initSession clears persistent token and starts with null token (logged out)', () async {
      final authService = AuthService();
      Get.put<AuthService>(authService);

      await authService.initSession();

      // Cold start MUST yield unauthenticated state so user must log in
      expect(authService.isAuthenticated, isFalse);
      expect(authService.token, isNull);
    });

    test('logout clears in-memory state and notifies listeners', () async {
      final authService = AuthService();
      Get.put<AuthService>(authService);

      // Simulate an in-memory active session during app runtime
      authService.rxToken.value = 'dummy_active_token';
      expect(authService.isAuthenticated, isTrue);

      await authService.logout();

      expect(authService.isAuthenticated, isFalse);
      expect(authService.token, isNull);
      expect(authService.user, isNull);
    });
  });
}
