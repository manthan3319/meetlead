import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

class LockBadge extends StatelessWidget {
  const LockBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(
        Icons.lock_outline,
        size: 44,
        color: AppColors.primary,
      ),
    );
  }
}
