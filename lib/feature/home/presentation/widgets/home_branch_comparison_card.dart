import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard/feature/home/model/executive_analytics_helper.dart';
import 'package:dashboard/core/presentation/widgets/item_picker_bottom_sheet.dart';

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

  static const BoxDecoration _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(18)),
    border: Border.fromBorderSide(BorderSide(color: Color(0xFFE2E8F0))),
    boxShadow: [
      BoxShadow(color: Color(0x080F172A), blurRadius: 12, offset: Offset(0, 4)),
    ],
  );

  static const FlLine _touchIndicatorLine = FlLine(
    color: Color(0xFF94A3B8),
    strokeWidth: 1.5,
    dashArray: [4, 4],
  );

  static const FlLine _gridLine = FlLine(
    color: Color(0xFFF1F5F9),
    strokeWidth: 1,
  );

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
      ..sort(
        (a, b) =>
            ascending ? a.total.compareTo(b.total) : b.total.compareTo(a.total),
      );

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
        (m) => FlSpot(
          m.toDouble(),
          m < b.monthlyTrend.length ? b.monthlyTrend[m] : 0.0,
        ),
      );
      for (final val in b.monthlyTrend) {
        if (val > peakY) peakY = val;
      }
    }

    _cachedBenchmarkSpots = List<FlSpot>.generate(
      12,
      (m) => FlSpot(
        m.toDouble(),
        m < widget.bankAverageMonthlyTrend.length
            ? widget.bankAverageMonthlyTrend[m]
            : 0.0,
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
      builder: (context) => ItemPickerBottomSheet<ExecutiveBranchItem, int>(
        title: 'Pilih Cabang untuk Komparasi',
        unitLabel: 'kantor cabang',
        applySuffix: 'Terpilih',
        emptyMessage: 'Kantor cabang tidak ditemukan',
        searchHint: 'Cari kantor cabang...',
        limitExceededMessage: 'Maksimal memilih 5 cabang!',
        maxSelect: 5,
        activeColor: const Color(0xFF0F172A),
        items: widget.branches,
        initiallySelected: _selectedBranchIds,
        getId: (b) => b.idKantor,
        getLabel: (b) => b.label,
        getSubtitle: (b) => 'Kontribusi: ${b.percentage.toStringAsFixed(1)}%',
        matchesQuery: (b, q) =>
            b.label.toLowerCase().contains(q) ||
            b.idKantor.toString().contains(q),
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
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)} M';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(value >= 10000000 ? 0 : 1)} jt';
    }
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)} rb';
    return value.toStringAsFixed(0);
  }

  List<LineTooltipItem> _buildTooltipItems(List<LineBarSpot> touchedSpots) {
    return touchedSpots.map((spot) {
      final isBenchmark =
          _showBenchmark && spot.barIndex == _cachedActiveBranches.length;
      final branch =
          !isBenchmark && spot.barIndex < _cachedActiveBranches.length
          ? _cachedActiveBranches[spot.barIndex]
          : null;
      final title = isBenchmark
          ? 'Rata-rata Bank'
          : (branch?.label ?? 'Kantor');
      final color = isBenchmark
          ? _benchmarkColor
          : _palette[spot.barIndex % _palette.length];
      final monthName = _monthLabels[spot.x.toInt()];

      return LineTooltipItem(
        '$title ($monthName)\n',
        TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
        children: [
          TextSpan(
            text: widget.currencyFormat.format(spot.y),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
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

    final Color badgeBgColor = isDirectlyFocused
        ? color.withValues(alpha: 0.12)
        : (isDimmed ? const Color(0xFFF8FAFC) : color.withValues(alpha: 0.05));

    final Color badgeBorderColor = isDirectlyFocused
        ? color
        : (isDimmed ? const Color(0xFFE2E8F0) : color.withValues(alpha: 0.25));

    final Color labelColor = isDimmed ? const Color(0xFF94A3B8) : color;
    final Color valueColor = isDimmed
        ? const Color(0xFF94A3B8)
        : (isBenchmark ? const Color(0xFF475569) : const Color(0xFF0F172A));

    return InkWell(
      onTap: () =>
          setState(() => _focusedBranchId = isDirectlyFocused ? null : id),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: badgeBgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: badgeBorderColor,
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
                      color: labelColor,
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
                      color: labelColor,
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
                  color: valueColor,
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

  List<LineChartBarData> _buildLineBarsData() {
    return <LineChartBarData>[
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
          showingIndicators: _touchedIndex != null
              ? [_touchedIndex!]
              : const [],
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
          showingIndicators: _touchedIndex != null
              ? [_touchedIndex!]
              : const [],
          belowBarData: BarAreaData(show: false),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.branches.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: _cardDecoration,
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
                            color: const Color(0xFF2563EB)
                                .withValues(alpha: 0.1),
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
                            'Komparasi Total Cabang',
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _showBenchmark
                                ? const Color(0xFF64748B)
                                      .withValues(alpha: 0.12)
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
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
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
                                onTap: () => _applyPreset(
                                  BranchViewMode.top3,
                                  ascending: false,
                                ),
                              ),
                              const SizedBox(width: 6),
                              _buildModeTab(
                                label: '3 Terendah',
                                isActive: _viewMode == BranchViewMode.bottom3,
                                onTap: () => _applyPreset(
                                  BranchViewMode.bottom3,
                                  ascending: true,
                                ),
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
                            final lineBarsDataList = _buildLineBarsData();

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
                                      getTooltipColor: (_) =>
                                          const Color(0xFF0F172A),
                                      tooltipPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                      getTooltipItems: _buildTooltipItems,
                                    ),
                                    getTouchedSpotIndicator:
                                        (
                                          LineChartBarData barData,
                                          List<int> spotIndexes,
                                        ) {
                                          return spotIndexes.map((index) {
                                            return TouchedSpotIndicatorData(
                                              _touchIndicatorLine,
                                              FlDotData(
                                                show: true,
                                                getDotPainter:
                                                    (
                                                      spot,
                                                      percent,
                                                      barData,
                                                      index,
                                                    ) {
                                                      return FlDotCirclePainter(
                                                        radius: 4.5,
                                                        color: Colors.white,
                                                        strokeWidth: 2.5,
                                                        strokeColor:
                                                            barData.color ??
                                                            const Color(
                                                              0xFF2563EB,
                                                            ),
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
                                    getDrawingHorizontalLine: (_) => _gridLine,
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 42,
                                        interval: _cachedYInterval,
                                        getTitlesWidget: (value, meta) {
                                          if (value == meta.max ||
                                              value == meta.min) {
                                            return const SizedBox.shrink();
                                          }
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
                                          if (idx >= 0 &&
                                              idx < _monthLabels.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 6,
                                              ),
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
                                  showingTooltipIndicators:
                                      _touchedIndex != null &&
                                          _touchedIndex! >= 0 &&
                                          _touchedIndex! < 12
                                      ? [
                                          ShowingTooltipIndicators(
                                            List.generate(
                                              lineBarsDataList.length,
                                              (barIdx) {
                                                final bar =
                                                    lineBarsDataList[barIdx];
                                                final spot =
                                                    _touchedIndex! <
                                                        bar.spots.length
                                                    ? bar.spots[_touchedIndex!]
                                                    : FlSpot(
                                                        _touchedIndex!
                                                            .toDouble(),
                                                        0,
                                                      );
                                                return LineBarSpot(
                                                  bar,
                                                  barIdx,
                                                  spot,
                                                );
                                              },
                                            ),
                                          ),
                                        ]
                                      : const [],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 18),

                        // 3-Column Grid Legend Badges (High-performance Wrap without GridView/Sliver overhead)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final itemWidth = (constraints.maxWidth - 12) / 3;
                            return Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                ..._cachedActiveBranches.asMap().entries.map((
                                  entry,
                                ) {
                                  final idx = entry.key;
                                  final b = entry.value;
                                  return SizedBox(
                                    width: itemWidth,
                                    height: 52,
                                    child: _buildLegendBadge(
                                      id: b.idKantor,
                                      label: b.label,
                                      valueText: widget.currencyFormat.format(
                                        b.total,
                                      ),
                                      color: _palette[idx % _palette.length],
                                      subtitle:
                                          '${b.percentage.toStringAsFixed(1)}%',
                                    ),
                                  );
                                }),
                                if (_showBenchmark)
                                  SizedBox(
                                    width: itemWidth,
                                    height: 52,
                                    child: _buildLegendBadge(
                                      id: -1,
                                      label: 'Rata-rata Bank',
                                      valueText: widget.currencyFormat.format(
                                        widget.bankAverageTotal,
                                      ),
                                      color: _benchmarkColor,
                                      isBenchmark: true,
                                    ),
                                  ),
                              ],
                            );
                          },
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

