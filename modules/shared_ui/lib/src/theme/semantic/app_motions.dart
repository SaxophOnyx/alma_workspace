import 'package:flutter/animation.dart';

final class AppMotions {
  const AppMotions._();

  static const Duration durationShort = Duration(milliseconds: 400);
  static const Duration durationMedium = Duration(milliseconds: 800);
  static const Duration durationLong = Duration(milliseconds: 1200);

  static const Duration silenceShort = Duration(seconds: 2);
  static const Duration silenceLong = Duration(seconds: 3);

  static const Curve standard = Curves.easeInOut;
}
