import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'services/notification_service.dart';
import 'screens/auth/login_screen/view/login_screen.dart';
import 'screens/auth/splash_screen/view/splash_screen.dart';
import 'screens/dashboard/main_shell.dart';
import 'screens/auth/subscription_required_screen/view/subscription_required_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MeetLeadApp());
}

class MeetLeadApp extends StatelessWidget {
  const MeetLeadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..bootstrap()),
      ],
      child: MaterialApp(
        title: 'MeetLead Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _Bootstrap(),
      ),
    );
  }
}

class _Bootstrap extends StatelessWidget {
  const _Bootstrap();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        if (!auth.booted) return const SplashScreen();
        if (!auth.isAuthenticated) return const LoginScreen();
        final isAdmin = auth.user?.role == 'superadmin' || auth.user?.role == 'admin';
        if (!auth.hasActiveSubscription && !isAdmin) return const SubscriptionRequiredScreen();
        return const MainShell();
      },
    );
  }
}
