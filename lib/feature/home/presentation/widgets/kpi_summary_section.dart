import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard/feature/home/model/dashboard_data.dart';

import 'kpi_stat_card.dart';

class KpiSummarySection extends StatelessWidget {
  final DashboardSummary summary;
  final NumberFormat currencyFormat;

  static const BoxDecoration _mainCardDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(color: Color(0x40DC2626), blurRadius: 12, offset: Offset(0, 4)),
    ],
  );

  static const TextStyle _headerTitleStyle = TextStyle(
    color: Colors.white70,
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.8,
  );

  static const TextStyle _totalAmountStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
  );

  static const TextStyle _averageTextStyle = TextStyle(
    color: Colors.white70,
    fontSize: 11,
  );

  const KpiSummarySection({
    super.key,
    required this.summary,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card Utama Besar (Total Bunga)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: _mainCardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TOTAL PENDAPATAN', style: _headerTitleStyle),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  currencyFormat.format(summary.totalYTD),
                  style: _totalAmountStyle,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Rata-rata/bln: ${currencyFormat.format(summary.monthlyAverage)}',
                        style: _averageTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2 Sub-card Kecil
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: KpiStatCard(
                  title: 'Total Data',
                  value: '${summary.totalAccounts} Data',
                  icon: Icons.table_chart_outlined,
                  iconColor: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiStatCard(
                  title: 'Produk Terbanyak',
                  value: summary.topProduct.replaceAll('KREDIT ', ''),
                  icon: Icons.trending_up_rounded,
                  iconColor: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
