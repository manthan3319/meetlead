// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

class AuthHero extends StatelessWidget {
  const AuthHero({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeroClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 60),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.dark],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Container(
                //   width: 44,
                //   height: 44,
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   alignment: Alignment.center,
                //   child: const Text(
                //     'M',
                //     style: TextStyle(
                //       color: AppColors.primary,
                //       fontSize: 22,
                //       fontWeight: FontWeight.w800,
                //     ),
                //   ),
                // ),
                // const SizedBox(width: 10),
                const Text(
                  'MeetLead Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final p = Path()
      ..lineTo(0, s.height - 30)
      ..quadraticBezierTo(s.width / 2, s.height + 20, s.width, s.height - 30)
      ..lineTo(s.width, 0)
      ..close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
