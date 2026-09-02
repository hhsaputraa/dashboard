# Graph Report - D:/app/ai/dashboard  (2026-09-02)

## Corpus Check
- 108 files · ~53,920 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 740 nodes · 960 edges · 46 communities (39 shown, 7 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 23 edges (avg confidence: 0.82)
- Token cost: 1,250 input · 420 output

## Community Hubs (Navigation)
- Windows Native Runner & C++ Plugins
- Office & Branch Filter UI
- Branch Comparison & Benchmarking
- macOS/iOS Runner & Secure Storage
- Snapshot Data & Financial Aggregations
- Dashboard Data Models & Serialization
- Executive Analytics & Helper Logic
- Home Screen & Status Presentation
- Monthly Trend Chart Visualization
- Linux Desktop Runner & GTK
- Feature Module Imports & Contracts
- Login Screen Form & Presentation
- Auth Service & Session Management
- Transaction & Analytics Presentation
- Authentication Result & Status Models
- Quarterly Growth Chart Component
- Server Configuration Dialog & Endpoints
- Core Network Client & Interceptors
- Dashboard Service & API Integration
- Branch Bar Chart Visualization
- Dashboard Loading & Error Views
- Windows Application Entrypoint
- Core Constants & Global Settings
- Portfolio Donut Chart Component
- Dashboard & Profile Screens
- Web Manifest & PWA Configuration
- KPI Stat Cards & Summary Section
- Presentation Widgets & UI Components
- AES Security & Encryption Utilities
- Analytics Leaderboard & Podium UI
- App Root & Entrypoint Architecture
- Modal Sheets & Interactive Dialogs
- Theme Tokens & Styling System
- Login Revamp & Performance Architecture
- Developer Guidelines & Architectural Specs
- Android MainActivity & Native Integration
- Calculated Metric Getters
- Nullable Flag Types
- Nullable String Identifiers
- Dashboard Screen Package Import
- Non-Functional & Quality Standards
- Project Overview & Readme

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
- `Anti-AI Slop & High Performance UI Design` --rationale_for--> `LoginScreen`  [INFERRED]
  plans/login_revamp.md → lib/feature/auth/presentation/login_screen.dart
- `Login Screen Revamp Specification` --references--> `LoginScreen`  [EXTRACTED]
  plans/login_revamp.md → lib/feature/auth/presentation/login_screen.dart
- `Architectural Layers Specification` --conceptually_related_to--> `AuthService`  [INFERRED]
  plans/architecture.md → lib/feature/auth/services/auth_service.dart
- `Dashboard Core Functional Requirements` --references--> `login`  [INFERRED]
  plans/requirements.md → lib/feature/auth/services/auth_service.dart
- `Layer Contracts & Dependency Rules` --semantically_similar_to--> `Flutter AI Architectural Guidelines (GEMINI.md)`  [INFERRED] [semantically similar]
  plans/architecture.md → GEMINI.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Spec-Driven Architecture & Quality Enforcement** — plans_architecture_architectural_layers, gemini_architectural_guidelines, agents_developer_standards [INFERRED 0.95]

## Communities (46 total, 7 thin omitted)

### Community 0 - "Windows Native Runner & C++ Plugins"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 1 - "Office & Branch Filter UI"
Cohesion: 0.04
Nodes (45): IconData, build, defaultOffices, id, label, OfficeOption, onKantorChanged, selectedKantor (+37 more)

### Community 2 - "Branch Comparison & Benchmarking"
Cohesion: 0.05
Nodes (42): _applyPreset, bankAverageMonthlyTrend, bankAverageTotal, _benchmarkColor, branches, BranchViewMode, build, _buildLegendBadge (+34 more)

### Community 3 - "macOS/iOS Runner & Secure Storage"
Cohesion: 0.06
Nodes (28): Any, Cocoa, Flutter, flutter_secure_storage_macos, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS (+20 more)

### Community 4 - "Snapshot Data & Financial Aggregations"
Cohesion: 0.05
Nodes (37): DateTime, availableSnapshots, calculateGrandTotal, calculateMonthlyTotals, calculateProductTotals, date, DummySnapshotRepository, id (+29 more)

### Community 5 - "Dashboard Data Models & Serialization"
Cohesion: 0.06
Nodes (33): interest_record.dart, DashboardData, DashboardSummary, fromJson, month, monthlyAverage, monthlyTrend, MonthlyTrendItem (+25 more)

### Community 6 - "Executive Analytics & Helper Logic"
Cohesion: 0.06
Nodes (33): bankAverageMonthlyTrend, bankAverageTotal, branches, compute, description, dominantPercentage, dominantProduct, ExecutiveAnalyticsHelper (+25 more)

### Community 7 - "Home Screen & Status Presentation"
Cohesion: 0.06
Nodes (33): _activeTrend, build, _buildDashboardContent, _buildStatusIndicator, _calculateActiveTrend, createState, _currencyFormat, _dashboardData (+25 more)

### Community 8 - "Monthly Trend Chart Visualization"
Cohesion: 0.07
Nodes (29): int?, _belowBarGradient, build, _cachedChartMaxY, _cachedSpots, _cachedTotalBunga, _cachedYInterval, _cardDecoration (+21 more)

### Community 9 - "Linux Desktop Runner & GTK"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 10 - "Feature Module Imports & Contracts"
Cohesion: 0.08
Nodes (20): package:dashboard/feature/auth/models/auth_result.dart, package:dashboard/feature/auth/models/user_model.dart, package:dashboard/feature/auth/presentation/login_screen.dart, package:dashboard/feature/home/model/executive_analytics_helper.dart, package:dashboard/feature/home/presentation/widgets/dashboard_state_views.dart, package:dashboard/feature/home/presentation/widgets/hhi_concentration_card.dart, package:dashboard/feature/home/presentation/widgets/home_branch_comparison_card.dart, package:dashboard/feature/home/presentation/widgets/kantor_filter_chips.dart (+12 more)

### Community 11 - "Login Screen Form & Presentation"
Cohesion: 0.09
Nodes (22): FormState, _authService, build, _buildInputDecoration, createState, _defaultBorder, dispose, _enabledBorder (+14 more)

### Community 12 - "Auth Service & Session Management"
Cohesion: 0.09
Nodes (21): bool get, FlutterSecureStorage, _apiClient, currentToken, currentUser, fetchProfile, initSession, _instance (+13 more)

### Community 13 - "Transaction & Analytics Presentation"
Cohesion: 0.10
Nodes (21): _analyticsResult, build, _buildAnalyticsContent, createState, _currencyFormat, _dashboardData, _dashboardService, _errorMessage (+13 more)

### Community 14 - "Authentication Result & Status Models"
Cohesion: 0.10
Nodes (18): AuthResult, failure, isSuccess, message, success, user, email, fromJson (+10 more)

### Community 15 - "Quarterly Growth Chart Component"
Cohesion: 0.12
Nodes (17): _baseRadiusMap, build, _buildQuarterCard, _buildSections, _chartColors, _computeRadiiAndTotal, createState, currencyFormat (+9 more)

### Community 16 - "Server Configuration Dialog & Endpoints"
Cohesion: 0.12
Nodes (16): _apiClient, build, createState, dispose, initState, _isTesting, _resetUrl, _saveUrl (+8 more)

### Community 17 - "Core Network Client & Interceptors"
Cohesion: 0.12
Nodes (15): Client, baseUrlNotifier, checkHealth, _cleanUrl, _customBaseUrl, _httpClient, init, _instance (+7 more)

### Community 18 - "Dashboard Service & API Integration"
Cohesion: 0.13
Nodes (14): dart:async, dart:convert, dart:io, ApiClient, AuthService, _apiClient, _authService, DashboardService (+6 more)

### Community 19 - "Branch Bar Chart Visualization"
Cohesion: 0.14
Nodes (14): BranchBarChart, _BranchBarChartState, branches, _branchGradients, build, _chartMaxY, _computeChartMaxY, createState (+6 more)

### Community 20 - "Dashboard Loading & Error Views"
Cohesion: 0.17
Nodes (11): Color, build, _configButtonStyle, DashboardLoadingView, errorMessage, message, onRetry, _retryButtonStyle (+3 more)

### Community 21 - "Windows Application Entrypoint"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 22 - "Core Constants & Global Settings"
Cohesion: 0.17
Nodes (11): aesKey, AppConstants, appName, appTagline, baseUrlAndroidEmulator, baseUrlLocal, keyAuthToken, keyCustomBaseUrl (+3 more)

### Community 23 - "Portfolio Donut Chart Component"
Cohesion: 0.18
Nodes (11): breakdown, build, _chartColors, createState, currencyFormat, grandTotal, PortfolioDonutChart, _PortfolioDonutChartState (+3 more)

### Community 24 - "Dashboard & Profile Screens"
Cohesion: 0.18
Nodes (8): build, DashboardScreen, build, ProfileScreen, build, ReportScreen, package:dashboard/core/theme/app_theme.dart, package:flutter/material.dart

### Community 25 - "Web Manifest & PWA Configuration"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 26 - "KPI Stat Cards & Summary Section"
Cohesion: 0.20
Nodes (9): kpi_stat_card.dart, _averageTextStyle, build, currencyFormat, _headerTitleStyle, _mainCardDecoration, summary, _totalAmountStyle (+1 more)

### Community 27 - "Presentation Widgets & UI Components"
Cohesion: 0.20
Nodes (10): _LoginBackground, _LoginFooter, _LoginHeader, DashboardErrorView, KantorFilterChips, KpiStatCard, KpiSummarySection, ProductBreakdownCard (+2 more)

### Community 28 - "AES Security & Encryption Utilities"
Cohesion: 0.22
Nodes (8): ../constants/app_constants.dart, dart:math, dart:typed_data, AesEncryption, decrypt, encrypt, package:convert/convert.dart, package:encrypt/encrypt.dart

### Community 29 - "Analytics Leaderboard & Podium UI"
Cohesion: 0.22
Nodes (8): AnalyticsResult, analytics, AnalyticsLeaderboardCard, build, _buildPodiumRow, currencyFormat, NumberFormat, package:dashboard/feature/transaction/model/analytics_helper.dart

### Community 30 - "App Root & Entrypoint Architecture"
Cohesion: 0.25
Nodes (7): core/constants/app_constants.dart, core/network/api_client.dart, core/theme/app_theme.dart, feature/auth/presentation/login_screen.dart, BankDashboardApp, build, main

### Community 31 - "Modal Sheets & Interactive Dialogs"
Cohesion: 0.32
Nodes (8): ServerConfigDialog, _ServerConfigDialogState, _BranchPickerBottomSheet, _BranchPickerBottomSheetState, HomeBranchComparisonCard, _HomeBranchComparisonCardState, State, StatefulWidget

### Community 32 - "Theme Tokens & Styling System"
Cohesion: 0.25
Nodes (7): accentColor, AppTheme, backgroundColor, primaryColor, secondaryColor, surfaceColor, static const Color

### Community 33 - "Login Revamp & Performance Architecture"
Cohesion: 0.50
Nodes (4): LoginScreen, _LoginScreenState, Anti-AI Slop & High Performance UI Design, Login Screen Revamp Specification

### Community 34 - "Developer Guidelines & Architectural Specs"
Cohesion: 0.67
Nodes (3): Agent Developer Experience Standards (AGENTS.md), Flutter AI Architectural Guidelines (GEMINI.md), Layer Contracts & Dependency Rules

## Knowledge Gaps
- **399 isolated node(s):** `AppConstants`, `appName`, `appTagline`, `baseUrlLocal`, `baseUrlAndroidEmulator` (+394 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthService` connect `Dashboard Service & API Integration` to `Login Screen Form & Presentation`, `Auth Service & Session Management`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
- **Why does `ApiClient` connect `Dashboard Service & API Integration` to `Server Configuration Dialog & Endpoints`, `Core Network Client & Interceptors`, `Auth Service & Session Management`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **What connects `AppConstants`, `appName`, `appTagline` to the rest of the system?**
  _399 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Windows Native Runner & C++ Plugins` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `Office & Branch Filter UI` be split into smaller, more focused modules?**
  _Cohesion score 0.044326241134751775 - nodes in this community are weakly interconnected._
- **Should `Branch Comparison & Benchmarking` be split into smaller, more focused modules?**
  _Cohesion score 0.046511627906976744 - nodes in this community are weakly interconnected._
- **Should `macOS/iOS Runner & Secure Storage` be split into smaller, more focused modules?**
  _Cohesion score 0.05807200929152149 - nodes in this community are weakly interconnected._