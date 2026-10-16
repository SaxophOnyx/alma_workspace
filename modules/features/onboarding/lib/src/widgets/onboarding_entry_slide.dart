import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class OnboardingEntrySlide extends StatelessWidget {
  final bool isEnterHighlighted;
  final VoidCallback onEnterPressed;

  const OnboardingEntrySlide({
    super.key,
    required this.isEnterHighlighted,
    required this.onEnterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: AppDimens.gapM,
      children: <Widget>[
        AppTextButton(
          text: context.translations.onboarding.entry.enter,
          onPressed: onEnterPressed,
          style: AppTextButtonStyle.title,
          isHighlighted: isEnterHighlighted,
        ),
        AppFadeIn(
          delay: AppMotions.durationMedium,
          child: AppText(
            text: context.translations.onboarding.entry.caption,
            style: context.appTexts.captionSmall,
            maxLines: null,
            textAlign: TextAlign.center,
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
