import 'package:flutter/material.dart';

import '../../../shared_ui.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData dark() {
    final ThemeData base = ThemeData(
      brightness: Brightness.dark,
      fontFamily: AppFonts.sansFamily,
      package: AppAssetUtils.appAssetPackageName,
      scaffoldBackgroundColor: AppColors.negro,
      canvasColor: AppColors.negro,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.oro,
        onPrimary: AppColors.negro,
        secondary: AppColors.humo,
        onSecondary: AppColors.negro,
        surface: AppColors.negro,
        onSurface: AppColors.crema,
        error: AppColors.carmin,
        onError: AppColors.crema,
      ),
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.oro,
        selectionHandleColor: AppColors.oro,
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppColorsTheme.dark(),
        AppTextTheme.dark(),
      ],
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.crema,
        displayColor: AppColors.crema,
      ),
    );
  }
}
