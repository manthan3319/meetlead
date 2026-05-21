import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme.dart';
import '../../../../models/meeting_model.dart';

class MeetingTile extends StatelessWidget {
  final MeetingModel meeting;
  final VoidCallback onTap;

  const MeetingTile({super.key, required this.meeting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM, h:mm a');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
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
                color: AppColors.light,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.event, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meeting.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fmt.format(meeting.scheduledAt),
                    style: const TextStyle(
                        color: AppColors.textgrey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                meeting.type,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
