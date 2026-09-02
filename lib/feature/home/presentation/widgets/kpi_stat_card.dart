import 'package:flutter/material.dart';

class KpiStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  static const BoxDecoration _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(14)),
    border: Border.fromBorderSide(BorderSide(color: Color(0xFFE2E8F0))),
  );

  static const BorderRadius _iconBorderRadius = BorderRadius.all(Radius.circular(10));

  static const TextStyle _titleStyle = TextStyle(
    fontSize: 10,
    color: Color(0xFF64748B),
    fontWeight: FontWeight.w500,
  );

  static const TextStyle _valueStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0F172A),
  );

  const KpiStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: _cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: _iconBorderRadius,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: _titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: _valueStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
