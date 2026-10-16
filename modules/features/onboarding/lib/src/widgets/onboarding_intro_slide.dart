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
      spacing: AppDimens.gapS,
      children: <Widget>[
        AppText(
          text: t.onboarding.intro.title,
          style: texts.brand,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.gapL),
        for (final String line in lines)
          AppText(
            text: line,
            style: texts.poetry,
            maxLines: null,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
