import 'package:flutter/material.dart';

import '../../../shared_ui.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      extensions: <ThemeExtension<dynamic>>[
        AppColorsTheme.light(),
        AppTextTheme.light(),
      ],
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      extensions: <ThemeExtension<dynamic>>[
        AppColorsTheme.dark(),
        AppTextTheme.dark(),
      ],
    );
  }
}
