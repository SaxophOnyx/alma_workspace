import 'package:flutter/material.dart';

import '../../widgets/app_entrance.dart';
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

  /// The old screen fades out before the new one rises in, so two screens of text never overlap.
  static Widget fadeThrough(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Animation<double> incoming = CurvedAnimation(parent: animation, curve: AppMotions.fadeThroughIn);
    final Animation<double> outgoing = ReverseAnimation(
      CurvedAnimation(parent: secondaryAnimation, curve: AppMotions.fadeThroughOut),
    );

    return FadeTransition(
      opacity: outgoing,
      child: AppEntrance(
        animation: incoming,
        child: child,
      ),
    );
  }

  /// A route drawn over the current screen without fading it out, for popups and confirmations.
  ///
  /// A popup route, unlike a page route, does not drive the previous page's secondary animation.
  static Route<T> overlay<T>(BuildContext context, Widget child, Page<T> page) {
    return RawDialogRoute<T>(
      settings: page,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: AppMotions.durationShort,
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) => child,
      transitionBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        return AppEntrance(
          animation: CurvedAnimation(parent: animation, curve: AppMotions.entrance),
          child: child,
        );
      },
    );
  }
}
