import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

class LegalText extends StatelessWidget {
  const LegalText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        text: 'By creating an account you agree to our ',
        style: TextStyle(color: AppColors.textgrey, fontSize: 11.5),
        children: [
          TextSpan(
            text: 'Terms',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
