import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dashboard/feature/auth/models/user_model.dart';
import 'package:dashboard/feature/profile/controllers/profile_controller.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  final testAdminUser = UserModel(
    id: 1,
    username: 'superadmin',
    fullName: 'Budi Santoso',
    email: 'budi@bank.co.id',
    isAdmin: true,
    isActive: true,
    lastLoginAt: '2026-09-02T10:30:00Z',
  );

  final testStandardUser = UserModel(
    id: 2,
    username: 'userbiasa',
    fullName: 'Siti',
    email: 'siti@bank.co.id',
    isAdmin: false,
    isActive: false,
    lastLoginAt: null,
  );

  test('ProfileController computes initials correctly', () {
    final controller = ProfileController();
    Get.put(controller);

    expect(controller.getInitials('Budi Santoso'), 'BS');
    expect(controller.getInitials('Siti'), 'S');
    expect(controller.getInitials('  Ahmad   Dahlan  '), 'AD');
    expect(controller.getInitials(''), 'U');
    expect(controller.getInitials(null), 'U');
  });

  test('ProfileController formats last login timestamp correctly', () {
    final controller = ProfileController();
    Get.put(controller);

    expect(controller.formatLastLogin(null), 'Aktif Sekarang');
    expect(controller.formatLastLogin(''), 'Aktif Sekarang');
    expect(controller.formatLastLogin('invalid-date'), 'Aktif Sekarang');

    final formatted = controller.formatLastLogin('2026-09-02T10:30:00Z');
    expect(formatted.contains('02 Sep 2026'), isTrue);
    expect(formatted.endsWith('WIB'), isTrue);
  });

  test('ProfileController exposes reactive user properties, role, and status', () {
    final controller = ProfileController();
    Get.put(controller);

    // Initial state when user is null
    expect(controller.user, isNull);
    expect(controller.initials, 'U');
    expect(controller.userRole, 'User');
    expect(controller.userStatus, 'Non-Aktif');
    expect(controller.formattedLastLogin, 'Aktif Sekarang');

    // Update with Admin user
    controller.customUser.value = testAdminUser;
    expect(controller.user, testAdminUser);
    expect(controller.initials, 'BS');
    expect(controller.userRole, 'Administrator');
    expect(controller.userStatus, 'Aktif');

    // Update with Standard user
    controller.customUser.value = testStandardUser;
    expect(controller.user, testStandardUser);
    expect(controller.initials, 'S');
    expect(controller.userRole, 'User');
    expect(controller.userStatus, 'Non-Aktif');
  });

  test('ProfileController logout state defaults to false', () {
    final controller = ProfileController();
    Get.put(controller);
    controller.customUser.value = testAdminUser;

    expect(controller.isLoggingOut.value, isFalse);
    expect(controller.isRefreshing.value, isFalse);
  });
}
