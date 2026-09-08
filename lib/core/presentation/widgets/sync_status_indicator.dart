import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Reusable status indicator displaying network synchronization state,
/// error state, or the last updated timestamp with a colored indicator dot.
class SyncStatusIndicator extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final DateTime lastFetched;
  final DateFormat? dateFormat;
  final String syncingText;
  final String errorText;
  final String Function(String formattedDate)? successTextBuilder;

  static final DateFormat defaultDateFormat = DateFormat('dd MMM yyyy, HH:mm:ss');
  static const Color loadingColor = Color(0xFFEAB308);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF22C55E);

  const SyncStatusIndicator({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.lastFetched,
    this.dateFormat,
    this.syncingText = 'Menyinkronkan data...',
    this.errorText = 'Gagal terhubung ke server',
    this.successTextBuilder,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    if (isLoading) {
      statusColor = loadingColor;
      statusText = syncingText;
    } else if (errorMessage != null) {
      statusColor = errorColor;
      statusText = errorText;
    } else {
      statusColor = successColor;
      final fmt = dateFormat ?? defaultDateFormat;
      final formattedDate = fmt.format(lastFetched);
      statusText = successTextBuilder != null
          ? successTextBuilder!(formattedDate)
          : 'Update data: $formattedDate';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          statusText,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
