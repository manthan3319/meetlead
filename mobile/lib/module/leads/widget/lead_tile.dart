import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/lead_model.dart';

class LeadTile extends StatelessWidget {
  final LeadModel lead;
  final VoidCallback onTap;
  final VoidCallback onWhatsapp;
  final VoidCallback onCall;

  const LeadTile({
    super.key,
    required this.lead,
    required this.onTap,
    required this.onWhatsapp,
    required this.onCall,
  });

  Color _priorityColor(String p) {
    switch (p) {
      case 'hot':
        return AppColors.red;
      case 'warm':
        return Colors.orange;
      default:
        return AppColors.textgrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(lead.priority);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(
            lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          lead.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${lead.phone ?? ''} • ${lead.source}',
          style: const TextStyle(color: AppColors.textgrey, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chat,
                  color: Color(0xFF25D366), size: 22),
              onPressed: onWhatsapp,
            ),
            IconButton(
              icon: const Icon(Icons.call,
                  color: AppColors.primary, size: 22),
              onPressed: onCall,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
