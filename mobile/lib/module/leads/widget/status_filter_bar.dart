import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class StatusFilterBar extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const StatusFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _options = <(String, String?)>[
    ('All', null),
    ('New', 'new'),
    ('Contacted', 'contacted'),
    ('Qualified', 'qualified'),
    ('Won', 'won'),
    ('Lost', 'lost'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _options.map((o) => _chip(o.$1, o.$2)).toList(),
      ),
    );
  }

  Widget _chip(String label, String? value) {
    final isSelected = selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textgrey,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
        ),
        onSelected: (_) => onChanged(value),
      ),
    );
  }
}
