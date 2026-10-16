import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared_ui.dart';

/// What a screen shows while it loads: nothing for a quick load, then a single slowly pulsing Oro dot.
class AppLoadingPulse extends StatefulWidget {
  const AppLoadingPulse({super.key});

  @override
  State<AppLoadingPulse> createState() => _AppLoadingPulseState();
}

class _AppLoadingPulseState extends State<AppLoadingPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _opacity;
  late final Timer _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotions.loadingPulse);
    _opacity = CurvedAnimation(parent: _controller, curve: AppMotions.standard);
    _delayTimer = Timer(AppMotions.loadingDelay, () => _controller.repeat(reverse: true));
  }

  @override
  void dispose() {
    _delayTimer.cancel();
    _opacity.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _opacity,
        child: DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, color: context.appColors.accent),
          child: const SizedBox.square(dimension: AppDimens.loadingDot),
        ),
      ),
    );
  }
}
