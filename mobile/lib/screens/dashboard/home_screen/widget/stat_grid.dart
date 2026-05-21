import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

class StatGrid extends StatelessWidget {
  final Map<String, dynamic>? summary;
  const StatGrid({super.key, this.summary});

  @override
  Widget build(BuildContext context) {
    final leads = summary?['leads'] ?? {};
    final meetings = summary?['meetings'] ?? {};
    final followups = summary?['followups'] ?? {};

    final tiles = [
      _Tile(
        label: "Today's Meetings",
        value: '${meetings['today'] ?? 0}',
        icon: Icons.event,
        color: AppColors.primary,
      ),
      _Tile(
        label: 'Pending Follow-ups',
        value: '${followups['pending'] ?? 0}',
        icon: Icons.flag,
        color: AppColors.teal700,
      ),
      _Tile(
        label: 'New Leads',
        value: '${leads['new'] ?? 0}',
        icon: Icons.fiber_new,
        color: AppColors.dark,
      ),
      _Tile(
        label: 'Won Leads',
        value: '${leads['won'] ?? 0}',
        icon: Icons.emoji_events,
        color: Colors.amber.shade700,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: tiles,
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _Tile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textgrey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
