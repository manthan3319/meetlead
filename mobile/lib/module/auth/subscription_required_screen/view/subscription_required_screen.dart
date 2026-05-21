import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../provider/subscription_required_provider.dart';
import '../widget/lock_badge.dart';

class SubscriptionRequiredScreen extends StatelessWidget {
  const SubscriptionRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubscriptionRequiredProvider(),
      child: const _SubscriptionRequiredView(),
    );
  }
}

class _SubscriptionRequiredView extends StatelessWidget {
  const _SubscriptionRequiredView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SubscriptionRequiredProvider>();
    return Scaffold(
      backgroundColor: AppColors.fildbg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LockBadge(),
                const SizedBox(height: 24),
                const Text(
                  'Subscription Required',
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
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
                    onPressed: () => p.openWebsite(context),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open Website to Buy Plan'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: p.refreshing ? null : () => p.refresh(context),
                    icon: p.refreshing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                        p.refreshing ? 'Checking...' : 'I\'ve Paid — Refresh'),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () => p.logout(context),
                  icon: const Icon(Icons.logout,
                      color: AppColors.red, size: 18),
                  label: const Text('Logout',
                      style: TextStyle(color: AppColors.red)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
