import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class LaunchContent extends StatelessWidget {
  const LaunchContent({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: AppFadeIn(
          delay: AppMotions.durationShort,
          child: AppText(
            text: context.translations.common.brand,
            style: context.appTexts.brand,
            color: context.appColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
