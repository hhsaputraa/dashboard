import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:dashboard/feature/auth/models/user_model.dart';
import 'package:dashboard/feature/profile/controllers/profile_controller.dart';
import 'package:dashboard/feature/profile/presentation/profile_screen.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  final testUser = UserModel(
    id: 99,
    username: 'johndoe',
    fullName: 'John Doe',
    email: 'john.doe@bank.co.id',
    isAdmin: true,
    isActive: true,
    lastLoginAt: '2026-09-02T10:30:00Z',
  );

  final testStandardUser = UserModel(
    id: 100,
    username: 'sitirahma',
    fullName: 'Siti Rahma',
    email: 'siti.rahma@bank.co.id',
    isAdmin: false,
    isActive: false,
    lastLoginAt: null,
  );

  group('ProfileScreen Legacy ValueNotifier Mode Tests', () {
    testWidgets('ProfileScreen renders empty state when user is null', (WidgetTester tester) async {
      final notifier = ValueNotifier<UserModel?>(null);

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(userNotifier: notifier),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Sesi Profil Tidak Ditemukan'), findsOneWidget);
      expect(find.text('Muat Ulang Profil'), findsOneWidget);
    });

    testWidgets('ProfileScreen renders user profile details accurately', (WidgetTester tester) async {
      final notifier = ValueNotifier<UserModel?>(testUser);

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(userNotifier: notifier),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Avatar Monogram, Name, and Username
      expect(find.text('JD'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('@johndoe'), findsOneWidget);

      // Verify Badges
      expect(find.text('Administrator'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);

      // Verify Details Card
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('john.doe@bank.co.id'), findsOneWidget);
      expect(find.text('Login terakhir pada'), findsOneWidget);
      final dt = DateTime.parse('2026-09-02T10:30:00Z').toLocal();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      expect(find.text('02 Sep 2026, $hour:$minute WIB'), findsOneWidget);

      // Verify Logout Button
      expect(find.text('Keluar dari Akun'), findsOneWidget);
    });

    testWidgets('ProfileScreen logout button opens confirmation dialog and confirms', (WidgetTester tester) async {
      final notifier = ValueNotifier<UserModel?>(testUser);
      bool logoutTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            userNotifier: notifier,
            onLogout: () async {
              logoutTriggered = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap logout button
      await tester.tap(find.text('Keluar dari Akun'));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Konfirmasi Keluar'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);

      // Tap Keluar in dialog
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();

      expect(logoutTriggered, isTrue);
    });
  });

  group('ProfileScreen GetX Reactive Mode Tests', () {
    testWidgets('ProfileScreen renders empty state reactively when controller user is null',
        (WidgetTester tester) async {
      final controller = ProfileController();
      Get.put(controller);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Sesi Profil Tidak Ditemukan'), findsOneWidget);
      expect(find.text('Muat Ulang Profil'), findsOneWidget);
    });

    testWidgets('ProfileScreen updates reactively via Obx when customUser is assigned',
        (WidgetTester tester) async {
      final controller = ProfileController();
      Get.put(controller);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Awalnya empty state
      expect(find.text('Sesi Profil Tidak Ditemukan'), findsOneWidget);

      // Update controller secara reaktif
      controller.customUser.value = testUser;
      await tester.pumpAndSettle();

      // Tampilan otomatis berubah ke profil user
      expect(find.text('Sesi Profil Tidak Ditemukan'), findsNothing);
      expect(find.text('JD'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('@johndoe'), findsOneWidget);
      expect(find.text('Administrator'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
      expect(find.text('john.doe@bank.co.id'), findsOneWidget);

      // Update ke standard non-active user
      controller.customUser.value = testStandardUser;
      await tester.pumpAndSettle();

      expect(find.text('JD'), findsNothing);
      expect(find.text('SR'), findsOneWidget);
      expect(find.text('Siti Rahma'), findsOneWidget);
      expect(find.text('@sitirahma'), findsOneWidget);
      expect(find.text('Staff'), findsOneWidget);
      expect(find.text('Nonaktif'), findsOneWidget);
      expect(find.text('Aktif Sekarang'), findsOneWidget);
    });

    testWidgets('ProfileScreen GetX logout button opens dialog and can cancel',
        (WidgetTester tester) async {
      final controller = ProfileController();
      Get.put(controller);
      controller.customUser.value = testUser;

      await tester.pumpWidget(
        const GetMaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap logout button
      await tester.tap(find.text('Keluar dari Akun'));
      await tester.pumpAndSettle();

      // Dialog konfirmasi muncul
      expect(find.text('Konfirmasi Keluar'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);

      // Tap Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Dialog tertutup, user tetap aktif
      expect(find.text('Konfirmasi Keluar'), findsNothing);
      expect(find.text('John Doe'), findsOneWidget);
    });
  });
}
