import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

/// Binding untuk ProfileScreen dependency injection.
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
