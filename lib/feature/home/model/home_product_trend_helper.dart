import '../model/dashboard_data.dart';

/// Pure helper for calculating active monthly trends based on selected products.
/// Isolated from UI and controllers to enable fast, headless testing and high cohesion.
class HomeProductTrendHelper {
  static const List<String> defaultMonthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  /// Calculates monthly trend items for the given [selectedProduct].
  ///
  /// - If [selectedProduct] is null or empty, returns [data.monthlyTrend].
  /// - Matches records by `jenisPinjaman` first.
  /// - If not found in records, falls back to `data.productBreakdown` (using predefined `monthlyTrend`
  ///   or scaled by ratio of product total to `summary.totalYTD`).
  /// - If no match is found, defaults to [data.monthlyTrend].
  static List<MonthlyTrendItem> calculateActiveTrend({
    required DashboardData data,
    required String? selectedProduct,
    List<String> monthNames = defaultMonthNames,
  }) {
    if (selectedProduct == null || selectedProduct.trim().isEmpty) {
      return data.monthlyTrend;
    }

    final selectedLower = selectedProduct.trim().toLowerCase();

    // 1. Cek matching dari raw records (agregasi bulanan per jenis pinjaman)
    if (data.records.isNotEmpty) {
      final monthlySums = List<double>.filled(12, 0.0);
      bool hasMatch = false;

      for (final r in data.records) {
        if (r.jenisPinjaman.trim().toLowerCase() == selectedLower) {
          hasMatch = true;
          for (int i = 0; i < 12 && i < r.bulanan.length; i++) {
            monthlySums[i] += r.bulanan[i];
          }
        }
      }

      if (hasMatch) {
        return List.generate(12, (i) {
          return MonthlyTrendItem(
            month: i < monthNames.length ? monthNames[i] : 'M${i + 1}',
            total: monthlySums[i],
          );
        });
      }
    }

    // 2. Cek matching dari productBreakdown
    for (final p in data.productBreakdown) {
      if (p.name.trim().toLowerCase() == selectedLower) {
        if (p.monthlyTrend != null && p.monthlyTrend!.isNotEmpty) {
          return p.monthlyTrend!;
        }
        if (data.summary.totalYTD > 0) {
          final ratio = p.total / data.summary.totalYTD;
          return data.monthlyTrend
              .map((m) => MonthlyTrendItem(month: m.month, total: m.total * ratio))
              .toList();
        }
        break;
      }
    }

    return data.monthlyTrend;
  }
}
