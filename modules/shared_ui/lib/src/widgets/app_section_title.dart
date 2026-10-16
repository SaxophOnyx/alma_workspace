import 'package:flutter/material.dart';

import '../../shared_ui.dart';

/// A section's name set large, with a short Oro rule beneath: the one gold accent of the screen.
class AppSectionTitle extends StatelessWidget {
  final String text;

  const AppSectionTitle({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppDimens.gapM,
      children: <Widget>[
        AppText(
          text: text,
          style: context.appTexts.display,
          maxLines: null,
          color: context.appColors.textPrimary,
        ),
        ColoredBox(
          color: context.appColors.accent,
          child: const SizedBox(width: AppDimens.ruleWidth, height: AppDimens.ruleThickness),
        ),
      ],
    );
  }
}
