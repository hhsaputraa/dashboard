import 'package:get/get.dart';
import '../controllers/login_controller.dart';

/// Binding untuk modul autentikasi (LoginScreen, etc).
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
