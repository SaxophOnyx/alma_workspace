import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared_ui.dart';

class AppFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const AppFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotions.durationLong,
  });

  @override
  State<AppFadeIn> createState() => _AppFadeInState();
}

class _AppFadeInState extends State<AppFadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _opacity;
  late final Timer _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: AppMotions.standard,
    );
    _delayTimer = Timer(widget.delay, _controller.forward);
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
    return FadeTransition(
      opacity: _opacity,
      child: widget.child,
    );
  }
}
