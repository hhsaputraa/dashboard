# Graph Report - .  (2026-08-27)

## Corpus Check
- Corpus is ~45,129 words - fits in a single context window. You may not need a graph.

## Summary
- 480 nodes · 602 edges · 33 communities (29 shown, 4 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Windows Native Runner
- Module Group 1
- Home Dashboard Presentation & Widgets
- Module Group 3
- Module Group 4
- Module Group 5
- Auth Presentation
- Auth Feature & Services
- Module Group 8
- Home Dashboard Presentation & Widgets
- Module Group 10
- Core Network & API Client
- Module Group 12
- Test Suite
- Module Group 14
- Auth Feature & Services
- Module Group 16
- Core Constants
- Module Group 18
- Module Group 19
- Core Security & AES
- Module Group 21
- Core Theme
- Module Group 23
- Dashboard Feature
- Module Group 25
- Module Group 26
- Module Group 31
- Module Group 32

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

## Communities (33 total, 4 thin omitted)

### Community 0 - "Windows Native Runner"
Cohesion: 0.07
Nodes (51): Point, RECT, Size, unique_ptr, DartProject, HWND, LPARAM, LRESULT (+43 more)

### Community 1 - "Module Group 1"
Cohesion: 0.06
Nodes (28): Any, Cocoa, Flutter, flutter_secure_storage_macos, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS (+20 more)

### Community 2 - "Home Dashboard Presentation & Widgets"
Cohesion: 0.08
Nodes (26): kpi_stat_card.dart, DashboardSummary, build, currencyFormat, KpiSummarySection, summary, build, currencyFormat (+18 more)

### Community 3 - "Module Group 3"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 4 - "Module Group 4"
Cohesion: 0.08
Nodes (23): DateTime, availableSnapshots, calculateGrandTotal, calculateMonthlyTotals, calculateProductTotals, date, DummySnapshotRepository, id (+15 more)

### Community 5 - "Module Group 5"
Cohesion: 0.08
Nodes (23): FormState, _authService, build, _buildInputDecoration, createState, _defaultBorder, dispose, _enabledBorder (+15 more)

### Community 6 - "Auth Presentation"
Cohesion: 0.09
Nodes (22): _apiClient, build, createState, dispose, initState, _isTesting, _resetUrl, _saveUrl (+14 more)

### Community 7 - "Auth Feature & Services"
Cohesion: 0.09
Nodes (21): bool get, dart:async, FlutterSecureStorage, _apiClient, currentToken, currentUser, fetchProfile, initSession (+13 more)

### Community 8 - "Module Group 8"
Cohesion: 0.10
Nodes (20): double get, bulanan, fromList, idKantor, idPinjaman, idTrxBunga, InterestRecord, jenisPinjaman (+12 more)

### Community 9 - "Home Dashboard Presentation & Widgets"
Cohesion: 0.10
Nodes (20): build, _buildDashboardContent, createState, _currencyFormat, _dashboardData, _dashboardService, _errorMessage, HomeScreen (+12 more)

### Community 10 - "Module Group 10"
Cohesion: 0.11
Nodes (17): AuthResult, failure, isSuccess, message, success, user, email, fromJson (+9 more)

### Community 11 - "Core Network & API Client"
Cohesion: 0.12
Nodes (16): Client, baseUrlNotifier, checkHealth, _cleanUrl, _customBaseUrl, _httpClient, init, _instance (+8 more)

### Community 12 - "Module Group 12"
Cohesion: 0.13
Nodes (14): DashboardData, fromJson, month, monthlyAverage, monthlyTrend, MonthlyTrendItem, name, percentage (+6 more)

### Community 13 - "Test Suite"
Cohesion: 0.13
Nodes (11): package:dashboard/feature/auth/models/auth_result.dart, package:dashboard/feature/auth/models/user_model.dart, package:dashboard/feature/auth/presentation/login_screen.dart, package:dashboard/feature/dashboard/presentation/dashboard_screen.dart, package:dashboard/main.dart, package:flutter_test/flutter_test.dart, main, createWidgetUnderTest (+3 more)

### Community 14 - "Module Group 14"
Cohesion: 0.16
Nodes (11): _LoginBackground, _LoginFooter, _LoginHeader, build, ProfileScreen, build, ReportScreen, build (+3 more)

### Community 15 - "Auth Feature & Services"
Cohesion: 0.17
Nodes (11): dart:convert, ApiClient, AuthService, _apiClient, _authService, DashboardService, fetchDashboardData, ../model/dashboard_data.dart (+3 more)

### Community 16 - "Module Group 16"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 17 - "Core Constants"
Cohesion: 0.17
Nodes (11): aesKey, AppConstants, appName, appTagline, baseUrlAndroidEmulator, baseUrlLocal, keyAuthToken, keyCustomBaseUrl (+3 more)

### Community 18 - "Module Group 18"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 19 - "Module Group 19"
Cohesion: 0.22
Nodes (8): Color, IconData, build, icon, iconColor, KpiStatCard, title, value

### Community 20 - "Core Security & AES"
Cohesion: 0.22
Nodes (8): ../constants/app_constants.dart, dart:math, dart:typed_data, AesEncryption, decrypt, encrypt, package:convert/convert.dart, package:encrypt/encrypt.dart

### Community 21 - "Module Group 21"
Cohesion: 0.25
Nodes (7): core/constants/app_constants.dart, core/network/api_client.dart, core/theme/app_theme.dart, feature/auth/presentation/login_screen.dart, BankDashboardApp, build, main

### Community 22 - "Core Theme"
Cohesion: 0.25
Nodes (7): accentColor, AppTheme, backgroundColor, primaryColor, secondaryColor, surfaceColor, static const Color

### Community 23 - "Module Group 23"
Cohesion: 0.25
Nodes (7): build, DashboardErrorView, DashboardLoadingView, errorMessage, message, onRetry, VoidCallback

### Community 24 - "Dashboard Feature"
Cohesion: 0.50
Nodes (3): build, DashboardScreen, package:dashboard/core/theme/app_theme.dart

## Knowledge Gaps
- **199 isolated node(s):** `AppConstants`, `appName`, `appTagline`, `baseUrlLocal`, `baseUrlAndroidEmulator` (+194 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ApiClient` connect `Auth Feature & Services` to `Core Network & API Client`, `Auth Presentation`, `Auth Feature & Services`?**
  _High betweenness centrality (0.067) - this node is a cross-community bridge._
- **Why does `AuthService` connect `Auth Feature & Services` to `Module Group 5`, `Auth Feature & Services`?**
  _High betweenness centrality (0.037) - this node is a cross-community bridge._
- **Why does `FlutterWindow` connect `Windows Native Runner` to `Module Group 1`?**
  _High betweenness centrality (0.031) - this node is a cross-community bridge._
- **Are the 4 inferred relationships involving `MessageHandler` (e.g. with `Destroy` and `GetClientArea`) actually correct?**
  _`MessageHandler` has 4 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppConstants`, `appName`, `appTagline` to the rest of the system?**
  _199 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Windows Native Runner` be split into smaller, more focused modules?**
  _Cohesion score 0.06594071385359952 - nodes in this community are weakly interconnected._
- **Should `Module Group 1` be split into smaller, more focused modules?**
  _Cohesion score 0.05807200929152149 - nodes in this community are weakly interconnected._