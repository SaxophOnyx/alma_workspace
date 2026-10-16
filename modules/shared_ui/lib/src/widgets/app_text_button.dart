import 'package:flutter/material.dart';

import '../../shared_ui.dart';

enum AppTextButtonStyle {
  navigation,
  title,
  menu,
  action,
  signal,
}

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final AppTextButtonStyle style;
  final bool isHighlighted;
  final bool isEnabled;
  final String? semanticLabel;

  const AppTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style = AppTextButtonStyle.action,
    this.isHighlighted = false,
    this.isEnabled = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorsTheme colors = context.appColors;
    final TextStyle textStyle = switch (style) {
      AppTextButtonStyle.navigation => context.appTexts.navigation,
      AppTextButtonStyle.title => context.appTexts.title,
      AppTextButtonStyle.menu => context.appTexts.menu,
      AppTextButtonStyle.action || AppTextButtonStyle.signal => context.appTexts.body,
    };

    return TextButton(
      onPressed: isEnabled ? onPressed : null,
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.textSecondary;
          }
          if (style == AppTextButtonStyle.signal) {
            return colors.signal;
          }
          if (isHighlighted || states.contains(WidgetState.pressed)) {
            return colors.accent;
          }
          return colors.textPrimary;
        }),
        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        animationDuration: AppMotions.durationHighlight,
        textStyle: WidgetStatePropertyAll<TextStyle>(textStyle),
        minimumSize: const WidgetStatePropertyAll<Size>(
          Size(AppDimens.minTouchTarget, AppDimens.minTouchTarget),
        ),
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: AppDimens.gapS),
        ),
      ),
      child: Semantics(
        label: semanticLabel,
        excludeSemantics: semanticLabel != null,
        child: AppText(
          text: text,
          style: textStyle,
          maxLines: null,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
