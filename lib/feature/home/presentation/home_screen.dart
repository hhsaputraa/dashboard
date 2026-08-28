import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:dashboard/core/presentation/server_config_dialog.dart';
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

  // Formatters statis (diinisialisasi 1 kali, hemat memori & CPU)
  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final _timeFormat = DateFormat('HH:mm:ss');

  // Filter Cabang (0 = Semua Kantor, 1 = Kantor 1, dst)
  int _selectedKantor = 0;

  // Filter Produk Terpilih (Cross-Filtering Power BI Style)
  String? _selectedProduct;

  // Cache data tren aktif (Memoized agar tidak dihitung ulang di setiap frame build)
  List<MonthlyTrendItem> _activeTrend = const [];

  bool _isLoading = true;
  String? _errorMessage;
  DashboardData? _dashboardData;
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
      if (!mounted) return;
      setState(() {
        _dashboardData = data;
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
      final matchingRecords = data.records.where((r) {
        return r.jenisPinjaman.trim().toLowerCase() == selectedLower;
      }).toList();

      if (matchingRecords.isNotEmpty) {
        const monthNames = [
          'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
          'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
        ];
        final monthlySums = List<double>.filled(12, 0.0);

        for (final r in matchingRecords) {
          for (int i = 0; i < 12 && i < r.bulanan.length; i++) {
            monthlySums[i] += r.bulanan[i];
          }
        }

        return List.generate(12, (i) {
          return MonthlyTrendItem(
            month: monthNames[i],
            total: monthlySums[i],
          );
        });
      }
    }

    // 2. Jika ada monthly_trend di dalam product breakdown
    final product = data.productBreakdown
        .where((p) => p.name.trim().toLowerCase() == selectedLower)
        .firstOrNull;

    if (product != null &&
        product.monthlyTrend != null &&
        product.monthlyTrend!.isNotEmpty) {
      return product.monthlyTrend!;
    }

    // 3. Fallback jika hanya ada total agregat
    if (product != null && data.summary.totalYTD > 0) {
      final ratio = product.total / data.summary.totalYTD;
      return data.monthlyTrend
          .map((m) => MonthlyTrendItem(month: m.month, total: m.total * ratio))
          .toList();
    }

    return data.monthlyTrend;
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
                  statusText = 'Menyinkronkan data...';
                } else if (_errorMessage != null) {
                  statusColor = const Color(0xFFEF4444);
                  statusText = 'Gagal terhubung ke server';
                } else {
                  statusColor = const Color(0xFF22C55E);
                  statusText =
                      'Update data pukul ${_timeFormat.format(_lastFetched)}';
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

        // --- GRAFIK TREN BULANAN (Power BI Drilldown) ---
        MonthlyTrendChart(
          trend: _activeTrend,
          currencyFormat: _currencyFormat,
          selectedProductName: _selectedProduct,
          onResetFilter: () => _setSelectedProduct(null),
        ),
        const SizedBox(height: 20),

        // --- BREAKDOWN PRODUK PINJAMAN (Interactive Cross-Filtering) ---
        ProductBreakdownCard(
          breakdown: data.productBreakdown,
          grandTotal: data.summary.totalYTD,
          currencyFormat: _currencyFormat,
          selectedProductName: _selectedProduct,
          onProductSelected: (selectedName) => _setSelectedProduct(selectedName),
        ),
      ],
    );
  }
}
