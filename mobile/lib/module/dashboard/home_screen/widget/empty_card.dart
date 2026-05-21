import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

class EmptyCard extends StatelessWidget {
  final String text;
  final IconData icon;

  const EmptyCard({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.textgrey.withValues(alpha: 0.5)),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(color: AppColors.textgrey)),
        ],
      ),
    );
  }
}
