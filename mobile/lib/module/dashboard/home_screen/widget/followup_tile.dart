import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme.dart';

class FollowupTile extends StatelessWidget {
  final dynamic item;
  const FollowupTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final lead = item['leadId'] ?? {};
    final when = DateTime.tryParse(item['scheduledAt'] ?? '') ?? DateTime.now();
    final type = item['type'] ?? 'call';

    IconData icon;
    Color color;
    switch (type) {
      case 'whatsapp':
        icon = Icons.chat;
        color = const Color(0xFF25D366);
        break;
      case 'meeting':
        icon = Icons.event;
        color = AppColors.primary;
        break;
      case 'visit':
        icon = Icons.place;
        color = AppColors.teal700;
        break;
      default:
        icon = Icons.phone;
        color = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead['name'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${type.toString().toUpperCase()} • ${DateFormat('h:mm a').format(when)}',
                  style: const TextStyle(
                      color: AppColors.textgrey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
