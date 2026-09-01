import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard/feature/home/model/executive_analytics_helper.dart';

enum BranchViewMode { top3, bottom3, custom }

class HomeBranchComparisonCard extends StatefulWidget {
  final List<ExecutiveBranchItem> branches;
  final ExecutiveBranchItem? topBranch;
  final List<double> bankAverageMonthlyTrend;
  final double bankAverageTotal;
  final NumberFormat currencyFormat;
  final bool initiallyExpanded;

  const HomeBranchComparisonCard({
    super.key,
    required this.branches,
    required this.topBranch,
    required this.bankAverageMonthlyTrend,
    required this.bankAverageTotal,
    required this.currencyFormat,
    this.initiallyExpanded = true,
  });

  @override
  State<HomeBranchComparisonCard> createState() =>
      _HomeBranchComparisonCardState();
}

class _HomeBranchComparisonCardState extends State<HomeBranchComparisonCard> {
  late bool _isExpanded;
  BranchViewMode _viewMode = BranchViewMode.top3;
  final Set<int> _selectedBranchIds = {};
  int? _focusedBranchId; // null = all normal, idKantor = branch focus, -1 = benchmark focus
  bool _showBenchmark = true;
  int? _touchedIndex;

  // Memoized cache fields (O(1) build execution without per-frame allocations)
  List<ExecutiveBranchItem> _cachedActiveBranches = const [];
  double _cachedChartMaxY = 1000000;
  double _cachedYInterval = 200000;
  final Map<int, List<FlSpot>> _cachedBranchSpots = {};
  List<FlSpot> _cachedBenchmarkSpots = const [];

  static const List<Color> _palette = [
    Color(0xFFE11D48), // Rose Crimson
    Color(0xFF2563EB), // Royal Blue
    Color(0xFF059669), // Emerald Jade
    Color(0xFFD97706), // Amber Gold
    Color(0xFF7C3AED), // Modern Violet
  ];

  static const Color _benchmarkColor = Color(0xFF64748B);

  static const List<String> _monthLabels = [
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

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _initDefaultSelection();
  }

