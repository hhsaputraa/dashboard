# Flutter & Dart ProGuard/R8 Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Flutter deferred components (Google Play Core is optional when deferred components are not used)
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Keep native methods and JNI callbacks
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep GetX and model reflection/deserialization if any
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Protect cryptography provider & encrypt package
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# Strip unnecessary debug logs and assertions in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
}
