import 'package:flutter/material.dart';

import 'app_motions.dart';

final class AppPageTransitions {
  const AppPageTransitions._();

  static Widget fade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: AppMotions.standard),
      child: child,
    );
  }
}
