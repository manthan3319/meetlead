import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

class LogoBadge extends StatelessWidget {
  const LogoBadge({super.key, required this.scale});

  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: Container(
        width: 104,
        height: 104,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'M',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 52,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
