import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:dashboard/feature/home/model/dashboard_data.dart';
import 'package:dashboard/feature/revenue/presentation/all_loan_products_screen.dart';

class PortfolioDonutChart extends StatefulWidget {
  final List<ProductBreakdown>? breakdown;
  final List<ProductBreakdown>? allProducts;
  final double grandTotal;
  final NumberFormat currencyFormat;

  const PortfolioDonutChart({
    super.key,
    required this.breakdown,
    this.allProducts,
    required this.grandTotal,
    required this.currencyFormat,
  });

  @override
  State<PortfolioDonutChart> createState() => _PortfolioDonutChartState();
}

class _PortfolioDonutChartState extends State<PortfolioDonutChart> {
  int _touchedIndex = -1;

  void _navigateToAllProducts(BuildContext context) {
    final all =
        widget.allProducts ?? widget.breakdown ?? const <ProductBreakdown>[];
    if (all.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AllLoanProductsScreen(
          products: all,
          grandTotal: widget.grandTotal,
          currencyFormat: widget.currencyFormat,
        ),
      ),
    );
  }

  // Palet warna modern bergaya FinTech & Executive Dashboard
  static const List<Color> _chartColors = [
    Color(0xFFE11D48), // Rose Crimson (Utama Bank BPR Supra)
    Color(0xFF2563EB), // Electric Royal Blue
    Color(0xFF059669), // Vibrant Emerald Jade
    Color(0xFFD97706), // Warm Amber Gold
    Color(0xFF7C3AED), // Modern Purple Violet
    Color(0xFF0891B2), // Cyan Teal
    Color(0xFFDB2777), // Neon Magenta
    Color(0xFF475569), // Premium Slate
  ];

  @override
  Widget build(BuildContext context) {
    final rawItems = widget.breakdown ?? const <ProductBreakdown>[];
    final items = rawItems.length > 5 ? rawItems.take(5).toList() : rawItems;

    if (items.isEmpty || widget.grandTotal <= 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text(
            'Tidak ada data portofolio produk',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
        ),
      );
    }

    final top5Total = items.fold<double>(0.0, (sum, item) => sum + item.total);

    final activeProduct = (_touchedIndex >= 0 && _touchedIndex < items.length)
        ? items[_touchedIndex]
        : null;
    final activeColor = activeProduct != null
        ? _chartColors[_touchedIndex % _chartColors.length]
        : const Color(0xFF0F172A);
    final activePercentage = activeProduct != null
        ? (top5Total > 0 ? (activeProduct.total / top5Total) * 100.0 : 0.0)
        : 100.0;
    final activeNominal = activeProduct != null
        ? activeProduct.total
        : top5Total;

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
                'Top 5 Portofolio Produk',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_touchedIndex != -1) ...[
                    InkWell(
                      onTap: () {
                        setState(() => _touchedIndex = -1);
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
                    ),
                    const SizedBox(width: 8),
                  ],
                  InkWell(
                    onTap: () => _navigateToAllProducts(context),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lihat Semua',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: Color(0xFF2563EB),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '5 jenis pinjaman tertinggi · Ketuk grafik untuk rincian',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 20),

          // Donut Chart dengan Persentase di Tengah
          SizedBox(
            height: 210,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, pieTouchResponse) {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          return;
                        }
                        final targetIdx = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                        if (targetIdx >= 0 &&
                            targetIdx < items.length &&
                            _touchedIndex != targetIdx) {
                          setState(() {
                            _touchedIndex = targetIdx;
                          });
                        }
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 3.5,
                    centerSpaceRadius: 62,
                    sections: List.generate(items.length, (i) {
                      final isTouched = i == _touchedIndex;
                      final item = items[i];
                      final color = _chartColors[i % _chartColors.length];
                      final radius = isTouched ? 42.0 : 34.0;

                      return PieChartSectionData(
                        color: color,
                        value: item.total,
                        showTitle: false,
                        title: '',
                        radius: radius,
                        badgeWidget: isTouched
                            ? const _TouchIndicatorBadge()
                            : null,
                        badgePositionPercentageOffset: 1.15,
                      );
                    }),
                  ),
                ),

                // Center Persentase Tunggal Bersih
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: _touchedIndex != -1 ? 26 : 28,
                    fontWeight: FontWeight.w900,
                    color: activeColor,
                    letterSpacing: -0.5,
                  ),
                  child: Text(
                    _touchedIndex != -1
                        ? '${activePercentage.toStringAsFixed(1)}%'
                        : '100%',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Nilai Rupiah Langsung di Bawah Donut Chart
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.currencyFormat.format(activeNominal),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Legend Card Hanya Menampilkan Nama Produk
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final color = _chartColors[idx % _chartColors.length];
            final isHighlighted = _touchedIndex == idx;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
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
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? color.withValues(alpha: 0.08)
                          : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isHighlighted
                            ? color.withValues(alpha: 0.4)
                            : const Color(0xFFF1F5F9),
                        width: isHighlighted ? 1.2 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Left Colored Capsule Indicator
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Nama Produk Saja
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isHighlighted
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isHighlighted
                                  ? color
                                  : const Color(0xFF1E293B),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TouchIndicatorBadge extends StatelessWidget {
  const _TouchIndicatorBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
    );
  }
}
