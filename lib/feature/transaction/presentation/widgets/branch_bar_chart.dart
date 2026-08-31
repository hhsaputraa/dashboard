import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:dashboard/feature/transaction/model/analytics_helper.dart';

class BranchBarChart extends StatefulWidget {
  final List<BranchPerformance> branches;
  final NumberFormat currencyFormat;

  const BranchBarChart({
    super.key,
    required this.branches,
    required this.currencyFormat,
  });

  @override
  State<BranchBarChart> createState() => _BranchBarChartState();
}

class _BranchBarChartState extends State<BranchBarChart> {
  int _touchedIndex = -1;

  // Palet gradasi modern bergaya FinTech
  static const List<List<Color>> _branchGradients = [
    [Color(0xFFE11D48), Color(0xFFFB7185)], // Kantor 1 - Rose Crimson / Coral
    [Color(0xFF2563EB), Color(0xFF60A5FA)], // Kantor 2 - Electric Royal Blue
    [Color(0xFF059669), Color(0xFF34D399)], // Kantor 3 - Vibrant Emerald Jade
    [Color(0xFFD97706), Color(0xFFFBBF24)], // Kantor 4 (Fallback) - Amber Gold
    [
      Color(0xFF7C3AED),
      Color(0xFFA78BFA),
    ], // Kantor 5 (Fallback) - Modern Violet
  ];

  String _formatCompactCurrency(double value) {
    if (value >= 1000000000) {
      final v = value / 1000000000;
      return '${v.toStringAsFixed(v % 1 == 0 ? 0 : 1)} M';
    } else if (value >= 1000000) {
      final v = value / 1000000;
      return '${v.toStringAsFixed(v % 1 == 0 ? 0 : 1)} jt';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)} rb';
    } else if (value == 0) {
      return '0';
    }
    return value.toStringAsFixed(0);
  }

  late double _chartMaxY;

  @override
  void initState() {
    super.initState();
    _computeChartMaxY();
  }

  @override
  void didUpdateWidget(BranchBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.branches != widget.branches) {
      _computeChartMaxY();
    }
  }

  void _computeChartMaxY() {
    double maxY = 0.0;
    for (final b in widget.branches) {
      if (b.total > maxY) maxY = b.total;
    }
    _chartMaxY = maxY > 0 ? maxY * 1.2 : 1200000;
  }

  static FlLine _getGridHorizontalLine(double value) =>
      const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1);

  @override
  Widget build(BuildContext context) {
    final list = widget.branches;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kartu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Performa Kantor Cabang',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Perbandingan total pendapatan kantor cabang',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 26),

          // Bar Chart Modern
          SizedBox(
            height: 210,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _chartMaxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => const Color(0xFF0F172A),
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = list[group.x.toInt()];
                      return BarTooltipItem(
                        '${item.label}\n',
                        const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: widget.currencyFormat.format(rod.toY),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' (${item.percentage.toStringAsFixed(1)}%)',
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    final newIndex = (!event.isInterestedForInteractions ||
                            response == null ||
                            response.spot == null)
                        ? -1
                        : response.spot!.touchedBarGroupIndex;

                    if (_touchedIndex != newIndex) {
                      setState(() {
                        _touchedIndex = newIndex;
                      });
                    }
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.max || value == meta.min) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          space: 6,
                          child: Text(
                            _formatCompactCurrency(value),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < list.length) {
                          final isSelected = idx == _touchedIndex;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              list[idx].label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: _getGridHorizontalLine,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(list.length, (i) {
                  final item = list[i];
                  final isTouched = i == _touchedIndex;
                  final gradientColors =
                      _branchGradients[i % _branchGradients.length];

                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: item.total,
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: isTouched ? 34 : 28,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: _chartMaxY,
                          color: const Color(0xFFF8FAFC),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Cards Mini Komparasi Modern
          Row(
            children: list.asMap().entries.map((entry) {
              final idx = entry.key;
              final b = entry.value;
              final colors = _branchGradients[idx % _branchGradients.length];
              final isHighlighted = _touchedIndex == idx;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    final next = _touchedIndex == idx ? -1 : idx;
                    if (_touchedIndex != next) {
                      setState(() {
                        _touchedIndex = next;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                      right: idx < list.length - 1 ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? colors.first.withValues(alpha: 0.08)
                          : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isHighlighted
                            ? colors.first.withValues(alpha: 0.4)
                            : const Color(0xFFF1F5F9),
                        width: isHighlighted ? 1.2 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colors.first,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                b.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.currencyFormat.format(b.total),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: colors.first.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '${b.percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: colors.first,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
