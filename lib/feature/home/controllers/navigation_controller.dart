import 'package:get/get.dart';

/// Controller untuk mengelola navigasi tab utama (BottomNavigationBar) pada shell aplikasi.
class NavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  int get currentIndex => selectedIndex.value;

  void changePage(int index) {
    if (selectedIndex.value != index) {
      selectedIndex.value = index;
    }
  }
}
