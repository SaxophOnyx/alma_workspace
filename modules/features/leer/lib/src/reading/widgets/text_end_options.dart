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

    return AppFadeIn(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppDimens.gapL,
        children: <Widget>[
          AppTextButton(
            text: t.leer.end.anotherText,
            onPressed: onAnotherTextPressed,
          ),
          AppTextButton(
            text: t.leer.end.breathe,
            onPressed: onBreathePressed,
          ),
          AppTextButton(
            text: t.leer.end.home,
            onPressed: onHomePressed,
          ),
        ],
      ),
    );
  }
}
