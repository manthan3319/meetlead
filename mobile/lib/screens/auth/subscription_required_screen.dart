import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class SubscriptionRequiredScreen extends StatefulWidget {
  const SubscriptionRequiredScreen({super.key});
  @override
  State<SubscriptionRequiredScreen> createState() => _SubscriptionRequiredScreenState();
}

class _SubscriptionRequiredScreenState extends State<SubscriptionRequiredScreen> {
  bool _refreshing = false;

  Future<void> _openWebsite() async {
    final url = Uri.parse('http://localhost:3001/dashboard/plans');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open browser. Visit localhost:3001 manually.')),
        );
      }
    }
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      await context.read<AuthProvider>().refreshSubscription();
      if (mounted && !context.read<AuthProvider>().hasActiveSubscription) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Still no active subscription found.')),
        );
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    // Consumer in main.dart will rebuild and show LoginScreen automatically.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fildbg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(22)),
                  child: const Icon(Icons.lock_outline, size: 44, color: AppColors.primary),
                ),
                const SizedBox(height: 24),
                const Text('Subscription Required', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Your trial has ended or you don\'t have an active plan. Purchase a plan on our website to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textgrey),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openWebsite,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open Website to Buy Plan'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _refreshing ? null : _refresh,
                    icon: _refreshing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                    label: Text(_refreshing ? 'Checking...' : 'I\'ve Paid — Refresh'),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: AppColors.red, size: 18),
                  label: const Text('Logout', style: TextStyle(color: AppColors.red)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
