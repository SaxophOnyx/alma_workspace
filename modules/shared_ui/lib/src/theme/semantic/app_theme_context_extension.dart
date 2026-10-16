import 'package:flutter/material.dart';

import 'app_colors_theme.dart';
import 'app_text_theme.dart';

extension AppThemeContextExtension on BuildContext {
  AppColorsTheme get appColors {
    final AppColorsTheme? theme = Theme.of(this).extension<AppColorsTheme>();
    assert(
      theme != null,
      'AppColorsTheme not found in Theme.extensions. Ensure AppTheme.light()/dark() includes AppColorsTheme.',
    );
    return theme!;
  }

  AppTextTheme get appTexts {
    final AppTextTheme? theme = Theme.of(this).extension<AppTextTheme>();
    assert(
      theme != null,
      'AppTextTheme not found in Theme.extensions. Ensure AppTheme.light()/dark() includes AppTextTheme.',
    );
    return theme!;
  }
}
