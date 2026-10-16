import 'package:flutter/animation.dart';

final class AppMotions {
  const AppMotions._();

  static const Duration durationHighlight = Duration(milliseconds: 200);
  static const Duration durationShort = Duration(milliseconds: 400);
  static const Duration durationMedium = Duration(milliseconds: 800);
  static const Duration durationLong = Duration(milliseconds: 1200);
  static const Duration durationQuoteFadeIn = Duration(milliseconds: 1500);
  static const Duration durationFadeOut = Duration(seconds: 2);

  static const Duration durationExitHold = Duration(seconds: 2);

  static const Duration staggerInterval = Duration(milliseconds: 600);

  /// Delay between siblings of a list or menu entering one after another.
  static const Duration staggerStep = Duration(milliseconds: 90);

  /// How long a load may take before the loading pulse appears.
  static const Duration loadingDelay = Duration(milliseconds: 300);

  /// One full cycle of the loading pulse.
  static const Duration loadingPulse = Duration(milliseconds: 1600);

  /// One full cycle of the breathing point's candle flicker during a hold.
  static const Duration flicker = Duration(milliseconds: 2400);

  /// How long the "Alma" word stays on the first-launch screen.
  static const Duration launchBrand = Duration(milliseconds: 2500);

  /// How long a chosen quiz answer is shown before the explanation.
  static const Duration quizAnswerEcho = Duration(milliseconds: 700);

  /// Fallback for leaving a quiz explanation that was never tapped.
  static const Duration quizExplanation = Duration(seconds: 6);

  static const Duration silenceStanza = Duration(seconds: 1);
  static const Duration silenceShort = Duration(seconds: 2);
  static const Duration silenceLong = Duration(seconds: 3);

  static const Curve standard = Curves.easeInOut;
  static const Curve entrance = Curves.easeOutCubic;

  /// Fade-through: the old screen leaves during the first part, the new one arrives during the rest.
  static const Curve fadeThroughOut = Interval(0, 0.4, curve: Curves.easeIn);
  static const Curve fadeThroughIn = Interval(0.4, 1, curve: Curves.easeOutCubic);
}
