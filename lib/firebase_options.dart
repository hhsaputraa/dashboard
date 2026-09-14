import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Secure [FirebaseOptions] for use with your Firebase apps.
///
/// If environment variables are passed via `--dart-define` (e.g. in CI/CD),
/// they will be used. Otherwise, returns `null` so Firebase automatically
/// and securely reads configuration directly from native files:
/// - iOS: `GoogleService-Info.plist` (bundled in Xcode Resources)
/// - Android: `google-services.json`
///
/// This avoids hardcoding sensitive credentials in source code.
class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      final apiKey = const String.fromEnvironment('FIREBASE_WEB_API_KEY');
      if (apiKey.isEmpty) return null;
      return const FirebaseOptions(
        apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
        appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
        messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
        authDomain: String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN'),
        storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        final apiKey = const String.fromEnvironment('FIREBASE_IOS_API_KEY');
        if (apiKey.isNotEmpty) {
          return const FirebaseOptions(
            apiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY'),
            appId: String.fromEnvironment('FIREBASE_IOS_APP_ID'),
            messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
            projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
            storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
            iosBundleId: String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
          );
        }
        // Returns null to load natively from GoogleService-Info.plist
        return null;

      case TargetPlatform.android:
        final apiKey = const String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
        if (apiKey.isNotEmpty) {
          return const FirebaseOptions(
            apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
            appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
            messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
            projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
            storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
          );
        }
        // Returns null to load natively from google-services.json
        return null;

      default:
        return null;
    }
  }
}
