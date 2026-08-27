import 'package:flutter/material.dart';
import 'package:dashboard/core/theme/app_theme.dart';

class KantorFilterChips extends StatelessWidget {
  final int selectedKantor;
  final ValueChanged<int> onKantorChanged;

  static const List<Map<String, dynamic>> defaultOffices = [
    {'id': 0, 'label': 'Semua Kantor'},
    {'id': 1, 'label': 'Kantor 1'},
    {'id': 2, 'label': 'Kantor 2'},
    {'id': 3, 'label': 'Kantor 3'},
  ];

  const KantorFilterChips({
    super.key,
    required this.selectedKantor,
    required this.onKantorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: defaultOffices.map((off) {
          final id = off['id'] as int;
          final isSelected = selectedKantor == id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              label: Text(off['label'] as String),
              selected: isSelected,
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF334155),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : const Color(0xFFE2E8F0),
                ),
              ),
              onSelected: (selected) {
                if (selected && selectedKantor != id) {
                  onKantorChanged(id);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
