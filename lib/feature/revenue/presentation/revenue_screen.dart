import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:dashboard/core/presentation/server_config_dialog.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';
import 'package:dashboard/feature/home/presentation/widgets/dashboard_state_views.dart';
import 'package:dashboard/feature/home/services/dashboard_service.dart';
import 'package:dashboard/feature/revenue/model/analytics_helper.dart';

import 'widgets/analytics_leaderboard_card.dart';
import 'widgets/branch_bar_chart.dart';
import 'widgets/portfolio_donut_chart.dart';
import 'widgets/quarterly_growth_chart.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  final DashboardService _dashboardService = DashboardService();

  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  bool _isLoading = true;
  String? _errorMessage;
  DashboardData? _dashboardData;
  AnalyticsResult? _analyticsResult;
  DateTime _lastFetched = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _dashboardService.fetchDashboardData(idKantor: 0);
      final analytics = AnalyticsHelper.computeAnalytics(data);

      if (!mounted) return;
      setState(() {
        _dashboardData = data;
        _analyticsResult = analytics;
        _isLoading = false;
        _lastFetched = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BPR SUPRA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Builder(
              builder: (context) {
                Color statusColor;
                String statusText;
                if (_isLoading) {
                  statusColor = const Color(0xFFEAB308);
                  statusText = 'Menyinkronkan';
                } else if (_errorMessage != null) {
                  statusColor = const Color(0xFFEF4444);
                  statusText = 'Gagal terhubung ke server';
                } else {
                  statusColor = const Color(0xFF22C55E);
                  statusText =
                      'Update data: ${_dateTimeFormat.format(_lastFetched)}';
                }

                return Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan Server',
            onPressed: () async {
              await ServerConfigDialog.show(context);
              _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Perbarui Data',
            onPressed: _loadData,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const DashboardLoadingView(
                  message: 'Memuat data analisis portofolio...',
                )
              else if (_errorMessage != null)
                DashboardErrorView(
                  errorMessage: _errorMessage,
                  onRetry: _loadData,
                )
              else if (_dashboardData != null && _analyticsResult != null)
                _buildAnalyticsContent(_dashboardData!, _analyticsResult!)
              else
                const SizedBox.shrink(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(DashboardData data, AnalyticsResult analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RepaintBoundary(
          child: AnalyticsLeaderboardCard(
            analytics: analytics,
            currencyFormat: _currencyFormat,
          ),
        ),
        const SizedBox(height: 20),

        // --- 3. PIE / DONUT CHART (Pangsa Pasar Produk) ---
        RepaintBoundary(
          child: PortfolioDonutChart(
            breakdown: data.productBreakdown,
            grandTotal: data.summary.totalYTD,
            currencyFormat: _currencyFormat,
          ),
        ),
        const SizedBox(height: 20),

        // --- 4. BAR CHART (Komparasi Kantor 1 vs 2 vs 3) ---
        RepaintBoundary(
          child: BranchBarChart(
            branches: analytics.branches,
            currencyFormat: _currencyFormat,
          ),
        ),
        const SizedBox(height: 20),

        // --- 5. BAR CHART (Pertumbuhan Kuartalan Q1 - Q4) ---
        RepaintBoundary(
          child: QuarterlyGrowthChart(
            quarters: analytics.quarters,
            currencyFormat: _currencyFormat,
          ),
        ),
      ],
    );
  }
}
