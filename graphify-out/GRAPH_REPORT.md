# Graph Report - .  (2026-08-27)

## Corpus Check
- Corpus is ~42,168 words - fits in a single context window. You may not need a graph.

## Summary
- 358 nodes · 444 edges · 22 communities (18 shown, 4 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Windows Native Runner
- Auth Feature & Services
- Dashboard Feature
- Auth Presentation
- Module Group 4
- Module Group 5
- Module Group 6
- Module Group 7
- Module Group 8
- Module Group 9
- Core Constants
- Test Suite
- Module Group 12
- Core Security & AES
- Module Group 14
- Module Group 15
- Module Group 20
- Module Group 21

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

## Communities (22 total, 4 thin omitted)

### Community 0 - "Windows Native Runner"
Cohesion: 0.07
Nodes (51): Point, RECT, Size, unique_ptr, DartProject, HWND, LPARAM, LRESULT (+43 more)

### Community 1 - "Auth Feature & Services"
Cohesion: 0.05
Nodes (41): bool get, Client, dart:async, dart:convert, FlutterSecureStorage, baseUrlNotifier, checkHealth, _cleanUrl (+33 more)

### Community 2 - "Dashboard Feature"
Cohesion: 0.06
Nodes (33): core/constants/app_constants.dart, core/network/api_client.dart, core/theme/app_theme.dart, feature/auth/presentation/login_screen.dart, accentColor, AppTheme, backgroundColor, primaryColor (+25 more)

### Community 3 - "Auth Presentation"
Cohesion: 0.06
Nodes (34): ApiClient, _apiClient, build, createState, dispose, initState, _isTesting, _resetUrl (+26 more)

### Community 4 - "Module Group 4"
Cohesion: 0.09
Nodes (18): Cocoa, Flutter, flutter_secure_storage_macos, FlutterMacOS, FlutterPluginRegistry, FlutterSceneDelegate, FlutterViewController, Foundation (+10 more)

### Community 5 - "Module Group 5"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 6 - "Module Group 6"
Cohesion: 0.08
Nodes (23): FormState, _authService, build, _buildInputDecoration, createState, _defaultBorder, dispose, _enabledBorder (+15 more)

### Community 7 - "Module Group 7"
Cohesion: 0.11
Nodes (17): AuthResult, failure, isSuccess, message, success, user, email, fromJson (+9 more)

### Community 8 - "Module Group 8"
Cohesion: 0.16
Nodes (10): Any, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, AppDelegate, Bool, AppDelegate, Bool (+2 more)

### Community 9 - "Module Group 9"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 10 - "Core Constants"
Cohesion: 0.17
Nodes (11): aesKey, AppConstants, appName, appTagline, baseUrlAndroidEmulator, baseUrlLocal, keyAuthToken, keyCustomBaseUrl (+3 more)

### Community 11 - "Test Suite"
Cohesion: 0.18
Nodes (8): package:dashboard/feature/auth/models/auth_result.dart, package:dashboard/feature/auth/models/user_model.dart, package:dashboard/feature/dashboard/presentation/dashboard_screen.dart, package:dashboard/main.dart, package:flutter_test/flutter_test.dart, main, main, main

### Community 12 - "Module Group 12"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 13 - "Core Security & AES"
Cohesion: 0.22
Nodes (8): ../constants/app_constants.dart, dart:math, dart:typed_data, AesEncryption, decrypt, encrypt, package:convert/convert.dart, package:encrypt/encrypt.dart

## Knowledge Gaps
- **126 isolated node(s):** `AppConstants`, `appName`, `appTagline`, `baseUrlLocal`, `baseUrlAndroidEmulator` (+121 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ApiClient` connect `Auth Presentation` to `Auth Feature & Services`?**
  _High betweenness centrality (0.060) - this node is a cross-community bridge._
- **Why does `FlutterWindow` connect `Windows Native Runner` to `Module Group 4`?**
  _High betweenness centrality (0.056) - this node is a cross-community bridge._
- **Are the 4 inferred relationships involving `MessageHandler` (e.g. with `Destroy` and `GetClientArea`) actually correct?**
  _`MessageHandler` has 4 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `Create` (e.g. with `Destroy` and `UpdateTheme`) actually correct?**
  _`Create` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppConstants`, `appName`, `appTagline` to the rest of the system?**
  _126 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Windows Native Runner` be split into smaller, more focused modules?**
  _Cohesion score 0.06594071385359952 - nodes in this community are weakly interconnected._
- **Should `Auth Feature & Services` be split into smaller, more focused modules?**
  _Cohesion score 0.048726467331118496 - nodes in this community are weakly interconnected._