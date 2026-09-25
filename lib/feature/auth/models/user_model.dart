import 'package:dashboard/core/constants/app_constants.dart';

class UserModel {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final bool isAdmin;
  final bool isActive;
  final String? lastLoginAt;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.isAdmin,
    this.isActive = true,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id_app_users'] is int
          ? json['id_app_users']
          : (int.tryParse(json['id_app_users']?.toString() ?? '0') ?? 0),
      username: json['username']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isAdmin: json['is_admin'] == true ||
          json['is_admin'] == AppConstants.roleAdminNumericFlag,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      lastLoginAt: json['last_login_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_app_users': id,
      'username': username,
      'full_name': fullName,
      'email': email,
      'is_admin': isAdmin,
      'is_active': isActive,
      'last_login_at': lastLoginAt,
    };
  }
}
