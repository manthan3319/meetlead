import 'package:flutter/widgets.dart';

class SplashProvider {
  SplashProvider(TickerProvider vsync) {
    logoCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 900),
    )..forward();
    scale = CurvedAnimation(parent: logoCtrl, curve: Curves.easeOutBack);
    fade = CurvedAnimation(parent: logoCtrl, curve: Curves.easeIn);

    dotsCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  late final AnimationController logoCtrl;
  late final Animation<double> scale;
  late final Animation<double> fade;
  late final AnimationController dotsCtrl;

  void dispose() {
    logoCtrl.dispose();
    dotsCtrl.dispose();
  }
}
