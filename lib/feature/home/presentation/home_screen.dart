import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:dashboard/core/presentation/server_config_dialog.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';
import 'package:dashboard/feature/home/model/executive_analytics_helper.dart';
import 'package:dashboard/feature/home/services/dashboard_service.dart';

import 'widgets/dashboard_state_views.dart';
import 'widgets/hhi_concentration_card.dart';
import 'widgets/home_branch_comparison_card.dart';
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

  // Formatters statis (diinisialisasi 1 kali, hemat memori & CPU)
  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Ags',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const Color _statusLoadingColor = Color(0xFFEAB308);
  static const Color _statusErrorColor = Color(0xFFEF4444);
  static const Color _statusSuccessColor = Color(0xFF22C55E);

  // Filter Cabang (0 = Semua Kantor, 1 = Kantor 1, dst)
  int _selectedKantor = 0;

  // Filter Produk Terpilih (Cross-Filtering Power BI Style)
  String? _selectedProduct;

  // Cache data tren aktif (Memoized agar tidak dihitung ulang di setiap frame build)
  List<MonthlyTrendItem> _activeTrend = const [];

  bool _isLoading = true;
  String? _errorMessage;
  DashboardData? _dashboardData;
  ExecutiveAnalyticsResult? _executiveResult;
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
      _selectedProduct = null;
      _activeTrend = const [];
    });

    try {
      final data = await _dashboardService.fetchDashboardData(
        idKantor: _selectedKantor,
      );
      final execResult = ExecutiveAnalyticsHelper.compute(data);

      if (!mounted) return;
      setState(() {
        _dashboardData = data;
        _executiveResult = execResult;
        _isLoading = false;
        _lastFetched = DateTime.now();
        _recomputeActiveTrend();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _setSelectedProduct(String? product) {
    if (_selectedProduct == product) return;
    setState(() {
      _selectedProduct = product;
      _recomputeActiveTrend();
    });
  }

  /// Menghitung ulang cache tren bulanan saat data atau filter produk berubah
  void _recomputeActiveTrend() {
    if (_dashboardData == null) {
      _activeTrend = const [];
      return;
    }
    _activeTrend = _calculateActiveTrend(_dashboardData!);
  }

  /// Menghitung agregasi data tren bulanan sesuai filter produk aktif
  List<MonthlyTrendItem> _calculateActiveTrend(DashboardData data) {
    if (_selectedProduct == null) {
      return data.monthlyTrend;
    }

    final selectedLower = _selectedProduct!.trim().toLowerCase();

    // 1. Hitung agregasi data bulanan riil dari records Oracle DB (Akurat & Dinamis)
    if (data.records.isNotEmpty) {
      final monthlySums = List<double>.filled(12, 0.0);
      bool hasMatch = false;

      for (final r in data.records) {
        if (r.jenisPinjaman.trim().toLowerCase() == selectedLower) {
          hasMatch = true;
          for (int i = 0; i < 12 && i < r.bulanan.length; i++) {
            monthlySums[i] += r.bulanan[i];
          }
        }
      }

      if (hasMatch) {
        return List.generate(12, (i) {
          return MonthlyTrendItem(
            month: _monthNames[i],
            total: monthlySums[i],
          );
        });
      }
    }

    // 2. Jika ada monthly_trend di dalam product breakdown
    for (final p in data.productBreakdown) {
      if (p.name.trim().toLowerCase() == selectedLower) {
        if (p.monthlyTrend != null && p.monthlyTrend!.isNotEmpty) {
          return p.monthlyTrend!;
        }
        if (data.summary.totalYTD > 0) {
          final ratio = p.total / data.summary.totalYTD;
          return data.monthlyTrend
              .map((m) => MonthlyTrendItem(month: m.month, total: m.total * ratio))
              .toList();
        }
        break;
      }
    }

    return data.monthlyTrend;
  }

  Widget _buildStatusIndicator() {
    Color statusColor;
    String statusText;
    if (_isLoading) {
      statusColor = _statusLoadingColor;
      statusText = 'Menyinkronkan data...';
    } else if (_errorMessage != null) {
      statusColor = _statusErrorColor;
      statusText = 'Gagal terhubung ke server';
    } else {
      statusColor = _statusSuccessColor;
      statusText = 'Update data: ${_dateTimeFormat.format(_lastFetched)}';
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
              if (!mounted) return;
              _loadData();
            },
          ),
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
                  _selectedKantor = newKantor;
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
        // --- 1. METRIC KPI CARDS ---
        RepaintBoundary(
          child: KpiSummarySection(
            summary: data.summary,
            currencyFormat: _currencyFormat,
          ),
        ),
        const SizedBox(height: 20),

        // --- 2. HHI CONCENTRATION & DIVERSIFICATION RISK CARD ---
        if (_executiveResult != null) ...[
          RepaintBoundary(
            child: HhiConcentrationCard(
              hhi: _executiveResult!.hhi,
            ),
          ),
          const SizedBox(height: 20),
        ],

        // --- 3. KOMPARASI KANTOR CABANG (Tampil saat Semua Kantor Terpilih) ---
        if (_selectedKantor == 0 &&
            _executiveResult != null &&
            _executiveResult!.branches.isNotEmpty) ...[
          RepaintBoundary(
            child: HomeBranchComparisonCard(
              branches: _executiveResult!.branches,
              topBranch: _executiveResult!.topBranch,
              bankAverageMonthlyTrend:
                  _executiveResult!.bankAverageMonthlyTrend,
              bankAverageTotal: _executiveResult!.bankAverageTotal,
              currencyFormat: _currencyFormat,
            ),
          ),
          const SizedBox(height: 20),
        ],

        // --- 4. GRAFIK TREN BULANAN (Power BI Drilldown) ---
        RepaintBoundary(
          child: MonthlyTrendChart(
            trend: _activeTrend,
            currencyFormat: _currencyFormat,
            selectedProductName: _selectedProduct,
            onResetFilter: () => _setSelectedProduct(null),
          ),
        ),
        const SizedBox(height: 20),

        // --- 5. BREAKDOWN PRODUK PINJAMAN (Interactive Cross-Filtering) ---
        RepaintBoundary(
          child: ProductBreakdownCard(
            breakdown: data.productBreakdown,
            grandTotal: data.summary.totalYTD,
            currencyFormat: _currencyFormat,
            selectedProductName: _selectedProduct,
            onProductSelected: (selectedName) =>
                _setSelectedProduct(selectedName),
          ),
        ),
      ],
    );
  }
}
