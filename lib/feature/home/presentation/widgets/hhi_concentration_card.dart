import 'package:flutter/material.dart';
import 'package:dashboard/feature/home/model/executive_analytics_helper.dart';

class HhiConcentrationCard extends StatefulWidget {
  final HhiResult hhi;
  final bool initiallyExpanded;

  const HhiConcentrationCard({
    super.key,
    required this.hhi,
    this.initiallyExpanded = true,
  });

  @override
  State<HhiConcentrationCard> createState() => _HhiConcentrationCardState();
}

class _HhiConcentrationCardState extends State<HhiConcentrationCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  Color _getStatusColor() {
    switch (widget.hhi.riskLevel) {
      case HhiRiskLevel.healthy:
        return const Color(0xFF16A34A); // Emerald Green
      case HhiRiskLevel.moderate:
        return const Color(0xFFD97706); // Amber Gold
      case HhiRiskLevel.highRisk:
        return const Color(0xFFDC2626); // Crimson Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final clampedScore = widget.hhi.score.clamp(0.0, 10000.0);
    final scoreRatio = clampedScore / 10000.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kartu (Accordion Trigger)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
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
                            color: statusColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.pie_chart_outline_rounded,
                            size: 16,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Diversifikasi Portofolio (HHI)',
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
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.hhi.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
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
                        const SizedBox(height: 14),

                        // Skor Utama & Skala
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              widget.hhi.score.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: statusColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '/ 10.000 poin',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Indikator Skala Segmen (Sehat: <1.500 | Sedang: 1.500-2.500 | Tinggi: >2.500)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            height: 8,
                            child: Stack(
                              children: [
                                const Row(
                                  children: [
                                    Expanded(
                                      flex: 15,
                                      child: ColoredBox(color: Color(0xFFBBF7D0)),
                                    ),
                                    SizedBox(width: 2),
                                    Expanded(
                                      flex: 10,
                                      child: ColoredBox(color: Color(0xFFFDE68A)),
                                    ),
                                    SizedBox(width: 2),
                                    Expanded(
                                      flex: 75,
                                      child: ColoredBox(color: Color(0xFFFECACA)),
                                    ),
                                  ],
                                ),
                                FractionallySizedBox(
                                  widthFactor: scoreRatio.clamp(0.02, 1.0),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      width: 4,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Label Batas Skala
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '0 (Sehat)',
                              style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '1.500',
                              style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '2.500',
                              style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '10.000 (Konsentrasi)',
                              style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Box Keterangan & Insight Dominasi Produk
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: statusColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.hhi.description,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF475569),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
