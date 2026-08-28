import 'interest_record.dart';

class DashboardSummary {
  final double totalYTD;
  final double monthlyAverage;
  final int totalAccounts;
  final String topProduct;

  const DashboardSummary({
    required this.totalYTD,
    required this.monthlyAverage,
    required this.totalAccounts,
    required this.topProduct,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return DashboardSummary(
      totalYTD: parseDouble(json['total_ytd']),
      monthlyAverage: parseDouble(json['monthly_average']),
      totalAccounts: int.tryParse(json['total_accounts']?.toString() ?? '') ?? 0,
      topProduct: json['top_product']?.toString() ?? '-',
    );
  }
}

class MonthlyTrendItem {
  final String month;
  final double total;

  const MonthlyTrendItem({
    required this.month,
    required this.total,
  });

  factory MonthlyTrendItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return MonthlyTrendItem(
      month: json['month']?.toString() ?? '',
      total: parseDouble(json['total']),
    );
  }
}

class ProductBreakdown {
  final String name;
  final double total;
  final double percentage;
  final List<MonthlyTrendItem>? monthlyTrend;

  const ProductBreakdown({
    required this.name,
    required this.total,
    required this.percentage,
    this.monthlyTrend,
  });

  factory ProductBreakdown.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final productTrend = json['monthly_trend'] is List
        ? (json['monthly_trend'] as List)
            .map((e) => MonthlyTrendItem.fromJson(e as Map<String, dynamic>))
            .toList()
        : null;

    return ProductBreakdown(
      name: json['name']?.toString() ?? '-',
      total: parseDouble(json['total']),
      percentage: parseDouble(json['percentage']),
      monthlyTrend: productTrend,
    );
  }
}

class DashboardData {
  final DashboardSummary summary;
  final List<MonthlyTrendItem> monthlyTrend;
  final List<ProductBreakdown> productBreakdown;
  final List<InterestRecord> records;

  const DashboardData({
    required this.summary,
    required this.monthlyTrend,
    required this.productBreakdown,
    this.records = const [],
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final summaryObj = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : <String, dynamic>{};

    final trendList = json['monthly_trend'] is List
        ? (json['monthly_trend'] as List)
            .map((e) => MonthlyTrendItem.fromJson(e as Map<String, dynamic>))
            .toList()
        : <MonthlyTrendItem>[];

    final breakdownList = json['product_breakdown'] is List
        ? (json['product_breakdown'] as List)
            .map((e) => ProductBreakdown.fromJson(e as Map<String, dynamic>))
            .toList()
        : <ProductBreakdown>[];

    final recordList = json['records'] is List
        ? (json['records'] as List)
            .map((e) => InterestRecord.fromJson(e as Map<String, dynamic>))
            .toList()
        : <InterestRecord>[];

    return DashboardData(
      summary: DashboardSummary.fromJson(summaryObj),
      monthlyTrend: trendList,
      productBreakdown: breakdownList,
      records: recordList,
    );
  }
}
