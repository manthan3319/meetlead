import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../services/api_service.dart';

class SubscriptionRequiredProvider extends ChangeNotifier {
  bool _refreshing = false;
  bool get refreshing => _refreshing;

  Future<Uri> buildBrowserUri() async {
    final token = await ApiService().getToken();
    if (token != null && token.isNotEmpty) {
      return Uri.parse(
        'http://10.88.70.1:3001/auth/bridge'
        '?token=${Uri.encodeQueryComponent(token)}'
        '&next=${Uri.encodeQueryComponent('/dashboard/plans')}',
      );
    }
    return Uri.parse('http://10.88.70.1:3001/dashboard/plans');
  }

  Future<void> openWebsite(BuildContext context) async {
    final url = await buildBrowserUri();
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not open browser. Visit 10.88.70.1:3001 manually.'),
          ),
        );
      }
    }
  }

  Future<void> refresh(BuildContext context) async {
    _refreshing = true;
    notifyListeners();
    try {
      await context.read<AuthProvider>().refreshSubscription();
      if (context.mounted &&
          !context.read<AuthProvider>().hasActiveSubscription) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Still no active subscription found.'),
          ),
        );
      }
    } finally {
      _refreshing = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
  }
}
