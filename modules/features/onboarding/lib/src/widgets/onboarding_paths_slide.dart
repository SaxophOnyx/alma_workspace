import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class OnboardingPathsSlide extends StatelessWidget {
  const OnboardingPathsSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final AppTranslations t = context.translations;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: AppDimens.gapXl,
      children: <Widget>[
        AppFadeIn(
          child: _PathLine(
            title: t.onboarding.paths.breatheTitle,
            subtitle: t.onboarding.paths.breatheSubtitle,
          ),
        ),
        AppFadeIn(
          delay: AppMotions.staggerInterval,
          child: _PathLine(
            title: t.onboarding.paths.speakTitle,
            subtitle: t.onboarding.paths.speakSubtitle,
          ),
        ),
        AppFadeIn(
          delay: AppMotions.staggerInterval * 2,
          child: _PathLine(
            title: t.onboarding.paths.readTitle,
            subtitle: t.onboarding.paths.readSubtitle,
          ),
        ),
      ],
    );
  }
}

class _PathLine extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PathLine({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final AppTextTheme texts = context.appTexts;

    return Column(
      spacing: AppDimens.gapXs,
      children: <Widget>[
        AppText(
          text: title,
          style: texts.headlineLarge,
          textAlign: TextAlign.center,
        ),
        AppText(
          text: subtitle,
          style: texts.caption,
          textAlign: TextAlign.center,
          color: context.appColors.textSecondary,
        ),
      ],
    );
  }
}
