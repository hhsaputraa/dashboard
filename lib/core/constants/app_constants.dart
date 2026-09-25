class AppConstants {
  AppConstants._();

  static const String appName = 'Supra Dashboard';
  static const String appTagline = 'Sistem Information';

  static const String baseUrlLocal = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8097',
  );

  static const String baseUrlAndroidEmulator = String.fromEnvironment(
    'API_BASE_URL_ANDROID',
    defaultValue: 'http://10.0.2.2:8097',
  );

  static const String aesKey = String.fromEnvironment(
    'AES_KEY',
    defaultValue: 'f17ba46472fa64e40ca496d1b4c91e8f',
  );
  static const String keyAuthToken = 'auth_token';
  static const String keyUserData = 'user_data';
  static const String keyCustomBaseUrl = 'custom_base_url';

  /// Flag numerik dari backend Go untuk role Admin (7 = Super Admin / Administrator)
  static const int roleAdminNumericFlag = 7;
}
