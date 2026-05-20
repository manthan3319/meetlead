// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final sub = auth.subscription;
    return Scaffold(
      backgroundColor: AppColors.fildbg,
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary,
                  child: Text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(user?.email ?? '', style: const TextStyle(color: AppColors.textgrey, fontSize: 13)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(6)),
                        child: Text(user?.role ?? '', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (sub != null) _SubscriptionCard(sub: sub),
          const SizedBox(height: 16),
          _menuItem(Icons.person, 'Profile', () {}),
          _menuItem(Icons.notifications_outlined, 'Notifications', () {}),
          _menuItem(Icons.mic, 'Voice Assistant', () {}),
          _menuItem(Icons.language, 'Language', () {}),
          _menuItem(Icons.help_outline, 'Help & Support', () async {
            final url = Uri.parse('https://meetlead.com/support');
            if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
          }),
          _menuItem(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await auth.logout();
              // Consumer in main.dart rebuilds to LoginScreen automatically.
              if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textgrey),
        onTap: onTap,
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final dynamic sub;
  const _SubscriptionCard({required this.sub});

  @override
  Widget build(BuildContext context) {
    final end = sub['endDate'] != null ? DateTime.tryParse(sub['endDate']) : null;
    final days = end == null ? 0 : end.difference(DateTime.now()).inDays;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.dark]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: Colors.white),
              const SizedBox(width: 8),
              Text(sub['planId']?['name'] ?? 'Plan',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                child: Text(sub['status']?.toString().toUpperCase() ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('$days days remaining', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
