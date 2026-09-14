# Graph Report - dashboard  (2026-09-09)

## Corpus Check
- 162 files · ~250,820 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1583 nodes · 2215 edges · 139 communities (90 shown, 49 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 29 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `f2bcc21e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Create
- user_model.dart
- branch_product_comparison_card.dart
- branch_product_comparison_controller.dart
- home_branch_comparison_card.dart
- analytics_helper.dart
- Migrating Dart Tests to Package Checks
- Resolving Dart Static Analysis Errors
- auth_service.dart
- monthly_trend_chart.dart
- report_controller.dart
- home_controller.dart
- home_binding.dart
- branch_product_comparison_helper.dart
- app_pages.dart
- Compiling C Code into Code Assets with Native Assets Hooks
- Internationalizing Flutter Applications
- GeneratedPluginRegistrant.swift
- executive_analytics_helper.dart
- product_breakdown_card.dart
- Dart Primary Constructors & New Constructor Syntax Skill
- server_config_dialog.dart
- profile_controller.dart
- Generating FFI Bindings using package:ffigen
- Flutter
- app_theme.dart
- login_controller.dart
- product_breakdown_benchmark_test.dart
- api_client.dart
- item_picker_bottom_sheet.dart
- StatelessWidget
- quarterly_growth_chart.dart
- main.dart
- dashboard_service.dart
- kantor_filter_chips.dart
- revenue_controller.dart
- portfolio_donut_chart.dart
- List
- package:flutter/material.dart
- home_screen.dart
- my_application.cc
- home_widgets_test.dart
- AppDelegate
- login_screen.dart
- report_screen.dart
- kpi_stat_card.dart
- Implementing Dart Patterns
- dashboard_data.dart
- description
- aes_encryption.dart
- /graphify
- State
- revenue_screen.dart
- branch_bar_chart.dart
- Tasklist Refactoring: Dekomposisi God Nodes & Bridges
- Testing and Mocking Dart Applications
- Implementing Dart and Flutter Test Coverage
- Implementing Flutter Integration Tests
- main_navigation_screen.dart
- Building Dart CLI Applications
- static final
- app_constants.dart
- Implementing Adaptive Layouts
- Testing Dart and Flutter Applications
- dashboard_state_views.dart
- string
- kpi_summary_section.dart
- url_security_validator.dart
- Managing Dart Dependencies
- Analyzing and Fixing Dart Code
- Implementing Flutter Networking
- quarterly_growth_calculator.dart
- Tasklist Security Hardening: Paket 1 (Network & Platform Hardening)
- ProductBreakdownCard Search, Bounded Height, and Scrollbar Implementation Plan
- Resolving Flutter Layout Errors
- Spec: Pendapatan Perbandingan Kantor Cabang Berdasarkan Jenis Pinjaman
- ios/RunnerTests/RunnerTests.swift
- Login Screen Revamp Plan (Anti-AI Slop & High Performance)
- package:dashboard/feature/home/model/interest_record.dart
- package:get/get.dart
- analytics_leaderboard_card.dart
- AppDelegate
- Tasks
- graphify reference: extra exports and benchmark
- ios/Runner/AppDelegate.swift
- package:dashboard/feature/home/model/dashboard_data.dart
- MainActivity
- profile_screen.dart
- Splash Background (Background)
- Splash Background (Background)
- Splash Background (Background)
- Splash Background (Background)
- App Icon (Ic Launcher)
- App Icon (Launcher Icon)
- App Icon (Ic Launcher)
- App Icon (Launcher Icon)
- App Icon (Ic Launcher)
- App Icon (Launcher Icon)
- App Icon (Ic Launcher)
- App Icon (Launcher Icon)
- App Icon (Ic Launcher)
- App Icon (Launcher Icon)
- App Icon (Icon App 1024X1024@1X)
- App Icon (Icon App 20X20@1X)
- App Icon (Icon App 20X20@2X)
- App Icon (Icon App 20X20@3X)
- App Icon (Icon App 29X29@1X)
- App Icon (Icon App 29X29@2X)
- App Icon (Icon App 29X29@3X)
- App Icon (Icon App 40X40@1X)
- App Icon (Icon App 40X40@2X)
- App Icon (Icon App 40X40@3X)
- App Icon (Icon App 50X50@1X)
- App Icon (Icon App 50X50@2X)
- App Icon (Icon App 57X57@1X)
- App Icon (Icon App 57X57@2X)
- App Icon (Icon App 60X60@2X)
- App Icon (Icon App 60X60@3X)
- App Icon (Icon App 72X72@1X)
- App Icon (Icon App 72X72@2X)
- App Icon (Icon App 76X76@1X)
- App Icon (Icon App 76X76@2X)
- App Icon (Icon App 83.5X83.5@2X)
- Splash Background (Background)
- Splash Background (Darkbackground)
- Visual Asset (Launchimage@2X)
- Visual Asset (Launchimage@3X)
- Visual Asset (Launchimage)
- bool?
- String?
- App Icon (Favicon)
- Visual Asset (Icon 192)
- Visual Asset (Icon 512)
- Visual Asset (Icon Maskable 192)
- Visual Asset (Icon Maskable 512)
- static const List
- Tasklist Refactoring & Improvement Fase 2

## God Nodes (most connected - your core abstractions)
1. `Migrating Dart Tests to Package Checks` - 35 edges
2. `Compiling C Code into Code Assets with Native Assets Hooks` - 26 edges
3. `Internationalizing Flutter Applications` - 26 edges
4. `Dart Primary Constructors & New Constructor Syntax Skill` - 25 edges
5. `Flutter` - 24 edges
6. `Create` - 23 edges
7. `Generating FFI Bindings using package:ffigen` - 23 edges
8. `build` - 22 edges
9. `Win32Window` - 22 edges
10. `Implementing Dart and Flutter Test Coverage` - 19 edges

## Surprising Connections (you probably didn't know these)
- `System Architecture & Layering Design` --references--> `AuthResult`  [EXTRACTED]
  plans/architecture.md → lib/feature/auth/models/auth_result.dart
- `Serializing JSON Manually in Flutter` --references--> `email`  [EXTRACTED]
  .agents/skills/flutter-implement-json-serialization/SKILL.md → lib/feature/auth/models/user_model.dart
- `Spec: Pendapatan Perbandingan Kantor Cabang Berdasarkan Jenis Pinjaman` --references--> `InterestRecord`  [EXTRACTED]
  plans/branch_product_comparison_spec.md → lib/feature/home/model/interest_record.dart
- `Architecting Flutter Applications` --references--> `_apiClient`  [EXTRACTED]
  .agents/skills/flutter-apply-architecture-best-practices/SKILL.md → lib/feature/home/services/dashboard_service.dart
- `/graphify` --references--> `dart_entrypoint_arguments`  [EXTRACTED]
  .agents/skills/graphify/SKILL.md → linux/runner/my_application.cc

## Import Cycles
- None detected.

## Communities (139 total, 49 thin omitted)

### Community 0 - "Create"
Cohesion: 0.07
Nodes (47): PluginRegistry, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND, LPARAM (+39 more)

### Community 1 - "user_model.dart"
Cohesion: 0.13
Nodes (14): @Deprecated, 1. Core Architectural Principles, 2. Spec-Driven Development Workflow, 3. Tooling & MCP Integration Rules, Project Rules & Architectural Guidelines, email, fromJson, fullName (+6 more)

### Community 2 - "branch_product_comparison_card.dart"
Cohesion: 0.06
Nodes (34): ComparisonViewMode, _availableBranches, _availableProducts, build, _buildBarChart, _buildLineBranchFocusChip, _buildLineChart, _buildModeButton (+26 more)

### Community 3 - "branch_product_comparison_controller.dart"
Cohesion: 0.07
Nodes (29): availableBranches, availableProducts, ComparisonViewMode, _currentRecords, focusedBranchIdForLine, _recomputeSeries, selectedBranchesList, selectedBranchIds (+21 more)

### Community 4 - "home_branch_comparison_card.dart"
Cohesion: 0.05
Nodes (39): _applyPreset, bankAverageMonthlyTrend, bankAverageTotal, _benchmarkColor, branches, BranchViewMode, build, _buildLegendBadge (+31 more)

### Community 5 - "analytics_helper.dart"
Cohesion: 0.10
Nodes (19): AnalyticsHelper, branches, BranchPerformance, computeAnalytics, idKantor, label, monthsLabel, percentage (+11 more)

### Community 6 - "Migrating Dart Tests to Package Checks"
Cohesion: 0.04
Nodes (45): 10. Dynamic Map / JSON Lookup Casting, 1. Dependency Setup, 1. Specific Error Matchers, 2. Identify and Plan Target Files, 2. The `anything` Matcher, 2. The `reason` Parameter is now `because`, 3. Asynchronous Custom Expectations, 3. Migrating a File (Incremental or Full) (+37 more)

### Community 7 - "Resolving Dart Static Analysis Errors"
Cohesion: 0.18
Nodes (11): Contents, Core Concepts & Guidelines, Resolving Dart Static Analysis Errors, Error Handling, Example: Fixing Dynamic List Assignments, Example: Fixing Null Safety with `late`, Examples, Null Safety (+3 more)

### Community 8 - "auth_service.dart"
Cohesion: 0.07
Nodes (29): ApiClient get, bool get, FlutterSecureStorage, _apiClient, currentToken, currentUser, fetchProfile, initSession (+21 more)

### Community 9 - "monthly_trend_chart.dart"
Cohesion: 0.05
Nodes (36): dashboard_data.dart, int?, chartMaxY, compute, formatCompactValue, MonthlyTrendCalculationResult, spots, totalBunga (+28 more)

### Community 10 - "report_controller.dart"
Cohesion: 0.05
Nodes (36): 1. Scaffold the Application, 2. Configure the Router, Contents, Core Concepts, Implementing Routing and Deep Linking, Examples, If configuring for Android:, If configuring for iOS: (+28 more)

### Community 11 - "home_controller.dart"
Cohesion: 0.07
Nodes (26): activeTrend, availableOffices, _calculateActiveTrend, changeKantor, currencyFormat, dashboardData, dashboardService, dateTimeFormat (+18 more)

### Community 12 - "home_binding.dart"
Cohesion: 0.10
Nodes (22): Bindings, ../controllers/branch_product_comparison_controller.dart, ../controllers/home_controller.dart, ../controllers/login_controller.dart, ../controllers/navigation_controller.dart, ../controllers/profile_controller.dart, ../controllers/revenue_controller.dart, GetxController (+14 more)

### Community 13 - "branch_product_comparison_helper.dart"
Cohesion: 0.12
Nodes (15): addMonthly, BranchInfo, branchLabel, BranchProductComparisonHelper, BranchProductSeries, buildSeriesMap, getAvailableBranches, getAvailableProducts (+7 more)

### Community 14 - "app_pages.dart"
Cohesion: 0.13
Nodes (13): graphify reference: transcribe video and audio, AppPages, initial, routes, package:dashboard/feature/auth/bindings/auth_binding.dart, package:dashboard/feature/auth/presentation/splash_screen.dart, package:dashboard/feature/home/bindings/home_binding.dart, package:dashboard/feature/profile/bindings/profile_binding.dart (+5 more)

### Community 15 - "Compiling C Code into Code Assets with Native Assets Hooks"
Cohesion: 0.10
Nodes (20): 1. Local Execution Sandbox, 2. Verify Target Outputs, 3. Verify Tree-Shaking Stripping, C Source and Bindings Setup, Choosing an Integration Approach, Constraints, Contents, Defining the C Library Build Spec (+12 more)

### Community 16 - "Internationalizing Flutter Applications"
Cohesion: 0.10
Nodes (19): 1. Add Dependencies, 1. Define ARB Files, 2. Enable Code Generation, 2. Generate Localization Classes, 3. Consume Localized Strings, 3. Create Configuration File, 4. Configure the App Entry Point, Advanced Formatting (+11 more)

### Community 17 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.18
Nodes (9): Cocoa, FlutterMacOS, FlutterPluginRegistry, FlutterViewController, Foundation, RegisterGeneratedPlugins(), MainFlutterWindow, NSWindow (+1 more)

### Community 18 - "executive_analytics_helper.dart"
Cohesion: 0.11
Nodes (18): bankAverageMonthlyTrend, bankAverageTotal, branches, description, dominantPercentage, dominantProduct, ExecutiveAnalyticsHelper, ExecutiveAnalyticsResult (+10 more)

### Community 19 - "product_breakdown_card.dart"
Cohesion: 0.06
Nodes (31): backgroundColor, breakdown, build, _buildListContainer, _cachedLowerNames, _cachedSource, _cardDecoration, _cardHeaderStyle (+23 more)

### Community 20 - "Dart Primary Constructors & New Constructor Syntax Skill"
Cohesion: 0.11
Nodes (18): 1. Overview, 2.1 Basic Class Header Syntax, 2.3 Constant Primary Constructors, 2.4 Extension Types, 2.5 Empty Body Semicolon Shorthand (`;`), 2. Syntax Reference, 3.1 Primary Initializer Scope, 3.2 Late Instance Variables Restriction (+10 more)

### Community 21 - "server_config_dialog.dart"
Cohesion: 0.06
Nodes (31): _apiClient, build, createState, dispose, initState, _isTesting, _resetUrl, _saveUrl (+23 more)

### Community 22 - "profile_controller.dart"
Cohesion: 0.11
Nodes (17): _authService, customUser, formatLastLogin, formattedLastLogin, getInitials, handleLogout, initials, isLoggingOut (+9 more)

### Community 23 - "Generating FFI Bindings using package:ffigen"
Cohesion: 0.05
Nodes (41): 1. `FfiGenerator`, 2. `Headers`, 3. `Functions`, 4. `Output`, Concrete Example: Binding a C Library, Constraints, Contents, Generating FFI Bindings using package:ffigen (+33 more)

### Community 24 - "Flutter"
Cohesion: 0.10
Nodes (31): graphify reference: add a URL and watch a folder, For /graphify add, For --watch, This file configures the analyzer, which statically analyzes Dart code to, Hapus git lama dan build cache, Dokumentasi Command, FlPluginRegistry, Flutter (+23 more)

### Community 25 - "app_theme.dart"
Cohesion: 0.04
Nodes (46): App Icon (App Icon), Branding Graphic (Bpr Emblem Red), Branding Graphic (Bpr Emblem White), Branding Graphic (Logo), DateFormat?, DateTime, build, dateFormat (+38 more)

### Community 26 - "login_controller.dart"
Cohesion: 0.12
Nodes (16): AuthService get, FormState, GlobalKey, _authService, clearError, errorMessage, formKey, isLoading (+8 more)

### Community 27 - "product_breakdown_benchmark_test.dart"
Cohesion: 0.04
Nodes (47): Graphify, graphify, Architectural Layers, Contents, Data Layer, Data Layer: Service and Repository, Architecting Flutter Applications, Examples (+39 more)

### Community 28 - "api_client.dart"
Cohesion: 0.11
Nodes (17): authHeaders, checkHealth, _cleanUrl, _customBaseUrl, _httpClient, init, _instance, post (+9 more)

### Community 29 - "item_picker_bottom_sheet.dart"
Cohesion: 0.10
Nodes (20): activeColor, applySuffix, build, createState, emptyMessage, _handleQuickSelect, initiallySelected, initState (+12 more)

### Community 30 - "StatelessWidget"
Cohesion: 0.15
Nodes (15): _LoginBackground, _LoginFooter, _LoginHeader, HomeScreen, DashboardErrorView, KantorFilterChips, KpiStatCard, _FastProgressBar (+7 more)

### Community 31 - "quarterly_growth_chart.dart"
Cohesion: 0.12
Nodes (16): _baseRadiusMap, build, _buildQuarterCard, _buildSections, _chartColors, _computeRadiiAndTotal, createState, currencyFormat (+8 more)

### Community 32 - "main.dart"
Cohesion: 0.13
Nodes (13): core/bindings/initial_binding.dart, core/constants/app_constants.dart, core/network/api_client.dart, core/routes/app_pages.dart, core/theme/app_theme.dart, feature/auth/services/auth_service.dart, dependencies, InitialBinding (+5 more)

### Community 33 - "dashboard_service.dart"
Cohesion: 0.19
Nodes (12): dart:io, GetxService, ApiClient, AuthService, _apiClient, _authService, DashboardService, package:dashboard/core/bindings/initial_binding.dart (+4 more)

### Community 34 - "kantor_filter_chips.dart"
Cohesion: 0.13
Nodes (14): build, defaultOffices, id, label, OfficeOption, offices, onKantorChanged, selectedKantor (+6 more)

### Community 35 - "revenue_controller.dart"
Cohesion: 0.13
Nodes (14): analyticsResult, currencyFormat, dashboardService, dateTimeFormat, errorMessage, isLoading, lastFetched, loadData (+6 more)

### Community 36 - "portfolio_donut_chart.dart"
Cohesion: 0.17
Nodes (12): allProducts, breakdown, build, _chartColors, createState, currencyFormat, grandTotal, _navigateToAllProducts (+4 more)

### Community 37 - "List"
Cohesion: 0.25
Nodes (7): idKantor, idPinjaman, idTrxBunga, InterestRecord, jenisPinjaman, _monthKeys, List

### Community 38 - "package:flutter/material.dart"
Cohesion: 0.11
Nodes (16): AnimationController, build, _checkSessionAndNavigate, _controller, createState, dispose, _fadeAnimation, initState (+8 more)

### Community 39 - "home_screen.dart"
Cohesion: 0.14
Nodes (13): HomeController get, build, _buildDashboardContent, _buildStatusIndicator, _controller, package:dashboard/core/presentation/server_config_dialog.dart, package:dashboard/core/presentation/widgets/sync_status_indicator.dart, widgets/dashboard_state_views.dart (+5 more)

### Community 40 - "my_application.cc"
Cohesion: 0.13
Nodes (19): FlView, GApplication, gboolean, gchar, GObject, GtkApplication, first_frame_cb(), my_application_activate() (+11 more)

### Community 41 - "home_widgets_test.dart"
Cohesion: 0.15
Nodes (12): package:dashboard/feature/home/presentation/widgets/hhi_concentration_card.dart, package:dashboard/feature/home/presentation/widgets/home_branch_comparison_card.dart, package:dashboard/feature/home/presentation/widgets/kantor_filter_chips.dart, package:dashboard/feature/home/presentation/widgets/kpi_stat_card.dart, package:dashboard/feature/home/presentation/widgets/kpi_summary_section.dart, package:dashboard/feature/home/presentation/widgets/monthly_trend_chart.dart, package:dashboard/feature/home/presentation/widgets/product_breakdown_card.dart, package:dashboard/feature/revenue/presentation/widgets/branch_bar_chart.dart (+4 more)

### Community 42 - "AppDelegate"
Cohesion: 0.25
Nodes (6): Any, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, AppDelegate, Bool, UIApplication

### Community 43 - "login_screen.dart"
Cohesion: 0.17
Nodes (11): build, _buildInputDecoration, _controller, _defaultBorder, _enabledBorder, _errorBorder, _focusedBorder, _focusedErrorBorder (+3 more)

### Community 44 - "report_screen.dart"
Cohesion: 0.17
Nodes (11): ../controllers/report_controller.dart, dependencies, ReportController, build, _buildCardInfoRow, _buildFilterChips, _buildKolCard, _buildSummaryHeader (+3 more)

### Community 45 - "kpi_stat_card.dart"
Cohesion: 0.17
Nodes (11): IconData, build, _cardDecoration, icon, _iconBorderRadius, iconColor, title, _titleStyle (+3 more)

### Community 46 - "Implementing Dart Patterns"
Cohesion: 0.14
Nodes (15): Algebraic Data Types (Sealed Classes), Contents, Core Pattern Implementations, Implementing Dart Patterns, Examples, Feedback Loop: Exhaustiveness Checking, Guard Clauses and Logical-or, JSON Validation and Destructuring (+7 more)

### Community 47 - "dashboard_data.dart"
Cohesion: 0.12
Nodes (16): interest_record.dart, DashboardData, fromJson, month, monthlyAverage, monthlyTrend, MonthlyTrendItem, name (+8 more)

### Community 48 - "description"
Cohesion: 0.17
Nodes (13): Background Parsing (Large Payload), Contents, Core Guidelines, Serializing JSON Manually in Flutter, Examples, High-Fidelity Model Implementation, Synchronous Parsing (Small Payload), Workflow: Fetching and Parsing JSON (+5 more)

### Community 49 - "aes_encryption.dart"
Cohesion: 0.13
Nodes (15): Agent Guidelines for Dashboard Project, Working with this Codebase, Client, ../constants/app_constants.dart, dart:math, dart:typed_data, AesEncryption, decrypt (+7 more)

### Community 50 - "/graphify"
Cohesion: 0.06
Nodes (32): graphify reference: incremental update and cluster-only, For --cluster-only, For --update (incremental re-extraction), /graphify, For /graphify add and --watch, For /graphify query, For --update and --cluster-only, Honesty Rules (+24 more)

### Community 51 - "State"
Cohesion: 0.21
Nodes (13): ItemPickerBottomSheet, _ItemPickerBottomSheetState, SplashScreen, _SplashScreenState, BranchBarChart, _BranchBarChartState, BranchProductComparisonCard, _BranchProductComparisonCardState (+5 more)

### Community 52 - "revenue_screen.dart"
Cohesion: 0.15
Nodes (12): build, _buildAnalyticsContent, _buildStatusIndicator, _controller, isActive, package:dashboard/feature/home/presentation/widgets/dashboard_state_views.dart, RevenueController get, widgets/analytics_leaderboard_card.dart (+4 more)

### Community 53 - "branch_bar_chart.dart"
Cohesion: 0.11
Nodes (17): _branchGradients, build, _chartMaxY, _computeChartMaxY, createState, currencyFormat, didUpdateWidget, _formatCompactCurrency (+9 more)

### Community 54 - "Tasklist Refactoring: Dekomposisi God Nodes & Bridges"
Cohesion: 0.50
Nodes (3): Daftar Tugas (Tasklist), Prinsip Kerja & Batasan Refactoring, Tasklist Refactoring: Dekomposisi God Nodes & Bridges

### Community 55 - "Testing and Mocking Dart Applications"
Cohesion: 0.22
Nodes (9): Contents, Testing and Mocking Dart Applications, Examples, Feedback Loop: Test Failures, Generating Mocks, Implementing Unit Tests, Managing Dependencies, Structuring Code for Testability (+1 more)

### Community 56 - "Implementing Dart and Flutter Test Coverage"
Cohesion: 0.15
Nodes (13): 1. Add Dependencies, 1. Run Tests with VM Service, 2. Collect Coverage and Generate LCOV, 2. Collect Raw Coverage, 3. Feedback Loop: Validate Output, 3. Format to LCOV, Contents, Coverage Directives (+5 more)

### Community 57 - "Implementing Flutter Integration Tests"
Cohesion: 0.17
Nodes (12): Contents, Implementing Flutter Integration Tests, Examples, Execution and Profiling, Interactive Exploration via MCP, Project Setup and Dependencies, Test Authoring Guidelines, Workflow: End-to-End Integration Testing (+4 more)

### Community 58 - "main_navigation_screen.dart"
Cohesion: 0.17
Nodes (10): build, _controller, _destinations, MainNavigationScreen, NavigationController get, package:dashboard/feature/home/controllers/navigation_controller.dart, package:dashboard/feature/home/presentation/home_screen.dart, package:dashboard/feature/home/presentation/main_navigation_screen.dart (+2 more)

### Community 59 - "Building Dart CLI Applications"
Cohesion: 0.20
Nodes (10): Argument Parsing & Command Routing, Compilation & Distribution, Contents, Building Dart CLI Applications, Example: CommandRunner Implementation, Examples, Execution & Error Handling, Project Setup & Architecture (+2 more)

### Community 60 - "static final"
Cohesion: 0.17
Nodes (12): Basic Preview, Contents, Creating a Widget Preview, Previewing Flutter Widgets, Examples, Handling Limitations, Interacting with Previews, MultiPreview Implementation (+4 more)

### Community 61 - "app_constants.dart"
Cohesion: 0.18
Nodes (10): aesKey, AppConstants, appTagline, baseUrlAndroidEmulator, baseUrlLocal, keyAuthToken, keyCustomBaseUrl, keyUserData (+2 more)

### Community 62 - "Implementing Adaptive Layouts"
Cohesion: 0.18
Nodes (11): Adaptive Layout using LayoutBuilder, Constraining Width on Large Screens, Contents, Device and Orientation Behaviors, Implementing Adaptive Layouts, Examples, Space Measurement Guidelines, Widget Sizing and Constraints (+3 more)

### Community 63 - "Testing Dart and Flutter Applications"
Cohesion: 0.20
Nodes (10): Contents, Testing Dart and Flutter Applications, Examples, Executing Tests, Mocking with Mockito, Standard Unit Test Suite, Structuring Test Files, Task Progress (+2 more)

### Community 64 - "dashboard_state_views.dart"
Cohesion: 0.18
Nodes (10): Color, build, _configButtonStyle, DashboardLoadingView, errorMessage, onRetry, _retryButtonStyle, package:dashboard/core/theme/app_theme.dart (+2 more)

### Community 65 - "string"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 66 - "kpi_summary_section.dart"
Cohesion: 0.18
Nodes (10): kpi_stat_card.dart, DashboardSummary, _averageTextStyle, build, currencyFormat, _headerTitleStyle, KpiSummarySection, _mainCardDecoration (+2 more)

### Community 67 - "url_security_validator.dart"
Cohesion: 0.18
Nodes (10): errorMessage, isLocalHost, isSecureHttps, isValid, localHosts, UrlSecurityValidationResult, UrlSecurityValidator, validate (+2 more)

### Community 68 - "Managing Dart Dependencies"
Cohesion: 0.20
Nodes (10): Contents, Core Concepts, Managing Dart Dependencies, Examples, Surgical Lockfile Removal, Tightening Constraints, Version Constraints, Workflow: Auditing Dependencies (+2 more)

### Community 69 - "Analyzing and Fixing Dart Code"
Cohesion: 0.14
Nodes (13): Analysis Configuration, Comprehensive `analysis_options.yaml`, Contents, Diagnostic Suppression, Analyzing and Fixing Dart Code, Examples, Inline Diagnostic Suppression, Workflow: Applying Automated Fixes (+5 more)

### Community 70 - "Implementing Flutter Networking"
Cohesion: 0.25
Nodes (8): Background Parsing, Configuration & Permissions, Contents, Implementing Flutter Networking, Examples, Request Execution & Response Handling, Workflow: Executing Network Operations, compute

### Community 71 - "quarterly_growth_calculator.dart"
Cohesion: 0.20
Nodes (9): baseRadiusMap, computeRadiiAndTotal, defaultTierRadii, fallbackRadius, QuarterlyGrowthCalculator, QuarterRadiusComputationResult, totalQuarters, Map (+1 more)

### Community 72 - "Tasklist Security Hardening: Paket 1 (Network & Platform Hardening)"
Cohesion: 0.50
Nodes (3): 1. Sasaran & Lingkup Perubahan, 2. Daftar Tugas (Tasklist), Tasklist Security Hardening: Paket 1 (Network & Platform Hardening)

### Community 74 - "Resolving Flutter Layout Errors"
Cohesion: 0.22
Nodes (9): Constraint Violation Diagnostics, Contents, Resolving Flutter Layout Errors, Examples, Fixing RenderFlex Overflow, Fixing Unbounded Width (TextField in Row), Layout Error Resolution Workflow, Task Progress (+1 more)

### Community 75 - "Spec: Pendapatan Perbandingan Kantor Cabang Berdasarkan Jenis Pinjaman"
Cohesion: 0.22
Nodes (9): bulanan, fetchDashboardData, dashboardData, RevenueScreen, 1. Overview, 2. Requirements & User Flow, 3. Architecture & Layering, 4. Quality Gate (+1 more)

### Community 76 - "ios/RunnerTests/RunnerTests.swift"
Cohesion: 0.29
Nodes (4): RunnerTests, RunnerTests, XCTest, XCTestCase

### Community 77 - "Login Screen Revamp Plan (Anti-AI Slop & High Performance)"
Cohesion: 0.29
Nodes (6): login, 1. Objectives, 2. Component Structure, 3. Design Engineering Spec, 4. Verification Plan, Login Screen Revamp Plan (Anti-AI Slop & High Performance)

### Community 78 - "package:dashboard/feature/home/model/interest_record.dart"
Cohesion: 0.25
Nodes (6): package:dashboard/feature/home/model/home_product_trend_helper.dart, package:dashboard/feature/home/model/interest_record.dart, package:dashboard/feature/revenue/controllers/branch_product_comparison_controller.dart, package:dashboard/feature/revenue/controllers/revenue_controller.dart, main, main

### Community 79 - "package:get/get.dart"
Cohesion: 0.18
Nodes (10): package:dashboard/core/security/url_security_validator.dart, package:dashboard/feature/auth/controllers/login_controller.dart, package:dashboard/feature/report/controllers/report_controller.dart, package:dashboard/feature/report/presentation/report_screen.dart, package:flutter_test/flutter_test.dart, package:get/get.dart, main, main (+2 more)

### Community 80 - "analytics_leaderboard_card.dart"
Cohesion: 0.29
Nodes (6): AnalyticsResult, analytics, build, _buildPodiumRow, currencyFormat, NumberFormat

### Community 81 - "AppDelegate"
Cohesion: 0.47
Nodes (4): FlutterAppDelegate, AppDelegate, Bool, NSApplication

### Community 82 - "Tasks"
Cohesion: 0.29
Nodes (6): Global Constraints, Task 1: Update `PortfolioDonutChart` Logic & UI, Task 2: Update Widget Tests, Task 3: Validation, Hot Reload, & Graphify Update, Tasks, Top 5 Portfolio Donut Chart Redesign Implementation Plan

### Community 83 - "graphify reference: extra exports and benchmark"
Cohesion: 0.40
Nodes (5): graphify reference: extra exports and benchmark, Step 6b - Wiki (only if --wiki flag), Step 7b - SVG export (only if --svg flag), Step 7d - MCP server (only if --mcp flag), token

### Community 84 - "ios/Runner/AppDelegate.swift"
Cohesion: 0.40
Nodes (3): FlutterSceneDelegate, SceneDelegate, UIKit

### Community 85 - "package:dashboard/feature/home/model/dashboard_data.dart"
Cohesion: 0.50
Nodes (3): package:dashboard/feature/home/controllers/home_controller.dart, package:dashboard/feature/home/model/dashboard_data.dart, main

### Community 89 - "profile_screen.dart"
Cohesion: 0.09
Nodes (20): build, _buildEmptyState, _buildInfoRow, _buildProfileContent, _buildScaffold, controller, ProfileScreen, userNotifier (+12 more)

### Community 145 - "static const List"
Cohesion: 0.33
Nodes (5): calculateActiveTrend, defaultMonthNames, HomeProductTrendHelper, ../model/dashboard_data.dart, static const List

### Community 151 - "Tasklist Refactoring & Improvement Fase 2"
Cohesion: 0.50
Nodes (3): Daftar Tugas (Tasklist), Prinsip & Standar Kualitas, Tasklist Refactoring & Improvement Fase 2

## Knowledge Gaps
- **990 isolated node(s):** `dependencies`, `AppConstants`, `appTagline`, `baseUrlLocal`, `baseUrlAndroidEmulator` (+985 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **49 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Migrating Dart Tests to Package Checks` connect `Migrating Dart Tests to Package Checks` to `description`, `string`, `static final`, `branch_product_comparison_helper.dart`?**
  _High betweenness centrality (0.066) - this node is a cross-community bridge._
- **Why does `description` connect `description` to `Migrating Dart Tests to Package Checks`, `Resolving Dart Static Analysis Errors`, `report_controller.dart`, `Compiling C Code into Code Assets with Native Assets Hooks`, `Internationalizing Flutter Applications`, `Dart Primary Constructors & New Constructor Syntax Skill`, `Generating FFI Bindings using package:ffigen`, `Flutter`, `product_breakdown_benchmark_test.dart`, `Implementing Dart Patterns`, `/graphify`, `Testing and Mocking Dart Applications`, `Implementing Dart and Flutter Test Coverage`, `Implementing Flutter Integration Tests`, `Building Dart CLI Applications`, `static final`, `Implementing Adaptive Layouts`, `Testing Dart and Flutter Applications`, `Managing Dart Dependencies`, `Analyzing and Fixing Dart Code`, `Resolving Flutter Layout Errors`?**
  _High betweenness centrality (0.050) - this node is a cross-community bridge._
- **Why does `Create` connect `Create` to `user_model.dart`, `report_controller.dart`, `Implementing Dart Patterns`, `description`, `Internationalizing Flutter Applications`, `/graphify`, `Testing and Mocking Dart Applications`, `Generating FFI Bindings using package:ffigen`, `Flutter`, `Implementing Flutter Integration Tests`, `Building Dart CLI Applications`, `static final`, `Testing Dart and Flutter Applications`?**
  _High betweenness centrality (0.041) - this node is a cross-community bridge._
- **What connects `dependencies`, `AppConstants`, `appTagline` to the rest of the system?**
  _990 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Create` be split into smaller, more focused modules?**
  _Cohesion score 0.07138047138047138 - nodes in this community are weakly interconnected._
- **Should `user_model.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `branch_product_comparison_card.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05714285714285714 - nodes in this community are weakly interconnected._