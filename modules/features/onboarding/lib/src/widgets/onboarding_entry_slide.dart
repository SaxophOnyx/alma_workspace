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
    return Center(
      child: AppTextButton(
        text: context.translations.onboarding.entry.enter,
        onPressed: onEnterPressed,
        style: AppTextButtonStyle.navigation,
        isHighlighted: isEnterHighlighted,
      ),
    );
  }
}
