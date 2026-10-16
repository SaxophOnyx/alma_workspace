import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class OnboardingIntroSlide extends StatelessWidget {
  const OnboardingIntroSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final AppTextTheme texts = context.appTexts;
    final AppTranslations t = context.translations;
    final List<String> lines = <String>[
      t.onboarding.intro.line1,
      t.onboarding.intro.line2,
      t.onboarding.intro.line3,
      t.onboarding.intro.line4,
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // The name arrives out of the dark first; the lines follow once it has settled.
        AppFadeIn(
          delay: AppMotions.durationMedium,
          child: AppText(
            text: t.onboarding.intro.title,
            style: texts.brand,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppDimens.gapL),
        AppFadeIn(
          delay: AppMotions.durationMedium + AppMotions.durationLong + AppMotions.durationShort,
          child: AppText(
            text: lines.join('\n'),
            style: texts.quote,
            maxLines: null,
            textAlign: TextAlign.center,
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
