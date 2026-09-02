import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:dashboard/feature/revenue/model/analytics_helper.dart';

class QuarterlyGrowthChart extends StatefulWidget {
  final List<QuarterPerformance> quarters;
  final NumberFormat currencyFormat;

  const QuarterlyGrowthChart({
    super.key,
    required this.quarters,
    required this.currencyFormat,
  });

  @override
  State<QuarterlyGrowthChart> createState() => _QuarterlyGrowthChartState();
}

class _QuarterlyGrowthChartState extends State<QuarterlyGrowthChart> {
  int _touchedIndex = -1;

  // Warna persis seperti fl_chart sample 1
  static const List<Color> _chartColors = [
    Color(0xFF0293EE),
    Color(0xFFF8B250),
    Color(0xFF845BEF),
    Color(0xFF13D38E),
  ];

  static const List<double> _tierRadii = [92.0, 78.0, 66.0, 54.0];
  late Map<int, double> _baseRadiusMap;
  late double _totalQuarters;

  @override
  void initState() {
    super.initState();
    _computeRadiiAndTotal();
  }

  @override
  void didUpdateWidget(QuarterlyGrowthChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quarters != widget.quarters) {
      _computeRadiiAndTotal();
    }
  }

  void _computeRadiiAndTotal() {
    final list = widget.quarters;
    double total = 0.0;
    for (final q in list) {
      total += q.total;
    }
    _totalQuarters = total;

    final sortedIndices = List<int>.generate(list.length, (i) => i)
      ..sort((a, b) => list[b].total.compareTo(list[a].total));

    final radiusMap = <int, double>{};
    for (int rank = 0; rank < sortedIndices.length; rank++) {
      final itemIndex = sortedIndices[rank];
      radiusMap[itemIndex] = rank < _tierRadii.length ? _tierRadii[rank] : 54.0;
    }
    _baseRadiusMap = radiusMap;
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.quarters;

    if (list.isEmpty || _totalQuarters <= 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text(
            'Tidak ada data performa kuartalan',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
        ),
      );
    }

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
                'Performa per Kuartal',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              if (_touchedIndex != -1)
                InkWell(
                  onTap: () {
                    if (_touchedIndex != -1) {
                      setState(() => _touchedIndex = -1);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          size: 12,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0293EE).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pie_chart_rounded,
                    size: 16,
                    color: Color(0xFF0293EE),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Perbandingan pendapatan per Kuartal',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 24),

          // PieChart Sample 1 Style (startDegreeOffset: 180, sectionsSpace: 1, centerSpaceRadius: 0)
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, pieTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      return;
                    }
                    final targetIdx =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                    if (targetIdx >= 0 &&
                        targetIdx < list.length &&
                        _touchedIndex != targetIdx) {
                      setState(() {
                        _touchedIndex = targetIdx;
                      });
                    }
                  },
                ),
                startDegreeOffset: 180,
                borderData: FlBorderData(show: false),
                sectionsSpace: 1.5,
                centerSpaceRadius: 0,
                sections: _buildSections(list),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Cards Legend 4 Kuartal (Format 2x2 Grid)
          if (list.length >= 4) ...[
            Row(
              children: [
                Expanded(child: _buildQuarterCard(list[0], 0)),
                const SizedBox(width: 8),
                Expanded(child: _buildQuarterCard(list[1], 1)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildQuarterCard(list[2], 2)),
                const SizedBox(width: 8),
                Expanded(child: _buildQuarterCard(list[3], 3)),
              ],
            ),
          ] else ...[
            ...list.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _buildQuarterCard(entry.value, entry.key),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuarterCard(QuarterPerformance item, int idx) {
    final color = _chartColors[idx % _chartColors.length];
    final isHighlighted = _touchedIndex == idx;

    return Material(
      color: Colors.transparent,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isHighlighted
                ? color.withValues(alpha: 0.08)
                : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHighlighted
                  ? color.withValues(alpha: 0.4)
                  : const Color(0xFFF1F5F9),
              width: isHighlighted ? 1.2 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item.quarter,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.currencyFormat.format(item.total),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                item.monthsLabel,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(List<QuarterPerformance> list) {
    return List.generate(list.length, (i) {
      final isTouched = i == _touchedIndex;
      final item = list[i];
      final color = _chartColors[i % _chartColors.length];
      final baseRadius = _baseRadiusMap[i] ?? 70.0;
      final radius = isTouched ? baseRadius + 8.0 : baseRadius;

      return PieChartSectionData(
        color: color,
        value: 25, // 4 kuadran sama besar 25% (90 derajat)
        title: isTouched
            ? '${item.quarter}\n${item.percentage.toStringAsFixed(1)}%'
            : item.quarter,
        radius: radius,
        titlePositionPercentageOffset: 0.55,
        titleStyle: TextStyle(
          fontSize: isTouched ? 13 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.15,
          shadows: const [
            Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        borderSide: isTouched
            ? const BorderSide(color: Colors.white, width: 4)
            : BorderSide(color: Colors.white.withValues(alpha: 0)),
      );
    });
  }
}
