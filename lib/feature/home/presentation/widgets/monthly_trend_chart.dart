import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';

class MonthlyTrendChart extends StatelessWidget {
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
  Widget build(BuildContext context) {
    double maxY = 0;
    double totalBunga = 0;
    final spots = <FlSpot>[];
    for (int i = 0; i < trend.length; i++) {
      final val = trend[i].total;
      if (val > maxY) maxY = val;
      totalBunga += val;
      spots.add(FlSpot(i.toDouble(), val));
    }
    if (maxY == 0) maxY = 1000000;
    final chartMaxY = maxY / 0.93;
    final yInterval = (chartMaxY / 5).clamp(1.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
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
                    key: ValueKey<String>(selectedProductName ?? 'all'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedProductName != null
                            ? 'Tren: $selectedProductName'
                            : 'Tren Bunga Bulanan (Jan - Des)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (selectedProductName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Total Bunga: ${currencyFormat.format(totalBunga)}',
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
              if (selectedProductName != null)
                InkWell(
                  onTap: onResetFilter,
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
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
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
                          const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: currencyFormat.format(spot.y),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yInterval,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Color(0xFFF1F5F9),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
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
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
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
                        final index = value.toInt();
                        if (index >= 0 && index < trend.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              trend[index].month,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                              ),
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
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.25),
                          AppTheme.primaryColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
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
