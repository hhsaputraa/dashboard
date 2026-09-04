import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dashboard/feature/home/controllers/navigation_controller.dart';
import 'package:dashboard/feature/home/presentation/home_screen.dart';
import 'package:dashboard/feature/profile/presentation/profile_screen.dart';
import 'package:dashboard/feature/report/presentation/report_screen.dart';
import 'package:dashboard/feature/revenue/presentation/revenue_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  NavigationController get _controller =>
      Get.isRegistered<NavigationController>()
          ? Get.find<NavigationController>()
          : Get.put(NavigationController());

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Beranda',
    ),
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: 'Pendapatan',
    ),
    NavigationDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
      label: 'Laporan',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = _controller.selectedIndex.value;
      return Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: [
            const HomeScreen(),
            RevenueScreen(isActive: selectedIndex == 1),
            const KodeKolScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: _controller.changePage,
          destinations: _destinations,
        ),
      );
    });
  }
}
