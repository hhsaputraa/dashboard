import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:dashboard/core/presentation/server_config_dialog.dart';
import 'package:dashboard/feature/home/controllers/home_controller.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';

import 'widgets/dashboard_state_views.dart';
import 'widgets/hhi_concentration_card.dart';
import 'widgets/home_branch_comparison_card.dart';
import 'widgets/kantor_filter_chips.dart';
import 'widgets/kpi_summary_section.dart';
import 'widgets/monthly_trend_chart.dart';
import 'widgets/product_breakdown_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  HomeController get _controller =>
      Get.isRegistered<HomeController>() ? Get.find<HomeController>() : Get.put(HomeController());

  Widget _buildStatusIndicator() {
    return Obx(() {
      Color statusColor;
      String statusText;
      if (_controller.isLoading.value) {
        statusColor = HomeController.statusLoadingColor;
        statusText = 'Menyinkronkan data...';
      } else if (_controller.errorMessage.value != null) {
        statusColor = HomeController.statusErrorColor;
        statusText = 'Gagal terhubung ke server';
      } else {
        statusColor = HomeController.statusSuccessColor;
        statusText =
            'Update data: ${HomeController.dateTimeFormat.format(_controller.lastFetched.value)}';
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
    });
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
            tooltip: 'Perbarui Data Oracle',
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
              // --- 1. FILTER KANTOR / CABANG ---
              Obx(() => KantorFilterChips(
                    selectedKantor: _controller.selectedKantor.value,
                    offices: _controller.availableOffices.toList(),
                    onKantorChanged: _controller.changeKantor,
                  )),
              const SizedBox(height: 16),

              // --- 2. KONTEN UTAMA (Loading, Error, atau Data Live) ---
              Obx(() {
                if (_controller.isLoading.value) {
                  return const DashboardLoadingView();
                } else if (_controller.errorMessage.value != null) {
                  return DashboardErrorView(
                    errorMessage: _controller.errorMessage.value,
                    onRetry: _controller.loadData,
                  );
                } else if (_controller.dashboardData.value != null) {
                  return _buildDashboardContent(_controller.dashboardData.value!);
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

  Widget _buildDashboardContent(DashboardData data) {
    return Obx(() {
      final execResult = _controller.executiveResult.value;
      final selectedKantor = _controller.selectedKantor.value;
      final activeTrend = _controller.activeTrend.toList();
      final selectedProduct = _controller.selectedProduct.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. METRIC KPI CARDS ---
          RepaintBoundary(
            child: KpiSummarySection(
              summary: data.summary,
              currencyFormat: HomeController.currencyFormat,
            ),
          ),
          const SizedBox(height: 20),

          // --- 2. HHI CONCENTRATION & DIVERSIFICATION RISK CARD ---
          if (execResult != null) ...[
            RepaintBoundary(
              child: HhiConcentrationCard(
                hhi: execResult.hhi,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // --- 3. KOMPARASI KANTOR CABANG (Tampil saat Semua Kantor Terpilih) ---
          if (selectedKantor == 0 &&
              execResult != null &&
              execResult.branches.isNotEmpty) ...[
            RepaintBoundary(
              child: HomeBranchComparisonCard(
                branches: execResult.branches,
                topBranch: execResult.topBranch,
                bankAverageMonthlyTrend:
                    execResult.bankAverageMonthlyTrend,
                bankAverageTotal: execResult.bankAverageTotal,
                currencyFormat: HomeController.currencyFormat,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // --- 4. GRAFIK TREN BULANAN (Power BI Drilldown) ---
          RepaintBoundary(
            child: MonthlyTrendChart(
              trend: activeTrend,
              currencyFormat: HomeController.currencyFormat,
              selectedProductName: selectedProduct,
              onResetFilter: () => _controller.setSelectedProduct(null),
            ),
          ),
          const SizedBox(height: 20),

          // --- 5. BREAKDOWN PRODUK PINJAMAN (Interactive Cross-Filtering) ---
          RepaintBoundary(
            child: ProductBreakdownCard(
              breakdown: data.productBreakdown,
              grandTotal: data.summary.totalYTD,
              currencyFormat: HomeController.currencyFormat,
              selectedProductName: selectedProduct,
              onProductSelected: _controller.setSelectedProduct,
            ),
          ),
        ],
      );
    });
  }
}
