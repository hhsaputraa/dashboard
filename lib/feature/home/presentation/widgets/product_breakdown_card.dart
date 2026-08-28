import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';

class ProductBreakdownCard extends StatelessWidget {
  final List<ProductBreakdown> breakdown;
  final double grandTotal;
  final NumberFormat currencyFormat;
  final String? selectedProductName;
  final ValueChanged<String?>? onProductSelected;

  const ProductBreakdownCard({
    super.key,
    required this.breakdown,
    required this.grandTotal,
    required this.currencyFormat,
    this.selectedProductName,
    this.onProductSelected,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kontribusi Berdasarkan Jenis Kredit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              if (selectedProductName != null)
                InkWell(
                  onTap: () => onProductSelected?.call(null),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.clear_rounded, size: 12, color: AppTheme.primaryColor),
                        SizedBox(width: 4),
                        Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Text(
                  'Tap untuk filter grafik',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (sortedBreakdown.isEmpty)
            const Text(
              'Tidak ada rincian produk',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ...sortedBreakdown.map((item) {
            final isSelected = selectedProductName == item.name;
            final percent = grandTotal > 0 ? (item.total / grandTotal) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: isSelected
                    ? AppTheme.primaryColor.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    if (onProductSelected != null) {
                      onProductSelected!(isSelected ? null : item.name);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : const Color(0xFFF1F5F9),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if (isSelected)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 6),
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        size: 14,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                            : const Color(0xFF1E293B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${currencyFormat.format(item.total)} (${item.percentage.toStringAsFixed(1)}%)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : const Color(0xFF334155),
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.primaryColor.withValues(alpha: 0.65),
                            ),
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
