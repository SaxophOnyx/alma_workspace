import 'package:flutter/material.dart';

import '../../shared_ui.dart';

/// Fades [child] in while it rises by [AppDimens.entranceOffset], driven by [animation] from 0 to 1.
class AppEntrance extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const AppEntrance({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: Offset(0, AppDimens.entranceOffset * (1 - animation.value)),
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}
