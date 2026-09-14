import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';

class ProductBreakdownCard extends StatefulWidget {
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
  State<ProductBreakdownCard> createState() => _ProductBreakdownCardState();
}

class _ProductBreakdownCardState extends State<ProductBreakdownCard> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  String _searchQuery = '';

  // Performance Optimization: Cache pre-lowercased names to avoid O(N) string allocations per frame
  List<ProductBreakdown>? _cachedSource;
  List<String> _cachedLowerNames = const [];

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

  static const Color _selectedItemBgColor = Color(
    0x14DC2626,
  ); // AppTheme.primaryColor 8% alpha

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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureLowerNames() {
    if (!identical(_cachedSource, widget.breakdown)) {
      _cachedSource = widget.breakdown;
      _cachedLowerNames = widget.breakdown
          .map((item) => item.name.toLowerCase())
          .toList(growable: false);
    }
  }

  List<ProductBreakdown> _getFilteredBreakdown() {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return widget.breakdown;

    _ensureLowerNames();
    final result = <ProductBreakdown>[];
    for (int i = 0; i < widget.breakdown.length; i++) {
      if (_cachedLowerNames[i].contains(query)) {
        result.add(widget.breakdown[i]);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final filteredBreakdown = _getFilteredBreakdown();
    final isLargeList = filteredBreakdown.length > 4;

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
              if (widget.selectedProductName != null)
                InkWell(
                  onTap: () => widget.onProductSelected?.call(null),
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
          const SizedBox(height: 12),
          // --- Search Bar ---
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Cari jenis pinjaman...',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 36),
                suffixIcon: _searchQuery.isNotEmpty
                    ? InkWell(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Icon(
                          Icons.clear_rounded,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(minWidth: 32),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.breakdown.isEmpty)
            const Text('Tidak ada rincian produk', style: _emptyTextStyle)
          else if (filteredBreakdown.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              child: const Text(
                'Tidak ada jenis pinjaman yang cocok',
                style: _emptyTextStyle,
              ),
            )
          else
            _buildListContainer(filteredBreakdown, isLargeList),
        ],
      ),
    );
  }

  Widget _buildListContainer(
    List<ProductBreakdown> filteredBreakdown,
    bool isLargeList,
  ) {
    final listWidget = Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      thickness: 4.5,
      radius: const Radius.circular(4),
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: !isLargeList,
        padding: const EdgeInsets.only(right: 6),
        itemCount: filteredBreakdown.length,
        itemBuilder: (context, index) {
          final item = filteredBreakdown[index];
          final isSelected = widget.selectedProductName == item.name;
          final percent = widget.grandTotal > 0
              ? (item.total / widget.grandTotal)
              : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: isSelected ? _selectedItemBgColor : Colors.transparent,
              borderRadius: _itemBorderRadius,
              child: InkWell(
                onTap: () {
                  if (widget.onProductSelected != null) {
                    widget.onProductSelected!(
                      isSelected ? null : item.name,
                    );
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isSelected)
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      right: 6,
                                      top: 2,
                                    ),
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
                                      height: 1.25,
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.currencyFormat.format(item.total)} (${item.percentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _FastProgressBar(
                        value: percent,
                        foregroundColor: isSelected
                            ? AppTheme.primaryColor
                            : const Color(0xA6DC2626),
                        backgroundColor: const Color(0xFFF1F5F9),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    if (isLargeList) {
      return SizedBox(
        height: 340,
        child: listWidget,
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 340),
      child: listWidget,
    );
  }
}

/// Lightweight static progress bar without Ticker or AnimationController overhead.
/// Avoids LinearProgressIndicator's frame listener and multiple render passes.
class _FastProgressBar extends StatelessWidget {
  final double value;
  final Color foregroundColor;
  final Color backgroundColor;

  const _FastProgressBar({
    required this.value,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: foregroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
        ),
      ),
    );
  }
}
