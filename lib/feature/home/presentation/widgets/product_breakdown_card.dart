import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';

class ProductBreakdownCard extends StatelessWidget {
  final List<ProductBreakdown> breakdown;
  final double grandTotal;
  final NumberFormat currencyFormat;

  const ProductBreakdownCard({
    super.key,
    required this.breakdown,
    required this.grandTotal,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    // Urutkan data kontribusi dari nominal/total tertinggi ke terendah secara dinamis
    final sortedBreakdown = List<ProductBreakdown>.from(breakdown)
      ..sort((a, b) => b.total.compareTo(a.total));

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
          const Text(
            'Kontribusi Berdasarkan Jenis Kredit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          if (sortedBreakdown.isEmpty)
            const Text(
              'Tidak ada rincian produk',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ...sortedBreakdown.map((item) {
            final percent = grandTotal > 0 ? (item.total / grandTotal) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${currencyFormat.format(item.total)} (${item.percentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percent.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
