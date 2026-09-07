import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';

class MonthlyTrendChart extends StatefulWidget {
  final List<MonthlyTrendItem> trend;
  final NumberFormat currencyFormat;
  final String? selectedProductName;
  final VoidCallback? onResetFilter;

  const MonthlyTrendChart({
    super.key,
    required this.trend,
    required this.currencyFormat,
    this.selectedProductName,
    this.onResetFilter,
  });

  @override
  State<MonthlyTrendChart> createState() => _MonthlyTrendChartState();
}

class _MonthlyTrendChartState extends State<MonthlyTrendChart> {
  List<FlSpot> _cachedSpots = const [];
  double _cachedChartMaxY = 1000000;
  double _cachedYInterval = 200000;
  double _cachedTotalBunga = 0;
  int? _touchedIndex;

  static const BoxDecoration _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.fromBorderSide(BorderSide(color: Color(0xFFE2E8F0))),
  );

  static const LinearGradient _belowBarGradient = LinearGradient(
    colors: [
      Color(0x40DC2626), // AppTheme.primaryColor with 25% alpha
      Color(0x00DC2626), // AppTheme.primaryColor with 0% alpha
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const FlLine _gridLine = FlLine(
    color: Color(0xFFF1F5F9),
    strokeWidth: 1,
    dashArray: [4, 4],
  );

  static const FlLine _touchIndicatorLine = FlLine(
    color: Color(0xFF94A3B8),
    strokeWidth: 1.5,
    dashArray: [4, 4],
  );

  static const TextStyle _tooltipMonthStyle = TextStyle(
    color: Color(0xFF94A3B8),
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle _tooltipValueStyle = TextStyle(
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle _yAxisTitleStyle = TextStyle(
    fontSize: 9,
    color: Color(0xFF94A3B8),
    fontWeight: FontWeight.w500,
  );

  static const TextStyle _xAxisTitleStyle = TextStyle(
    fontSize: 10,
    color: Color(0xFF64748B),
  );

  static String _formatCompactValue(double value) {
    if (value <= 0) return '0';
    if (value >= 1000000000) {
      final v = value / 1000000000;
      return '${v.toStringAsFixed(v >= 10 ? 0 : 1)} M';
    } else if (value >= 1000000) {
      final v = value / 1000000;
      return '${v.toStringAsFixed(v >= 10 ? 0 : 1)} jt';
    } else if (value >= 1000) {
      final v = value / 1000;
      return '${v.toStringAsFixed(v >= 10 ? 0 : 1)} rb';
    }
    return value.toStringAsFixed(0);
  }

  @override
  void initState() {
    super.initState();
    _recomputeSpots();
  }

  @override
  void didUpdateWidget(MonthlyTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trend != widget.trend) {
      _recomputeSpots();
    }
  }

  void _recomputeSpots() {
    double maxY = 0;
    double totalBunga = 0;
    final spots = <FlSpot>[];

    for (int i = 0; i < widget.trend.length; i++) {
      final val = widget.trend[i].total;
      if (val > maxY) maxY = val;
      totalBunga += val;
      spots.add(FlSpot(i.toDouble(), val));
    }

    if (maxY == 0) maxY = 1000000;
    _cachedChartMaxY = maxY / 0.93;
    _cachedYInterval = (_cachedChartMaxY / 5).clamp(1.0, double.infinity);
    _cachedTotalBunga = totalBunga;
    _cachedSpots = spots;
    _touchedIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    final trend = widget.trend;
    final chartMaxY = _cachedChartMaxY;
    final yInterval = _cachedYInterval;
    final totalBunga = _cachedTotalBunga;
    final spots = _cachedSpots;

    final lineBarData = LineChartBarData(
      spots: spots,
      isCurved: true,
      color: AppTheme.primaryColor,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      showingIndicators: _touchedIndex != null ? [_touchedIndex!] : const [],
      belowBarData: BarAreaData(show: true, gradient: _belowBarGradient),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.15),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    key: ValueKey<String>(widget.selectedProductName ?? 'all'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedProductName != null
                            ? 'Tren: ${widget.selectedProductName}'
                            : 'Tren Bulanan (Jan - Des)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.selectedProductName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Total: ${widget.currencyFormat.format(totalBunga)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (widget.selectedProductName != null)
                InkWell(
                  onTap: widget.onResetFilter,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Semua',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.show_chart_rounded,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
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
                    getTooltipColor: (touchedSpot) => const Color(0xFF0F172A),
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        final monthName = index >= 0 && index < trend.length
                            ? trend[index].month
                            : '';
                        return LineTooltipItem(
                          'Bulan $monthName\n',
                          _tooltipMonthStyle,
                          children: [
                            TextSpan(
                              text: widget.currencyFormat.format(spot.y),
                              style: _tooltipValueStyle,
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                  getTouchedSpotIndicator:
                      (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((index) {
                          return TouchedSpotIndicatorData(
                            _touchIndicatorLine,
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4.5,
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                  strokeColor:
                                      barData.color ?? AppTheme.primaryColor,
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
                  horizontalInterval: yInterval,
                  getDrawingHorizontalLine: (value) => _gridLine,
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      interval: yInterval,
                      getTitlesWidget: (value, meta) {
                        if (value < -0.01 || value > chartMaxY + 0.01) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            _formatCompactValue(value),
                            textAlign: TextAlign.right,
                            style: _yAxisTitleStyle,
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
                        final index = value.toInt();
                        if (index >= 0 && index < trend.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              trend[index].month,
                              style: _xAxisTitleStyle,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (trend.length - 1).toDouble().clamp(0, 11),
                minY: 0,
                maxY: chartMaxY,
                lineBarsData: [lineBarData],
                showingTooltipIndicators:
                    _touchedIndex != null &&
                        _touchedIndex! >= 0 &&
                        _touchedIndex! < spots.length
                    ? [
                        ShowingTooltipIndicators([
                          LineBarSpot(lineBarData, 0, spots[_touchedIndex!]),
                        ]),
                      ]
                    : const [],
              ),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOutCubic,
            ),
          ),
        ],
      ),
    );
  }
}
