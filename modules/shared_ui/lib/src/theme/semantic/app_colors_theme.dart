import 'package:flutter/material.dart';

import '../raw/app_colors.dart';

final class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color signal;

  const AppColorsTheme({
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.signal,
  });

  factory AppColorsTheme.dark() {
    return const AppColorsTheme(
      background: AppColors.negro,
      textPrimary: AppColors.crema,
      textSecondary: AppColors.humo,
      accent: AppColors.oro,
      signal: AppColors.carmin,
    );
  }

  @override
  AppColorsTheme copyWith({
    Color? background,
    Color? textPrimary,
    Color? textSecondary,
    Color? accent,
    Color? signal,
  }) {
    return AppColorsTheme(
      background: background ?? this.background,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      accent: accent ?? this.accent,
      signal: signal ?? this.signal,
    );
  }

  @override
  AppColorsTheme lerp(
    covariant ThemeExtension<AppColorsTheme>? other,
    double t,
  ) {
    if (other is! AppColorsTheme) {
      return this;
    }

    return AppColorsTheme(
      background: Color.lerp(background, other.background, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      signal: Color.lerp(signal, other.signal, t)!,
    );
  }
}
