import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:dashboard/feature/home/model/dashboard_data.dart';
import 'package:dashboard/feature/home/services/dashboard_service.dart';
import 'widgets/dashboard_state_views.dart';
import 'widgets/kantor_filter_chips.dart';
import 'widgets/kpi_summary_section.dart';
import 'widgets/monthly_trend_chart.dart';
import 'widgets/product_breakdown_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardService _dashboardService = DashboardService();

  // Filter Cabang (0 = Semua Kantor, 1 = Kantor 1, dst)
  int _selectedKantor = 0;

  bool _isLoading = true;
  String? _errorMessage;
  DashboardData? _dashboardData;
  DateTime _lastFetched = DateTime.now();

  // Format Rupiah
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

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
      final data = await _dashboardService.fetchDashboardData(
        idKantor: _selectedKantor,
      );
      if (!mounted) return;
      setState(() {
        _dashboardData = data;
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
    final timeFormat = DateFormat('HH:mm:ss');

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
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Realtime Oracle DB (${timeFormat.format(_lastFetched)})',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Perbarui Data Oracle',
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
              // --- 1. FILTER KANTOR / CABANG ---
              KantorFilterChips(
                selectedKantor: _selectedKantor,
                onKantorChanged: (newKantor) {
                  setState(() {
                    _selectedKantor = newKantor;
                  });
                  _loadData();
                },
              ),
              const SizedBox(height: 16),

              // --- 2. KONTEN UTAMA (Loading, Error, atau Data Live) ---
              if (_isLoading)
                const DashboardLoadingView()
              else if (_errorMessage != null)
                DashboardErrorView(
                  errorMessage: _errorMessage,
                  onRetry: _loadData,
                )
              else if (_dashboardData != null)
                _buildDashboardContent(_dashboardData!)
              else
                const SizedBox.shrink(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(DashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- METRIC KPI CARDS ---
        KpiSummarySection(
          summary: data.summary,
          currencyFormat: _currencyFormat,
        ),
        const SizedBox(height: 20),

        // --- GRAFIK TREN BULANAN ---
        MonthlyTrendChart(
          trend: data.monthlyTrend,
          currencyFormat: _currencyFormat,
        ),
        const SizedBox(height: 20),

        // --- BREAKDOWN PRODUK PINJAMAN ---
        ProductBreakdownCard(
          breakdown: data.productBreakdown,
          grandTotal: data.summary.totalYTD,
          currencyFormat: _currencyFormat,
        ),
      ],
    );
  }
}
