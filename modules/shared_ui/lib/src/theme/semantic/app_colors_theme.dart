import 'package:flutter/material.dart';

import '../raw/app_colors.dart';

final class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  final Color primary;

  const AppColorsTheme({
    required this.primary,
  });

  factory AppColorsTheme.light() {
    return const AppColorsTheme(
      primary: AppColors.luridRed,
    );
  }

  factory AppColorsTheme.dark() {
    return const AppColorsTheme(
      primary: AppColors.luridRed,
    );
  }

  @override
  AppColorsTheme copyWith({
    Color? primary,
  }) {
    return AppColorsTheme(
      primary: primary ?? this.primary,
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
      primary: Color.lerp(primary, other.primary, t)!,
    );
  }
}
