import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:dashboard/feature/transaction/model/analytics_helper.dart';

class AnalyticsLeaderboardCard extends StatelessWidget {
  final AnalyticsResult analytics;
  final NumberFormat currencyFormat;

  const AnalyticsLeaderboardCard({
    super.key,
    required this.analytics,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final topBranch = analytics.topBranch;
    final topProduct = analytics.topProduct;
    final topQuarter = analytics.topQuarter;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RINGKASAN PENDAPATAN TERTINGGI',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildPodiumRow(
            category: 'KANTOR CABANG ',
            title: topBranch != null ? topBranch.label : '-',
            subtitle: topBranch != null
                ? '${currencyFormat.format(topBranch.total)} (${topBranch.percentage.toStringAsFixed(1)}%)'
                : '-',
            color: const Color(0xFF16A34A),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // 2. Produk Juara 1
          _buildPodiumRow(
            category: 'PRODUK KREDIT ',
            title: topProduct != null
                ? topProduct.name.replaceAll('KREDIT ', '')
                : '-',
            subtitle: topProduct != null
                ? '${currencyFormat.format(topProduct.total)} (${topProduct.percentage.toStringAsFixed(1)}%)'
                : '-',
            color: const Color(0xFF16A34A),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          _buildPodiumRow(
            category: 'PERIODE KUARTAL ',
            title: topQuarter != null
                ? '${topQuarter.title} (${topQuarter.monthsLabel})'
                : '-',
            subtitle: topQuarter != null
                ? '${currencyFormat.format(topQuarter.total)} (${topQuarter.percentage.toStringAsFixed(1)}%)'
                : '-',
            color: const Color(0xFF16A34A),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumRow({
    required String category,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
