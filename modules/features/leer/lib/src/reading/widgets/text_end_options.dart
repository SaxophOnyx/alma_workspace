import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class TextEndOptions extends StatelessWidget {
  final VoidCallback onAnotherTextPressed;
  final VoidCallback onBreathePressed;
  final VoidCallback onHomePressed;

  const TextEndOptions({
    super.key,
    required this.onAnotherTextPressed,
    required this.onBreathePressed,
    required this.onHomePressed,
  });

  @override
  Widget build(BuildContext context) {
    final AppTranslations t = context.translations;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppDimens.gapS,
      children: <Widget>[
        AppFadeIn(
          child: AppTextButton(
            text: t.leer.end.anotherText,
            onPressed: onAnotherTextPressed,
          ),
        ),
        AppFadeIn(
          delay: AppMotions.staggerInterval,
          child: AppTextButton(
            text: t.leer.end.breathe,
            onPressed: onBreathePressed,
          ),
        ),
        AppFadeIn(
          delay: AppMotions.staggerInterval * 2,
          child: AppTextButton(
            text: t.leer.end.home,
            onPressed: onHomePressed,
            style: AppTextButtonStyle.quiet,
          ),
        ),
      ],
    );
  }
}
