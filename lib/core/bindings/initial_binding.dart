import 'package:get/get.dart';
import '../network/api_client.dart';
import '../services/notification_service.dart';
import '../../feature/auth/services/auth_service.dart';

/// Binding global yang diinisialisasi saat pertama kali aplikasi dibuka.
/// Mendaftarkan Core Services (ApiClient, AuthService, NotificationService) sebagai permanent singleton di GetX memory container.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiClient>(ApiClient(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
  }
}
