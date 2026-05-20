// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../followups/followups_screen.dart';
import '../services/services_screen.dart';
import '../settings/settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fildbg,
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _item(context, Icons.flag, 'Follow-ups', 'Today\'s tasks & pending', AppColors.teal700, const FollowupsScreen()),
          _item(context, Icons.work, 'Services Catalog', 'Manage your services & pricing', AppColors.primary, const ServicesScreen()),
          _item(context, Icons.person_outline, 'Account & Settings', 'Profile, plan, logout', AppColors.dark, const SettingsScreen()),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title, String subtitle, Color color, Widget screen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textgrey, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textgrey),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      ),
    );
  }
}
