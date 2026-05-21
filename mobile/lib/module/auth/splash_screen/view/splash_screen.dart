import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../provider/splash_provider.dart';
import '../widget/glow_circle.dart';
import '../widget/loading_dots.dart';
import '../widget/logo_badge.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SplashHost();
  }
}

class _SplashHost extends StatefulWidget {
  const _SplashHost();

  @override
  State<_SplashHost> createState() => _SplashHostState();
}

class _SplashHostState extends State<_SplashHost>
    with TickerProviderStateMixin {
  late final SplashProvider _splash;

  @override
  void initState() {
    super.initState();
    _splash = SplashProvider(this);
  }

  @override
  void dispose() {
    _splash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<SplashProvider>.value(
      value: _splash,
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    final p = context.read<SplashProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.dark],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -80,
                right: -80,
                child: GlowCircle(
                  size: 220,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                bottom: -60,
                left: -60,
                child: GlowCircle(
                  size: 180,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LogoBadge(scale: p.scale),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: p.fade,
                      child: const Text(
                        'MeetLead Pro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FadeTransition(
                      opacity: p.fade,
                      child: Text(
                        'Lead. Meet. Convert.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 32,
                child: Column(
                  children: [
                    LoadingDots(controller: p.dotsCtrl),
                    const SizedBox(height: 12),
                    Text(
                      'Loading your workspace...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
