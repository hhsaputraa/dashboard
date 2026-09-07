import 'package:flutter/material.dart';
import 'package:dashboard/core/theme/app_theme.dart';

class OfficeOption {
  final int id;
  final String label;

  const OfficeOption(this.id, this.label);
}

class KantorFilterChips extends StatelessWidget {
  final int selectedKantor;
  final ValueChanged<int> onKantorChanged;
  final List<OfficeOption> offices;

  static const List<OfficeOption> defaultOffices = [
    OfficeOption(0, 'Semua Kantor'),
    OfficeOption(1, 'Kantor 1'),
    OfficeOption(2, 'Kantor 2'),
    OfficeOption(3, 'Kantor 3'),
  ];

  static final OutlinedBorder _selectedShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: const BorderSide(color: AppTheme.primaryColor),
  );

  static final OutlinedBorder _unselectedShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: const BorderSide(color: Color(0xFFE2E8F0)),
  );

  static const TextStyle _selectedTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  static const TextStyle _unselectedTextStyle = TextStyle(
    color: Color(0xFF334155),
    fontWeight: FontWeight.normal,
    fontSize: 12,
  );

  const KantorFilterChips({
    super.key,
    required this.selectedKantor,
    required this.onKantorChanged,
    this.offices = defaultOffices,
  });

  @override
  Widget build(BuildContext context) {
    final displayOffices = offices.isNotEmpty ? offices : defaultOffices;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: displayOffices.map((off) {
          final isSelected = selectedKantor == off.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              label: Text(off.label),
              selected: isSelected,
              selectedColor: AppTheme.primaryColor,
              labelStyle: isSelected ? _selectedTextStyle : _unselectedTextStyle,
              backgroundColor: Colors.white,
              shape: isSelected ? _selectedShape : _unselectedShape,
              onSelected: (selected) {
                if (selected && selectedKantor != off.id) {
                  onKantorChanged(off.id);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
