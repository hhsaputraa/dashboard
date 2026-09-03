import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:dashboard/feature/home/model/interest_record.dart';
import 'package:dashboard/feature/revenue/model/branch_product_comparison_helper.dart';

enum ComparisonViewMode { barTotal, lineMonthly }

class BranchProductComparisonCard extends StatefulWidget {
  final List<InterestRecord> records;
  final NumberFormat currencyFormat;

  const BranchProductComparisonCard({
    super.key,
    required this.records,
    required this.currencyFormat,
  });

  @override
  State<BranchProductComparisonCard> createState() =>
      _BranchProductComparisonCardState();
}

class _BranchProductComparisonCardState
    extends State<BranchProductComparisonCard> {
  ComparisonViewMode _viewMode = ComparisonViewMode.barTotal;

  final Set<int> _selectedBranchIds = {};
  final Set<String> _selectedProducts = {};

  // Untuk Line Chart: jika null berarti agregat semua cabang terpilih, jika ada id berarti cabang tersebut
  int? _focusedBranchIdForLine;

  // Nilai Y bar yang sedang disentuh/ditap untuk menampilkan garis bantu putus-putus
  double? _touchedBarY;

  static const List<Color> _productColors = [
    Color(0xFFE11D48), // Crimson Red
    Color(0xFF2563EB), // Royal Blue
    Color(0xFF059669), // Emerald Green
  ];

  static const List<String> _monthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Ags',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  // Cached data to eliminate heavy re-computations on build/touch
  List<BranchInfo> _availableBranches = const [];
  List<ProductInfo> _availableProducts = const [];
  List<BranchInfo> _selectedBranchesList = const [];
  List<ProductInfo> _selectedProductsList = const [];
  Map<int, Map<String, BranchProductSeries>> _seriesMap = const {};

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void didUpdateWidget(BranchProductComparisonCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.records != oldWidget.records) {
      _initData();
    }
  }

  void _initData() {
    _selectedBranchIds.clear();
    _selectedProducts.clear();
    _focusedBranchIdForLine = null;
    _touchedBarY = null;
    _updateAvailableBranches();
    _updateAvailableProducts();
    _recomputeSeries();
  }

  void _updateAvailableBranches() {
    _availableBranches =
        BranchProductComparisonHelper.getAvailableBranches(widget.records);
  }

  void _updateAvailableProducts() {
    final branchFilteredRecords = _selectedBranchIds.isNotEmpty
        ? widget.records
            .where((r) => _selectedBranchIds.contains(r.idKantor))
            .toList()
        : widget.records;
    _availableProducts =
        BranchProductComparisonHelper.getAvailableProducts(branchFilteredRecords);
  }

  void _recomputeSeries() {
    _selectedBranchesList = _availableBranches
        .where((b) => _selectedBranchIds.contains(b.idKantor))
        .toList();
    _selectedProductsList = _availableProducts
        .where((p) => _selectedProducts.contains(p.name))
        .toList();
    _seriesMap = BranchProductComparisonHelper.buildSeriesMap(
      records: widget.records,
      selectedBranchIds: _selectedBranchIds,
      selectedProducts: _selectedProducts,
    );
  }

  void _openBranchPickerModal(
    BuildContext context,
    List<BranchInfo> availableBranches,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ItemPickerBottomSheet<BranchInfo, int>(
        title: 'Pilih Kantor Cabang',
        unitLabel: 'kantor',
        applySuffix: 'Cabang',
        emptyMessage: 'Kantor cabang tidak ditemukan',
        searchHint: 'Cari kantor cabang...',
        limitExceededMessage: 'Maksimal memilih 5 kantor cabang!',
        maxSelect: 5,
        activeColor: const Color(0xFF0F172A),
        items: availableBranches,
        initiallySelected: _selectedBranchIds,
        getId: (b) => b.idKantor,
        getLabel: (b) => b.label,
        matchesQuery: (b, q) =>
            b.label.toLowerCase().contains(q) ||
            b.idKantor.toString().contains(q),
        quickSelectLabel:
            availableBranches.length > 5 ? 'Pilih 5 Teratas' : null,
        onQuickSelect: () =>
            availableBranches.take(5).map((b) => b.idKantor).toSet(),
        onApply: (newSelection) {
          setState(() {
            _selectedBranchIds
              ..clear()
              ..addAll(newSelection);
            if (_focusedBranchIdForLine != null &&
                !_selectedBranchIds.contains(_focusedBranchIdForLine)) {
              _focusedBranchIdForLine = null;
            }
            if (_selectedBranchIds.isEmpty) {
              _selectedProducts.clear();
            }
            _updateAvailableProducts();
            _recomputeSeries();
          });
        },
      ),
    );
  }

  void _openProductPickerModal(
    BuildContext context,
    List<ProductInfo> availableProducts,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ItemPickerBottomSheet<ProductInfo, String>(
        title: 'Pilih Jenis Pinjaman',
        unitLabel: 'jenis pinjaman',
        applySuffix: 'Pinjaman',
        emptyMessage: 'Jenis pinjaman tidak ditemukan',
        searchHint: 'Cari jenis pinjaman...',
        limitExceededMessage: 'Maksimal memilih 3 jenis pinjaman!',
        maxSelect: 3,
        activeColor: const Color(0xFFE11D48),
        items: availableProducts,
        initiallySelected: _selectedProducts,
        getId: (p) => p.name,
        getLabel: (p) => p.name,
        matchesQuery: (p, q) => p.name.toLowerCase().contains(q),
        quickSelectLabel: 'Pilih Top 3 Pinjaman',
        quickSelectColor: const Color(0xFFE11D48),
        onQuickSelect: () =>
            availableProducts.take(3).map((p) => p.name).toSet(),
        onApply: (newSelection) {
          setState(() {
            _selectedProducts
              ..clear()
              ..addAll(newSelection);
            _recomputeSeries();
          });
        },
      ),
    );
  }

  void _selectTop3Products() {
    final top = BranchProductComparisonHelper.getTopProducts(
      widget.records,
      limit: 3,
    );
    setState(() {
      _selectedProducts
        ..clear()
        ..addAll(top);
      _recomputeSeries();
    });
  }

  static String _formatCompact(double value) {
    if (value <= 0) return '0';
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)} M';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(value >= 10000000 ? 0 : 1)} jt';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)} rb';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final availableBranches = _availableBranches;
    final availableProducts = _availableProducts;
    final selectedBranchesList = _selectedBranchesList;
    final selectedProductsList = _selectedProductsList;
    final seriesMap = _seriesMap;
    final isProductEnabled = _selectedBranchIds.isNotEmpty;

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
          // Header Judul & Switcher Mode (Bar vs Line)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Komparasi Cabang & Pinjaman',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Bandingkan cabang (maks. 5) & jenis pinjaman (maks. 3)',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Segmented Toggle
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeButton(
                      mode: ComparisonViewMode.barTotal,
                      icon: Icons.bar_chart_rounded,
                      label: 'Total',
                    ),
                    const SizedBox(width: 2),
                    _buildModeButton(
                      mode: ComparisonViewMode.lineMonthly,
                      icon: Icons.show_chart_rounded,
                      label: 'Tren',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons: Pilih Cabang & Pilih Pinjaman (Flow Popup Checkbox)
          Row(
            children: [
              Expanded(
                child: _buildPickerButton(
                  onTap: () =>
                      _openBranchPickerModal(context, availableBranches),
                  isEnabled: true,
                  icon: Icons.storefront_rounded,
                  iconColor: const Color(0xFF2563EB),
                  title: 'Pilih Cabang',
                  subtitle: _selectedBranchIds.isEmpty
                      ? '0 Cabang Dipilih'
                      : '${_selectedBranchIds.length} Cabang Dipilih',
                  hasSelection: _selectedBranchIds.isNotEmpty,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPickerButton(
                  onTap: isProductEnabled
                      ? () =>
                          _openProductPickerModal(context, availableProducts)
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Pilih kantor cabang terlebih dahulu!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                  isEnabled: isProductEnabled,
                  icon: isProductEnabled
                      ? Icons.account_balance_wallet_rounded
                      : Icons.lock_outline_rounded,
                  iconColor: isProductEnabled
                      ? const Color(0xFFE11D48)
                      : const Color(0xFF94A3B8),
                  title: 'Pilih Pinjaman',
                  subtitle: !isProductEnabled
                      ? 'Pilih cabang dulu'
                      : _selectedProducts.isEmpty
                          ? '0 Pinjaman Dipilih'
                          : '${_selectedProducts.length} Pinjaman Dipilih',
                  hasSelection:
                      isProductEnabled && _selectedProducts.isNotEmpty,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Shortcut & Tag Ringkasan Pilihan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: selectedBranchesList.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Pilih cabang untuk mulai komparasi',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Dipilih: ${selectedBranchesList.map((b) => b.label).join(', ')}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
              ),
              if (isProductEnabled)
                InkWell(
                  onTap: _selectTop3Products,
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 13,
                          color: Color(0xFFE11D48),
                        ),
                        SizedBox(width: 2),
                        Text(
                          'Top 3 Pinjaman',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFE11D48),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // Legend Jenis Pinjaman yang Terpilih (Sederhana & Rapi dengan Dot Warna)
          if (selectedProductsList.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Pinjaman:',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ...List.generate(selectedProductsList.length, (index) {
                  final prod = selectedProductsList[index];
                  final color = _productColors[index % _productColors.length];
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        prod.name,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
          const SizedBox(height: 14),

          // Sub-filter Cabang khusus untuk Line Chart jika mode = lineMonthly
          if (_viewMode == ComparisonViewMode.lineMonthly &&
              selectedBranchesList.length > 1) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text(
                    'Fokus Tren:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildLineBranchFocusChip(id: null, label: 'Semua Terpilih'),
                  ...selectedBranchesList.map(
                    (b) => _buildLineBranchFocusChip(
                      id: b.idKantor,
                      label: b.label,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Area Tampilan Grafik
          if (_selectedBranchIds.isEmpty)
            Container(
              height: 220,
              alignment: Alignment.center,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 34,
                    color: Color(0xFFCBD5E1),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pilih kantor cabang terlebih dahulu',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else if (_selectedProducts.isEmpty)
            Container(
              height: 220,
              alignment: Alignment.center,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 34,
                    color: Color(0xFFCBD5E1),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pilih jenis pinjaman untuk melihat perbandingan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else if (_viewMode == ComparisonViewMode.barTotal)
            SizedBox(
              height: 260,
              child: _buildBarChart(
                branches: selectedBranchesList,
                products: selectedProductsList,
                seriesMap: seriesMap,
              ),
            )
          else
            SizedBox(
              height: 260,
              child: _buildLineChart(
                branches: selectedBranchesList,
                products: selectedProductsList,
                seriesMap: seriesMap,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required ComparisonViewMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _viewMode == mode;
    return InkWell(
      onTap: () {
        if (_viewMode != mode) {
          setState(() {
            _viewMode = mode;
            _touchedBarY = null;
          });
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerButton({
    required VoidCallback onTap,
    required bool isEnabled,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool hasSelection,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isEnabled
              ? const Color(0xFFF8FAFC)
              : const Color(0xFFF1F5F9).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isEnabled
                ? const Color(0xFFE2E8F0)
                : const Color(0xFFE2E8F0).withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      color: isEnabled
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          hasSelection ? FontWeight.bold : FontWeight.w500,
                      color: hasSelection
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              isEnabled
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.lock_outline_rounded,
              size: isEnabled ? 18 : 14,
              color: isEnabled
                  ? const Color(0xFF64748B)
                  : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineBranchFocusChip({required int? id, required String label}) {
    final isSelected = _focusedBranchIdForLine == id;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _focusedBranchIdForLine = id;
          });
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0F172A)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart({
    required List<BranchInfo> branches,
    required List<ProductInfo> products,
    required Map<int, Map<String, BranchProductSeries>> seriesMap,
  }) {
    double maxY = 0.0;
    for (final b in branches) {
      for (final p in products) {
        final val = seriesMap[b.idKantor]?[p.name]?.total ?? 0.0;
        if (val > maxY) maxY = val;
      }
    }
    if (maxY <= 0) maxY = 1000000;
    maxY *= 1.25;

    final rodWidth = products.length == 1
        ? 20.0
        : products.length == 2
        ? 12.0
        : 8.5;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
            if (!event.isInterestedForInteractions ||
                response == null ||
                response.spot == null) {
              if (_touchedBarY != null) {
                setState(() {
                  _touchedBarY = null;
                });
              }
              return;
            }
            final newY = response.spot!.touchedRodData.toY;
            if (_touchedBarY != newY) {
              setState(() {
                _touchedBarY = newY;
              });
            }
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF0F172A),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex < 0 || groupIndex >= branches.length) return null;
              if (rodIndex < 0 || rodIndex >= products.length) return null;

              final branch = branches[groupIndex];
              final prod = products[rodIndex];
              final nominal = widget.currencyFormat.format(rod.toY);
              final color = _productColors[rodIndex % _productColors.length];

              return BarTooltipItem(
                '${branch.label}\n',
                TextStyle(
                  color: color, // Sesuai warna dot
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '${prod.name}\n',
                    style: TextStyle(
                      color: color.withValues(alpha: 0.9), // Sesuai warna dot
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: nominal,
                    style: const TextStyle(
                      color: Colors.white, // Text angka warna putih
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        extraLinesData: ExtraLinesData(
          extraLinesOnTop: true,
          horizontalLines: [
            if (_touchedBarY != null)
              HorizontalLine(
                y: _touchedBarY!,
                color: const Color(0xFF94A3B8), // Abu-abu
                strokeWidth: 1.5,
                dashArray: const [4, 4], // Garis lurus putus-putus bantuan
              ),
          ],
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 46,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    _formatCompact(value),
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= branches.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    branches[index].label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) =>
              const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
          getDrawingVerticalLine: (value) => const FlLine(
            color: Color(0xFFF1F5F9),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(branches.length, (bIndex) {
          final branch = branches[bIndex];
          return BarChartGroupData(
            x: bIndex,
            barsSpace: 4,
            barRods: List.generate(products.length, (pIndex) {
              final prod = products[pIndex];
              final total =
                  seriesMap[branch.idKantor]?[prod.name]?.total ?? 0.0;
              final color = _productColors[pIndex % _productColors.length];

              return BarChartRodData(
                toY: total,
                color: color,
                width: rodWidth,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildLineChart({
    required List<BranchInfo> branches,
    required List<ProductInfo> products,
    required Map<int, Map<String, BranchProductSeries>> seriesMap,
  }) {
    final List<LineChartBarData> lineBars = [];
    double maxY = 0.0;

    for (int pIndex = 0; pIndex < products.length; pIndex++) {
      final prod = products[pIndex];
      final color = _productColors[pIndex % _productColors.length];

      final spots = <FlSpot>[];
      for (int m = 0; m < 12; m++) {
        double monthVal = 0.0;
        if (_focusedBranchIdForLine != null) {
          monthVal =
              seriesMap[_focusedBranchIdForLine]?[prod.name]?.monthly[m] ?? 0.0;
        } else {
          // Agregasi seluruh cabang yang sedang terpilih
          for (final b in branches) {
            monthVal += seriesMap[b.idKantor]?[prod.name]?.monthly[m] ?? 0.0;
          }
        }
        if (monthVal > maxY) maxY = monthVal;
        spots.add(FlSpot(m.toDouble(), monthVal));
      }

      lineBars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.25,
          color: color,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: color.withValues(alpha: 0.06),
          ),
        ),
      );
    }

    if (maxY <= 0) maxY = 1000000;
    maxY *= 1.25;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        minX: 0,
        maxX: 11,
        lineTouchData: LineTouchData(
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((spotIndex) {
              return TouchedSpotIndicatorData(
                const FlLine(
                  color: Color(0xFF94A3B8), // Garis bantu abu-abu ke sumbu bulan
                  strokeWidth: 1.5,
                  dashArray: [4, 4], // Putus-putus
                ),
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2.5,
                      strokeColor: barData.color ?? const Color(0xFF0F172A),
                    );
                  },
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF0F172A),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final pIndex = spot.barIndex;
                if (pIndex < 0 || pIndex >= products.length) return null;
                final prod = products[pIndex];
                final nominal = widget.currencyFormat.format(spot.y);
                final monthIdx = spot.x.toInt();
                final monthName =
                    (monthIdx >= 0 && monthIdx < _monthLabels.length)
                        ? _monthLabels[monthIdx]
                        : '';

                return LineTooltipItem(
                  '${prod.name} ($monthName)\n',
                  TextStyle(
                    color: _productColors[pIndex % _productColors.length],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: nominal,
                      style: const TextStyle(
                        color: Colors.white, // Text rupiah/angka putih
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
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
          drawVerticalLine: true,
          drawHorizontalLine: true,
          verticalInterval: 1,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
          getDrawingVerticalLine: (_) => const FlLine(
            color: Color(0xFFE2E8F0), // Garis bantu abu-abu
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 46,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    _formatCompact(value),
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 26,
              getTitlesWidget: (value, meta) {
                final m = value.toInt();
                if (m < 0 || m >= _monthLabels.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    _monthLabels[m],
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: lineBars,
      ),
    );
  }
}

// -------------------------------------------------------------
// REUSABLE MODAL BOTTOM SHEET: ITEM PICKER (CABANG / PINJAMAN)
// -------------------------------------------------------------
class _ItemPickerBottomSheet<T, K> extends StatefulWidget {
  final String title;
  final String unitLabel;
  final String applySuffix;
  final String emptyMessage;
  final String searchHint;
  final String limitExceededMessage;
  final int maxSelect;
  final Color activeColor;
  final List<T> items;
  final Set<K> initiallySelected;
  final K Function(T item) getId;
  final String Function(T item) getLabel;
  final bool Function(T item, String query) matchesQuery;
  final String? quickSelectLabel;
  final Color? quickSelectColor;
  final Set<K>? Function()? onQuickSelect;
  final ValueChanged<Set<K>> onApply;

  const _ItemPickerBottomSheet({
    required this.title,
    required this.unitLabel,
    required this.applySuffix,
    required this.emptyMessage,
    required this.searchHint,
    required this.limitExceededMessage,
    required this.maxSelect,
    required this.activeColor,
    required this.items,
    required this.initiallySelected,
    required this.getId,
    required this.getLabel,
    required this.matchesQuery,
    this.quickSelectLabel,
    this.quickSelectColor,
    this.onQuickSelect,
    required this.onApply,
  });

  @override
  State<_ItemPickerBottomSheet<T, K>> createState() =>
      _ItemPickerBottomSheetState<T, K>();
}

class _ItemPickerBottomSheetState<T, K>
    extends State<_ItemPickerBottomSheet<T, K>> {
  late final Set<K> _tempSelected;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempSelected = Set<K>.from(widget.initiallySelected);
  }

  void _handleQuickSelect() {
    if (widget.onQuickSelect != null) {
      final selected = widget.onQuickSelect!();
      if (selected != null) {
        setState(() {
          _tempSelected
            ..clear()
            ..addAll(selected);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = widget.items.where((item) {
      if (query.isEmpty) return true;
      return widget.matchesQuery(item, query);
    }).toList();

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Maksimal ${widget.maxSelect} ${widget.unitLabel} (${_tempSelected.length}/${widget.maxSelect} dipilih)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Color(0xFF64748B),
                    ),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action Quick Selection
              if (widget.quickSelectLabel != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: _handleQuickSelect,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: (widget.quickSelectColor ?? widget.activeColor)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.quickSelectColor != null
                                ? Icons.bolt_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 14,
                            color:
                                widget.quickSelectColor ?? widget.activeColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.quickSelectLabel!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color:
                                  widget.quickSelectColor ?? widget.activeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Search Bar
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF94A3B8),
                    size: 18,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF0F172A),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Daftar Checkbox
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                ),
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            widget.emptyMessage,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, idx) {
                          final item = filtered[idx];
                          final id = widget.getId(item);
                          final isChecked = _tempSelected.contains(id);
                          final canCheckMore =
                              _tempSelected.length < widget.maxSelect;

                          return CheckboxListTile(
                            value: isChecked,
                            activeColor: widget.activeColor,
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            title: Text(
                              widget.getLabel(item),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  if (canCheckMore) {
                                    _tempSelected.add(id);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          widget.limitExceededMessage,
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } else {
                                  _tempSelected.remove(id);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),

              // Footer Buttons: Batal & Terapkan
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(_tempSelected);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Terapkan (${_tempSelected.length} ${widget.applySuffix})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
