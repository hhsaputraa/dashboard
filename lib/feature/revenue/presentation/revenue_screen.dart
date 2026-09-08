import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:dashboard/core/presentation/server_config_dialog.dart';
import 'package:dashboard/core/presentation/widgets/sync_status_indicator.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';
import 'package:dashboard/feature/home/presentation/widgets/dashboard_state_views.dart';
import 'package:dashboard/feature/revenue/controllers/revenue_controller.dart';
import 'package:dashboard/feature/revenue/model/analytics_helper.dart';

import 'widgets/analytics_leaderboard_card.dart';
import 'widgets/branch_bar_chart.dart';
import 'widgets/branch_product_comparison_card.dart';
import 'widgets/portfolio_donut_chart.dart';
import 'widgets/quarterly_growth_chart.dart';

class RevenueScreen extends StatelessWidget {
  final bool isActive;

  const RevenueScreen({super.key, this.isActive = true});

  RevenueController get _controller =>
      Get.isRegistered<RevenueController>()
          ? Get.find<RevenueController>()
          : Get.put(RevenueController());

  Widget _buildStatusIndicator() {
    return Obx(
      () => SyncStatusIndicator(
        isLoading: _controller.isLoading.value,
        errorMessage: _controller.errorMessage.value,
        lastFetched: _controller.lastFetched.value,
        dateFormat: RevenueController.dateTimeFormat,
        syncingText: 'Menyinkronkan analitik...',
        errorText: 'Gagal terhubung ke server',
      ),
    );
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
            _buildStatusIndicator(),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan Server',
            onPressed: () async {
              await ServerConfigDialog.show(context);
              _controller.loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Perbarui Data',
            onPressed: _controller.loadData,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _controller.loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                if (_controller.isLoading.value) {
                  return const DashboardLoadingView(
                    message: 'Memuat data analisis portofolio...',
                  );
                } else if (_controller.errorMessage.value != null) {
                  return DashboardErrorView(
                    errorMessage: _controller.errorMessage.value,
                    onRetry: _controller.loadData,
                  );
                } else if (_controller.dashboardData.value != null &&
                    _controller.analyticsResult.value != null) {
                  return _buildAnalyticsContent(
                    _controller.dashboardData.value!,
                    _controller.analyticsResult.value!,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
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
            currencyFormat: RevenueController.currencyFormat,
          ),
        ),
        const SizedBox(height: 20),

        // --- 3. PIE / DONUT CHART (Pangsa Pasar Produk - Top 5) ---
        RepaintBoundary(
          child: PortfolioDonutChart(
            breakdown: analytics.safeTopProducts.isNotEmpty
                ? analytics.safeTopProducts
                : data.productBreakdown.take(5).toList(),
            allProducts: data.productBreakdown,
            grandTotal: data.summary.totalYTD,
            currencyFormat: RevenueController.currencyFormat,
          ),
        ),
        const SizedBox(height: 20),

        // --- 4. BAR CHART (Komparasi Top 3 Kantor Cabang) ---
        RepaintBoundary(
          child: BranchBarChart(
            branches: analytics.safeTopBranches,
            currencyFormat: RevenueController.currencyFormat,
          ),
        ),
        const SizedBox(height: 20),

        // --- 5. KOMPARASI CABANG BERDASARKAN JENIS PINJAMAN ---
        RepaintBoundary(
          child: BranchProductComparisonCard(
            records: data.records,
            currencyFormat: RevenueController.currencyFormat,
          ),
        ),
        const SizedBox(height: 20),

        // --- 6. BAR CHART (Pertumbuhan Kuartalan Q1 - Q4) ---
        RepaintBoundary(
          child: QuarterlyGrowthChart(
            quarters: analytics.quarters,
            currencyFormat: RevenueController.currencyFormat,
          ),
        ),
      ],
    );
  }
}
