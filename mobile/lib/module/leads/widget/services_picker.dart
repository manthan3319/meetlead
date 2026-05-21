import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class ServicesPicker extends StatelessWidget {
  final List<dynamic> available;
  final Set<String> selected;
  final void Function(String id, bool isOn) onToggle;

  const ServicesPicker({
    super.key,
    required this.available,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (available.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.light,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'No services yet. Add services in the Services tab to link them here.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: available.map<Widget>((s) {
        final id = s['_id'] as String;
        final isOn = selected.contains(id);
        return FilterChip(
          label: Text('${s['name']} • ₹${s['price'] ?? 0}'),
          selected: isOn,
          selectedColor: AppColors.light,
          checkmarkColor: AppColors.primary,
          side: BorderSide(
              color: isOn ? AppColors.primary : AppColors.fildbg),
          onSelected: (v) => onToggle(id, v),
        );
      }).toList(),
    );
  }
}
