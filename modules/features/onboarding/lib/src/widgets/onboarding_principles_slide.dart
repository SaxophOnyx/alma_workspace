import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class OnboardingPrinciplesSlide extends StatelessWidget {
  const OnboardingPrinciplesSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final AppTextTheme texts = context.appTexts;
    final AppTranslations t = context.translations;
    final List<String> lines = <String>[
      t.onboarding.principles.noAccount,
      t.onboarding.principles.noInternet,
      t.onboarding.principles.noNotifications,
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: AppDimens.gapS,
      children: <Widget>[
        for (final String line in lines)
          AppText(
            text: line,
            style: texts.title,
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: AppDimens.gapL),
        AppText(
          text: t.onboarding.principles.closing,
          style: texts.quote,
          maxLines: null,
          textAlign: TextAlign.center,
          color: context.appColors.textSecondary,
        ),
      ],
    );
  }
}
