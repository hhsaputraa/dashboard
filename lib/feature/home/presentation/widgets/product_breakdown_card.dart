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

  static const BoxDecoration _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.fromBorderSide(BorderSide(color: Color(0xFFE2E8F0))),
  );

  static const BoxDecoration _resetBtnDecoration = BoxDecoration(
    color: Color(0x1ADC2626), // AppTheme.primaryColor 10% alpha
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const BorderRadius _itemBorderRadius = BorderRadius.all(
    Radius.circular(10),
  );
  static const BorderRadius _progressBorderRadius = BorderRadius.all(
    Radius.circular(6),
  );

  static const Color _selectedItemBgColor = Color(
    0x14DC2626,
  ); // AppTheme.primaryColor 8% alpha

  static const AlwaysStoppedAnimation<Color> _selectedProgressAnimation =
      AlwaysStoppedAnimation<Color>(AppTheme.primaryColor);
  static const AlwaysStoppedAnimation<Color> _unselectedProgressAnimation =
      AlwaysStoppedAnimation<Color>(
        Color(0xA6DC2626),
      ); // AppTheme.primaryColor 65% alpha

  static const TextStyle _cardHeaderStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0F172A),
  );

  static const TextStyle _resetTextStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: AppTheme.primaryColor,
  );

  static const TextStyle _hintTextStyle = TextStyle(
    fontSize: 11,
    color: Color(0xFF94A3B8),
  );

  static const TextStyle _emptyTextStyle = TextStyle(
    fontSize: 12,
    color: Color(0xFF94A3B8),
  );

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Kontribusi Berdasarkan Jenis Pinjaman',
                  style: _cardHeaderStyle,
                ),
              ),
              if (selectedProductName != null)
                InkWell(
                  onTap: () => onProductSelected?.call(null),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: _resetBtnDecoration,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.clear_rounded,
                          size: 12,
                          color: AppTheme.primaryColor,
                        ),
                        SizedBox(width: 4),
                        Text('Reset', style: _resetTextStyle),
                      ],
                    ),
                  ),
                )
              else
                const Text('Tap untuk filter grafik', style: _hintTextStyle),
            ],
          ),
          const SizedBox(height: 14),
          if (breakdown.isEmpty)
            const Text('Tidak ada rincian produk', style: _emptyTextStyle),
          ...breakdown.map((item) {
            final isSelected = selectedProductName == item.name;
            final percent = grandTotal > 0 ? (item.total / grandTotal) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: isSelected ? _selectedItemBgColor : Colors.transparent,
                borderRadius: _itemBorderRadius,
                child: InkWell(
                  onTap: () {
                    if (onProductSelected != null) {
                      onProductSelected!(isSelected ? null : item.name);
                    }
                  },
                  borderRadius: _itemBorderRadius,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: _itemBorderRadius,
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
                          borderRadius: _progressBorderRadius,
                          child: LinearProgressIndicator(
                            value: percent.clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: isSelected
                                ? _selectedProgressAnimation
                                : _unselectedProgressAnimation,
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
