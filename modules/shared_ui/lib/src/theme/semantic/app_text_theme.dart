import 'package:flutter/material.dart';

import '../raw/app_fonts.dart';

final class AppTextTheme extends ThemeExtension<AppTextTheme> {
  final TextStyle body;

  const AppTextTheme({
    required this.body,
  });

  factory AppTextTheme.light() {
    return const AppTextTheme(
      body: AppFonts.default_14,
    );
  }

  factory AppTextTheme.dark() {
    return const AppTextTheme(
      body: AppFonts.default_14,
    );
  }

  @override
  AppTextTheme copyWith({
    TextStyle? body,
  }) {
    return AppTextTheme(
      body: body ?? this.body,
    );
  }

  @override
  AppTextTheme lerp(
    covariant ThemeExtension<AppTextTheme>? other,
    double t,
  ) {
    if (other is! AppTextTheme) {
      return this;
    }

    return AppTextTheme(
      body: TextStyle.lerp(body, other.body, t)!,
    );
  }
}
