# Graph Report - .  (2026-08-27)

## Corpus Check
- Corpus is ~42,166 words - fits in a single context window. You may not need a graph.

## Summary
- 355 nodes · 444 edges · 25 communities (21 shown, 4 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Windows Native Runner (Win32/C++)
- Auth Service & Secure Storage
- macOS Runner & Plugins
- Linux Runner (GTK/GLib)
- Auth & Navigation UI State
- Authentication Domain Models
- Login & Server Config Presentation
- Core API Client & Network
- Home & Login UI Components
- Widget Tests & Test Suite
- iOS Native Runner (Swift/ObjC)
- Windows Native Entry Point
- App Constants & Configuration
- Dashboard Feature UI & Theme Integration
- Web PWA Manifest
- AES Encryption Core Utility
- App Theme & Styling
- Windows Plugin Registrant
- Android Native Activity (Kotlin)
- Nullable Bool Type Node
- Nullable String Type Node

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 22 edges
2. `MessageHandler` - 12 edges
3. `FlutterWindow` - 10 edges
4. `Create` - 10 edges
5. `WndProc` - 10 edges
6. `MessageHandler` - 9 edges
7. `_MyApplication` - 7 edges
8. `OnCreate` - 7 edges
9. `WindowClassRegistrar` - 7 edges
10. `Destroy` - 7 edges

## Surprising Connections (you probably didn't know these)
- `OnCreate` --calls--> `RegisterPlugins()`  [INFERRED]
  windows/runner/flutter_window.h → windows/flutter/generated_plugin_registrant.cc
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `Win32Window::Win32Window()` --calls--> `Destroy`  [INFERRED]
  windows/runner/win32_window.cpp → windows/runner/win32_window.h
- `my_application_activate()` --calls--> `fl_register_plugins()`  [INFERRED]
  linux/runner/my_application.cc → linux/flutter/generated_plugin_registrant.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  linux/runner/main.cc → linux/runner/my_application.cc

## Import Cycles
- None detected.

## Communities (25 total, 4 thin omitted)

### Community 0 - "Windows Native Runner (Win32/C++)"
Cohesion: 0.07
Nodes (51): Point, RECT, Size, unique_ptr, DartProject, HWND, LPARAM, LRESULT (+43 more)

### Community 1 - "Auth Service & Secure Storage"
Cohesion: 0.05
Nodes (39): bool get, Client, ../../../core/security/aes_encryption.dart, dart:async, dart:convert, FlutterSecureStorage, _apiClient, AuthService (+31 more)

### Community 2 - "macOS Runner & Plugins"
Cohesion: 0.09
Nodes (18): Cocoa, Flutter, flutter_secure_storage_macos, FlutterMacOS, FlutterPluginRegistry, FlutterSceneDelegate, FlutterViewController, Foundation (+10 more)

### Community 3 - "Linux Runner (GTK/GLib)"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 4 - "Auth & Navigation UI State"
Cohesion: 0.08
Nodes (23): ../../core/presentation/server_config_dialog.dart, FormState, ../../home/presentation/main_navigation_screen.dart, _authService, build, _buildInputDecoration, createState, _defaultBorder (+15 more)

### Community 5 - "Authentication Domain Models"
Cohesion: 0.11
Nodes (17): AuthResult, failure, isSuccess, message, success, user, email, fromJson (+9 more)

### Community 6 - "Login & Server Config Presentation"
Cohesion: 0.13
Nodes (17): LoginScreen, _LoginScreenState, ServerConfigDialog, _ServerConfigDialogState, build, createState, MainNavigationScreen, _MainNavigationScreenState (+9 more)

### Community 7 - "Core API Client & Network"
Cohesion: 0.11
Nodes (17): ApiClient, _apiClient, build, createState, dispose, initState, _isTesting, _resetUrl (+9 more)

### Community 8 - "Home & Login UI Components"
Cohesion: 0.14
Nodes (13): _LoginBackground, _LoginFooter, _LoginHeader, build, HomeScreen, build, ProfileScreen, build (+5 more)

### Community 9 - "Widget Tests & Test Suite"
Cohesion: 0.13
Nodes (11): package:dashboard/auth/models/auth_result.dart, package:dashboard/auth/models/user_model.dart, package:dashboard/auth/presentation/login_screen.dart, package:dashboard/dashboard/presentation/dashboard_screen.dart, package:dashboard/main.dart, package:flutter_test/flutter_test.dart, main, createWidgetUnderTest (+3 more)

### Community 10 - "iOS Native Runner (Swift/ObjC)"
Cohesion: 0.16
Nodes (10): Any, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, AppDelegate, Bool, AppDelegate, Bool (+2 more)

### Community 11 - "Windows Native Entry Point"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 12 - "App Constants & Configuration"
Cohesion: 0.17
Nodes (11): aesKey, AppConstants, appName, appTagline, baseUrlAndroidEmulator, baseUrlLocal, keyAuthToken, keyCustomBaseUrl (+3 more)

### Community 13 - "Dashboard Feature UI & Theme Integration"
Cohesion: 0.20
Nodes (9): auth/presentation/login_screen.dart, core/constants/app_constants.dart, core/network/api_client.dart, core/theme/app_theme.dart, build, DashboardScreen, BankDashboardApp, build (+1 more)

### Community 14 - "Web PWA Manifest"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 15 - "AES Encryption Core Utility"
Cohesion: 0.22
Nodes (8): ../constants/app_constants.dart, dart:math, dart:typed_data, AesEncryption, decrypt, encrypt, package:convert/convert.dart, package:encrypt/encrypt.dart

### Community 16 - "App Theme & Styling"
Cohesion: 0.25
Nodes (7): accentColor, AppTheme, backgroundColor, primaryColor, secondaryColor, surfaceColor, static const Color

## Knowledge Gaps
- **126 isolated node(s):** `AuthResult`, `isSuccess`, `message`, `user`, `success` (+121 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `FlutterWindow` connect `Windows Native Runner (Win32/C++)` to `macOS Runner & Plugins`?**
  _High betweenness centrality (0.057) - this node is a cross-community bridge._
- **Why does `ApiClient` connect `Core API Client & Network` to `Auth Service & Secure Storage`?**
  _High betweenness centrality (0.051) - this node is a cross-community bridge._
- **Are the 4 inferred relationships involving `MessageHandler` (e.g. with `Destroy` and `GetClientArea`) actually correct?**
  _`MessageHandler` has 4 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `Create` (e.g. with `Destroy` and `UpdateTheme`) actually correct?**
  _`Create` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AuthResult`, `isSuccess`, `message` to the rest of the system?**
  _126 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Windows Native Runner (Win32/C++)` be split into smaller, more focused modules?**
  _Cohesion score 0.06594071385359952 - nodes in this community are weakly interconnected._
- **Should `Auth Service & Secure Storage` be split into smaller, more focused modules?**
  _Cohesion score 0.05121951219512195 - nodes in this community are weakly interconnected._