  @override
  void didUpdateWidget(HomeBranchComparisonCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.branches != widget.branches ||
        oldWidget.bankAverageMonthlyTrend != widget.bankAverageMonthlyTrend) {
      _initDefaultSelection();
    }
  }

  void _initDefaultSelection() {
    _applyPreset(BranchViewMode.top3, ascending: false);
  }

  void _applyPreset(BranchViewMode mode, {required bool ascending}) {
    final sorted = List<ExecutiveBranchItem>.from(widget.branches)
      ..sort((a, b) =>
          ascending ? a.total.compareTo(b.total) : b.total.compareTo(a.total));

    setState(() {
      _viewMode = mode;
      _focusedBranchId = null;
      _selectedBranchIds
        ..clear()
        ..addAll(sorted.take(3).map((b) => b.idKantor));
      _recomputeChartState();
    });
  }

  void _recomputeChartState() {
    _cachedActiveBranches = widget.branches
        .where((b) => _selectedBranchIds.contains(b.idKantor))
        .take(5)
        .toList();

    _cachedBranchSpots.clear();
    double peakY = 0.0;

    for (final b in _cachedActiveBranches) {
      _cachedBranchSpots[b.idKantor] = List<FlSpot>.generate(
        12,
        (m) => FlSpot(m.toDouble(), m < b.monthlyTrend.length ? b.monthlyTrend[m] : 0.0),
      );
      for (final val in b.monthlyTrend) {
        if (val > peakY) peakY = val;
      }
    }

    _cachedBenchmarkSpots = List<FlSpot>.generate(
      12,
      (m) => FlSpot(
        m.toDouble(),
        m < widget.bankAverageMonthlyTrend.length ? widget.bankAverageMonthlyTrend[m] : 0.0,
      ),
    );

    if (_showBenchmark) {
      for (final val in widget.bankAverageMonthlyTrend) {
        if (val > peakY) peakY = val;
      }
    }

    if (peakY <= 0) peakY = 1000000;
    _cachedChartMaxY = peakY * 1.28;
    _cachedYInterval = (_cachedChartMaxY / 5).clamp(1.0, double.infinity);
    _touchedIndex = null;
  }

  void _openBranchPickerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BranchPickerBottomSheet(
        branches: widget.branches,
        initiallySelectedIds: _selectedBranchIds,
        onApply: (newSelection) {
          setState(() {
            _viewMode = BranchViewMode.custom;
            _focusedBranchId = null;
            _selectedBranchIds
              ..clear()
              ..addAll(newSelection);
            _recomputeChartState();
          });
        },
      ),
    );
  }

  static String _formatCompact(double value) {
    if (value <= 0) return '0';
    if (value >= 1000000000) return '${(value / 1000000000).toStringAsFixed(1)} M';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(value >= 10000000 ? 0 : 1)} jt';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)} rb';
    return value.toStringAsFixed(0);
  }

  List<LineTooltipItem> _buildTooltipItems(List<LineBarSpot> touchedSpots) {
    return touchedSpots.map((spot) {
      final isBenchmark = _showBenchmark && spot.barIndex == _cachedActiveBranches.length;
      final branch = !isBenchmark && spot.barIndex < _cachedActiveBranches.length
          ? _cachedActiveBranches[spot.barIndex]
          : null;
      final title = isBenchmark ? 'Rata-rata Bank' : (branch?.label ?? 'Kantor');
      final color = isBenchmark ? _benchmarkColor : _palette[spot.barIndex % _palette.length];
      final monthName = _monthLabels[spot.x.toInt()];

      return LineTooltipItem(
        '$title ($monthName)\n',
        TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
        children: [
          TextSpan(
            text: widget.currencyFormat.format(spot.y),
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildLegendBadge({
    required int id,
    required String label,
    required String valueText,
    required Color color,
    String? subtitle,
    bool isBenchmark = false,
  }) {
    final isDirectlyFocused = _focusedBranchId == id;
    final isDimmed = _focusedBranchId != null && !isDirectlyFocused;

    return InkWell(
      onTap: () => setState(() => _focusedBranchId = isDirectlyFocused ? null : id),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isDirectlyFocused
              ? color.withValues(alpha: 0.12)
              : (isDimmed ? const Color(0xFFF8FAFC) : color.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDirectlyFocused
                ? color
                : (isDimmed ? const Color(0xFFE2E8F0) : color.withValues(alpha: 0.25)),
            width: isDirectlyFocused ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                if (isBenchmark)
                  Icon(Icons.horizontal_rule_rounded, size: 12, color: color)
                else
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isDimmed ? color.withValues(alpha: 0.4) : color,
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: isBenchmark ? 9.5 : 10,
                      fontWeight: FontWeight.bold,
                      color: isDimmed ? const Color(0xFF94A3B8) : color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isDimmed ? const Color(0xFF94A3B8) : color,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valueText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDimmed
                      ? const Color(0xFF94A3B8)
                      : (isBenchmark ? const Color(0xFF475569) : const Color(0xFF0F172A)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.branches.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Accordion Trigger)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.insights_rounded,
                            size: 16,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Komparasi Tren Cabang',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Benchmark Toggle Button
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showBenchmark = !_showBenchmark;
                            _recomputeChartState();
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _showBenchmark
                                ? const Color(0xFF64748B).withValues(alpha: 0.12)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _showBenchmark
                                    ? Icons.check_box_outlined
                                    : Icons.check_box_outline_blank,
                                size: 12,
                                color: const Color(0xFF475569),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Benchmark Rata-rata',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 150),
                        turns: _isExpanded ? 0.5 : 0.0,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Body Content (Collapsible Accordion - Snappy & High Performance)
          AnimatedSize(
            duration: const Duration(milliseconds: 160),
            curve: Curves.fastOutSlowIn,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 12),
                        Text(
                          'Komparasi multi-garis performa 12 bulan (Total ${widget.branches.length} Kantor Cabang)',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 14),

                        // Toolbar Modes
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildModeTab(
                                label: 'Top 3',
                                isActive: _viewMode == BranchViewMode.top3,
                                onTap: () => _applyPreset(BranchViewMode.top3, ascending: false),
                              ),
                              const SizedBox(width: 6),
                              _buildModeTab(
                                label: '3 Terendah',
                                isActive: _viewMode == BranchViewMode.bottom3,
                                onTap: () => _applyPreset(BranchViewMode.bottom3, ascending: true),
                              ),
                              const SizedBox(width: 6),
                              _buildModeTab(
                                label: _viewMode == BranchViewMode.custom
                                    ? 'Filter (${_selectedBranchIds.length})'
                                    : 'Pilih Cabang',
                                isActive: _viewMode == BranchViewMode.custom,
                                onTap: _openBranchPickerModal,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Multi-Line Chart Canvas
                        Builder(
                          builder: (context) {
                            final lineBarsDataList = <LineChartBarData>[
                              ..._cachedActiveBranches.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final b = entry.value;
                                final color = _palette[idx % _palette.length];
                                final isHighlighted =
                                    _focusedBranchId == null || _focusedBranchId == b.idKantor;

                                return LineChartBarData(
                                  spots: _cachedBranchSpots[b.idKantor] ?? const [],
                                  isCurved: true,
                                  curveSmoothness: 0.35,
                                  preventCurveOverShooting: true,
                                  color: isHighlighted ? color : color.withValues(alpha: 0.35),
                                  barWidth: 2.5,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: false),
                                  showingIndicators: _touchedIndex != null ? [_touchedIndex!] : const [],
                                  belowBarData: BarAreaData(show: false),
                                );
                              }),
                              if (_showBenchmark)
                                LineChartBarData(
                                  spots: _cachedBenchmarkSpots,
                                  isCurved: true,
                                  curveSmoothness: 0.35,
                                  dashArray: [6, 4],
                                  color: (_focusedBranchId == null || _focusedBranchId == -1)
                                      ? _benchmarkColor.withValues(alpha: 0.85)
                                      : _benchmarkColor.withValues(alpha: 0.35),
                                  barWidth: 2.5,
                                  dotData: const FlDotData(show: false),
                                  showingIndicators: _touchedIndex != null ? [_touchedIndex!] : const [],
                                  belowBarData: BarAreaData(show: false),
                                ),
                            ];

                            return SizedBox(
                              height: 220,
                              child: LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: 11,
                                  minY: 0,
                                  maxY: _cachedChartMaxY,
                                  lineTouchData: LineTouchData(
                                    enabled: true,
                                    handleBuiltInTouches: false,
                                    touchCallback: (event, response) {
                                      final spots = response?.lineBarSpots;
                                      if (!event.isInterestedForInteractions ||
                                          event is FlTapUpEvent ||
                                          event is FlPanEndEvent ||
                                          spots == null ||
                                          spots.isEmpty) {
                                        if (_touchedIndex != null) {
                                          setState(() => _touchedIndex = null);
                                        }
                                        return;
                                      }
                                      final idx = spots.first.spotIndex;
                                      if (_touchedIndex != idx) {
                                        setState(() => _touchedIndex = idx);
                                      }
                                    },
                                    touchTooltipData: LineTouchTooltipData(
                                      fitInsideHorizontally: true,
                                      fitInsideVertically: false,
                                      getTooltipColor: (_) => const Color(0xFF0F172A),
                                      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      getTooltipItems: _buildTooltipItems,
                                    ),
                                    getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                                      return spotIndexes.map((index) {
                                        return TouchedSpotIndicatorData(
                                          const FlLine(
                                            color: Color(0xFF94A3B8),
                                            strokeWidth: 1.5,
                                            dashArray: [4, 4],
                                          ),
                                          FlDotData(
                                            show: true,
                                            getDotPainter: (spot, percent, barData, index) {
                                              return FlDotCirclePainter(
                                                radius: 4.5,
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                                strokeColor: barData.color ?? const Color(0xFF2563EB),
                                              );
                                            },
                                          ),
                                        );
                                      }).toList();
                                    },
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: _cachedYInterval,
                                    getDrawingHorizontalLine: (_) =>
                                        const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 42,
                                        interval: _cachedYInterval,
                                        getTitlesWidget: (value, meta) {
                                          if (value == meta.max || value == meta.min) return const SizedBox.shrink();
                                          return SideTitleWidget(
                                            meta: meta,
                                            space: 4,
                                            child: Text(
                                              _formatCompact(value),
                                              style: const TextStyle(
                                                fontSize: 9,
                                                color: Color(0xFF94A3B8),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 24,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          final idx = value.toInt();
                                          if (idx >= 0 && idx < _monthLabels.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: Text(
                                                _monthLabels[idx],
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF64748B),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: lineBarsDataList,
                                  showingTooltipIndicators: _touchedIndex != null &&
                                          _touchedIndex! >= 0 &&
                                          _touchedIndex! < 12
                                      ? [
                                          ShowingTooltipIndicators(
                                            List.generate(lineBarsDataList.length, (barIdx) {
                                              final bar = lineBarsDataList[barIdx];
                                              final spot = _touchedIndex! < bar.spots.length
                                                  ? bar.spots[_touchedIndex!]
                                                  : FlSpot(_touchedIndex!.toDouble(), 0);
                                              return LineBarSpot(bar, barIdx, spot);
                                            }),
                                          ),
                                        ]
                                      : const [],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 18),

                        // 3-Column Grid Legend Badges
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          childAspectRatio: 1.9,
                          children: [
                            ..._cachedActiveBranches.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final b = entry.value;
                              return _buildLegendBadge(
                                id: b.idKantor,
                                label: b.label,
                                valueText: widget.currencyFormat.format(b.total),
                                color: _palette[idx % _palette.length],
                                subtitle: '${b.percentage.toStringAsFixed(1)}%',
                              );
                            }),
                            if (_showBenchmark)
                              _buildLegendBadge(
                                id: -1,
                                label: 'Rata-rata Bank',
                                valueText: widget.currencyFormat.format(widget.bankAverageTotal),
                                color: _benchmarkColor,
                                isBenchmark: true,
                              ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _BranchPickerBottomSheet extends StatefulWidget {
  final List<ExecutiveBranchItem> branches;
  final Set<int> initiallySelectedIds;
  final ValueChanged<Set<int>> onApply;

  const _BranchPickerBottomSheet({
    required this.branches,
    required this.initiallySelectedIds,
    required this.onApply,
  });

  @override
  State<_BranchPickerBottomSheet> createState() =>
      _BranchPickerBottomSheetState();
}

class _BranchPickerBottomSheetState extends State<_BranchPickerBottomSheet> {
  late final Set<int> _tempSelected;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempSelected = Set<int>.from(widget.initiallySelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = widget.branches.where((b) {
      if (query.isEmpty) return true;
      return b.label.toLowerCase().contains(query) ||
          b.idKantor.toString().contains(query);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pilih Cabang untuk Komparasi',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Text(
              'Maksimal 5 kantor cabang',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari kantor cabang...',
                prefixIcon: const Icon(Icons.search, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, idx) {
                  final b = filtered[idx];
                  final isChecked = _tempSelected.contains(b.idKantor);

                  return CheckboxListTile(
                    value: isChecked,
                    title: Text(
                      b.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Kontribusi: ${b.percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 11),
                    ),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          if (_tempSelected.length < 5) {
                            _tempSelected.add(b.idKantor);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Maksimal memilih 5 cabang!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } else if (_tempSelected.length > 1) {
                          _tempSelected.remove(b.idKantor);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  widget.onApply(_tempSelected);
                  Navigator.pop(context);
                },
                child: Text(
                  'Terapkan (${_tempSelected.length} Terpilih)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
