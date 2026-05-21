import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';

class FollowupTile extends StatelessWidget {
  final dynamic item;
  final VoidCallback onAction;
  final VoidCallback onComplete;

  const FollowupTile({
    super.key,
    required this.item,
    required this.onAction,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final lead = item['leadId'] ?? {};
    final when = DateTime.tryParse(item['scheduledAt'] ?? '') ?? DateTime.now();
    final isPending = item['status'] == 'pending';
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead['name'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${type.toString().toUpperCase()} • ${DateFormat('d MMM, h:mm a').format(when)}',
                  style: const TextStyle(
                      color: AppColors.textgrey, fontSize: 11),
                ),
                if ((item['note'] ?? '').toString().isNotEmpty)
                  Text(
                    item['note'],
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (isPending) ...[
            IconButton(
              onPressed: onAction,
              icon: Icon(icon, color: color, size: 22),
            ),
            IconButton(
              onPressed: onComplete,
              icon: const Icon(Icons.check_circle_outline,
                  color: AppColors.primary),
            ),
          ] else
            const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
        ],
      ),
    );
  }
}
