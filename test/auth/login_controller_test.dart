import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dashboard/feature/auth/controllers/login_controller.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  test('LoginController initializes with correct default reactive states', () {
    final controller = LoginController();
    Get.put(controller);

    expect(controller.obscurePassword.value, isTrue);
    expect(controller.isLoading.value, isFalse);
    expect(controller.errorMessage.value, isNull);
    expect(controller.usernameController.text, isEmpty);
    expect(controller.passwordController.text, isEmpty);
  });

  test('LoginController togglePasswordVisibility toggles obscurePassword', () {
    final controller = LoginController();
    Get.put(controller);

    expect(controller.obscurePassword.value, isTrue);
    controller.togglePasswordVisibility();
    expect(controller.obscurePassword.value, isFalse);
    controller.togglePasswordVisibility();
    expect(controller.obscurePassword.value, isTrue);
  });

  test('LoginController clearError clears errorMessage', () {
    final controller = LoginController();
    Get.put(controller);

    controller.errorMessage.value = 'Terjadi kesalahan';
    expect(controller.errorMessage.value, equals('Terjadi kesalahan'));

    controller.clearError();
    expect(controller.errorMessage.value, isNull);
  });
}
