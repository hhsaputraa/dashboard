import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dashboard/core/routes/app_routes.dart';
import '../services/auth_service.dart';

/// Controller untuk form login dan state autentikasi UI.
class LoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  AuthService get _authService => AuthService.to;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void clearError() {
    errorMessage.value = null;
  }

  Future<bool> submitLogin() async {
    if (formKey.currentState == null || !formKey.currentState!.validate() || isLoading.value) {
      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await _authService.login(
        username: usernameController.text,
        password: passwordController.text,
      );

      isLoading.value = false;

      if (result.isSuccess) {
        Get.offAllNamed(AppRoutes.main);
        return true;
      } else {
        errorMessage.value = result.message;
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Terjadi kesalahan: $e';
      return false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
